//
//  MemoryTool.hpp
//  UE4
//
//  Created by yy on 2022/5/9.
//

#ifndef MemoryTool_hpp
#define MemoryTool_hpp

#include <stdio.h>
#include <dlfcn.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <string.h>
#include <string>
#include <mach/mach.h>
#include <mach-o/dyld.h>
#include <mach-o/dyld_images.h>
#include <math.h>




static uintptr_t module_base = 0;
static mach_port_t Task;


static bool 地址泄露(uintptr_t address) {
    return address && address > 0x100000000 && address < 0x160000000;
}



#endif /* MemoryTool_hpp */
