#ifndef memmm_hpp
#define memmm_hpp

#include <stdio.h>
#include <stdlib.h>
#include <sys/sysctl.h>
#include <dlfcn.h>
#include <unistd.h>
#include <sys/mman.h>
#include <string.h>
#include <string>
#include <mach/mach.h>
#include <mach-o/dyld.h>
#include <mach-o/dyld_images.h>
#include <math.h>
#include "UtfTool.hpp"
#include "libproc.h"
#import <Foundation/Foundation.h>
#include <errno.h>
#define __int64 int64_t
#ifndef PROC_ALL_PIDS
#define PROC_ALL_PIDS 1
#endif

#ifndef PROC_PIDPATHINFO_MAXSIZE
#define PROC_PIDPATHINFO_MAXSIZE 1024
#endif


mach_vm_address_t Cosmksence;

mach_port_t global_task_port = MACH_PORT_NULL;  // 全局 task_port


// 获取指定进程的 task port
mach_port_t get_task_port(pid_t pid) {
    mach_port_t task;
    kern_return_t kr = task_for_pid(mach_task_self(), pid, &task);
    if (kr != KERN_SUCCESS) {
       // NSLog(@"[Cosmk2137] 获取 task port 失败，PID: %d, 错误码: %d", pid, kr);
        return MACH_PORT_NULL;
    }
   // NSLog(@"[Cosmk2137] 获取 task port 成功，PID: %d", pid);
    return task;
}


// 获取指定进程的 task port
void initialize_task_port(pid_t pid) {
    global_task_port = get_task_port(pid);
    if (global_task_port == MACH_PORT_NULL) {
      // NSLog(@"[Cosmk2137] 无法获取进程 %d 的 task port", pid);
    } else {
      // NSLog(@"[Cosmk2137] 成功初始化 task port, PID: %d", pid);
    }
}



// 自定义 mach_vm_read 替代函数，使用 vm_read 实现
kern_return_t mach_vm_read(mach_port_t target_task, mach_vm_address_t address, mach_vm_size_t size, mach_vm_address_t *data, mach_vm_size_t *data_size) {
    vm_offset_t outData = 0;      // 用于存储读取的数据指针
    mach_msg_type_number_t outSize = 0;  // 用于存储读取的数据大小

    // 调用 vm_read 来读取目标进程的内存
    kern_return_t kr = vm_read(target_task, (vm_address_t)address, (vm_size_t)size, &outData, &outSize);

    if (kr == KERN_SUCCESS) {
        *data = outData;
        *data_size = outSize;
       // NSLog(@"[Cosmk2137] 成功读取内存，地址: 0x%llx, 大小: %llu", address, size);
    } else {
       // NSLog(@"[Cosmk2137] 读取内存失败，地址: 0x%llx, 错误码: %d", address, kr);
    }

    return kr;
}


static bool ReadMemory(mach_vm_address_t address, void* buffer, size_t size) {
    mach_vm_size_t data_size = 0;
    mach_vm_address_t out_memory = 0;

    // 使用 mach_vm_read 来读取目标进程的内存
    kern_return_t kr = mach_vm_read(global_task_port, address, size, &out_memory, &data_size);
    
    // 检查读取是否成功以及读取的数据大小是否正确
    if (kr != KERN_SUCCESS || data_size != size) {
       // NSLog(@"[Cosmk2137] 读取内存失败，错误码: %d，地址: 0x%llx", kr, address);
        return false;
    }

    // 将 mach_vm_read 返回的内存复制到用户提供的缓冲区
    memcpy(buffer, (void*)out_memory, size);
    //NSLog(@"[Cosmk2137] 内存读取成功，地址: 0x%llx, 大小: %zu", address, size);

    // 释放 mach_vm_read 分配的内存
    vm_deallocate(mach_task_self(), out_memory, data_size);

    return true;
}


// 获取 dyld_all_image_infos 结构的地址
mach_vm_address_t GetDyldInfoAddress(mach_port_t task) {
    struct task_dyld_info dyld_info;
    mach_msg_type_number_t count = TASK_DYLD_INFO_COUNT;

    kern_return_t kr = task_info(task, TASK_DYLD_INFO, (task_info_t)&dyld_info, &count);
    if (kr != KERN_SUCCESS) {
        //NSLog(@"[Cosmk2137] 获取 dyld_all_image_infos 失败, 错误码: %d", kr);
        return 0;
    }
    //NSLog(@"[Cosmk2137] 获取 dyld_all_image_infos 成功");
    return dyld_info.all_image_info_addr;
}

// 获取特定模块的基地址
mach_vm_address_t GetModuleBaseAddress(mach_port_t task, const char* moduleName) {
    mach_vm_address_t dyldInfoAddr = GetDyldInfoAddress(task);
    if (dyldInfoAddr == 0) {
        //NSLog(@"[Cosmk2137] 获取 dyld_info 地址失败");
        return 0;
    }

    struct dyld_all_image_infos dyld_info;
    if (!ReadMemory( dyldInfoAddr, &dyld_info, sizeof(dyld_info))) {
        //NSLog(@"[Cosmk2137] 读取 dyld_all_image_infos 失败");
        return 0;
    }

    for (uint32_t i = 0; i < dyld_info.infoArrayCount; i++) {
        struct dyld_image_info image_info;
        if (!ReadMemory((mach_vm_address_t)dyld_info.infoArray + i * sizeof(struct dyld_image_info), &image_info, sizeof(image_info))) {
            continue;
        }

        char imagePath[PROC_PIDPATHINFO_MAXSIZE];
        if (!ReadMemory((mach_vm_address_t)image_info.imageFilePath, imagePath, sizeof(imagePath))) {
            continue;
        }

        if (strstr(imagePath, moduleName)) {
            //NSLog(@"[Cosmk2137] 找到模块 '%s'，基地址: 0x%llx", moduleName, (mach_vm_address_t)image_info.imageLoadAddress);
            return (mach_vm_address_t)image_info.imageLoadAddress;
        }
    }

    //NSLog(@"[Cosmk2137] 未找到模块 '%s'", moduleName);
    return 0;
}


// 获取指定进程的 PID
pid_t GetProcessPID(const char* targetProcessName) {
    int maxProcCount = proc_listpids(PROC_ALL_PIDS, 0, NULL, 0) / sizeof(pid_t);
    pid_t *pids = (pid_t *)malloc(maxProcCount * sizeof(pid_t));
    if (!pids) {
        //NSLog(@"[Cosmk2137] 无法分配内存");
        return -1;
    }

    int procCount = proc_listpids(PROC_ALL_PIDS, 0, pids, maxProcCount * sizeof(pid_t));
    pid_t targetPID = -1;

    for (int i = 0; i < procCount / sizeof(pid_t); i++) {
        pid_t pid = pids[i];
        if (pid == 0) {
            continue;
        }

        char pathBuffer[PROC_PIDPATHINFO_MAXSIZE];
        proc_pidpath(pid, pathBuffer, sizeof(pathBuffer));

        if (strstr(pathBuffer, targetProcessName)) {
            targetPID = pid;
            //NSLog(@"[Cosmk2137] 找到目标进程 '%s'，PID: %d", targetProcessName, targetPID);
            break;
        }
    }
    
    free(pids);
    if (targetPID == -1) {
        //NSLog(@"[Cosmk2137] 未找到目标进程 '%s'", targetProcessName);
    }
    return targetPID;
}


template<typename T>
T DuQu(mach_vm_address_t address) {
    T data;

    // 检查 global_task_port 是否有效
    if (global_task_port == MACH_PORT_NULL) {
        //NSLog(@"[Cosmk2137] global_task_port 未初始化");
        return T();  // 返回默认值
    }

    // 使用 ReadMemory 函数读取目标地址的数据
    if (ReadMemory(address, &data, sizeof(T))) {
        //NSLog(@"[Cosmk2137] 读取成功, 地址: 0x%llx", address);
        return data;
    }

    //NSLog(@"[Cosmk2137] 读取失败, 地址: 0x%llx", address);
    return T();  // 读取失败，返回类型 T 的默认值
}

// 写入目标进程内存，使用全局的 global_task_port
static bool WriteMemory(mach_vm_address_t address, void* buffer, size_t size) {
    kern_return_t kr = vm_write(global_task_port, address, (vm_offset_t)buffer, (mach_msg_type_number_t)size);
    if (kr != KERN_SUCCESS) {
       
        return false;
    }
   
    return true;
}


template<typename T>
bool XieRu(mach_vm_address_t address, const T& value) {
    // 检查 global_task_port 是否有效
    if (global_task_port == MACH_PORT_NULL) {
        //NSLog(@"[Cosmk2137] global_task_port 未初始化，无法写入");
        return false;  // 返回失败
    }

    // 使用 WriteMemory 函数写入目标地址的数据
    if (WriteMemory(address, (void*)&value, sizeof(T))) {
        //NSLog(@"[Cosmk2137] 写入成功, 地址: 0x%llx, 大小: %zu", address, sizeof(T));
        return true;  // 写入成功
    }

    //NSLog(@"[Cosmk2137] 写入失败, 地址: 0x%llx", address);
    return false;  // 写入失败
}



typedef uintptr_t kaddr;
static bool IsValidAddress(kaddr address) {
    return address != 0;
}

#endif /* memmm_hpp */
