//
//  PUBGDrawView.m
//  ChatsNinja
//
//  Created by TianCgg on 2022/10/2.
//

//#import "huitu.h"
//#import "PUBGDrawDataFactory.h"
#import "MGPGLabel.h"
#import <cstddef>
#import <cstdlib>
#import <dlfcn.h>
#import <spawn.h>
#import <unistd.h>
#import <notify.h>
#import <net/if.h>
#import <ifaddrs.h>
#import <sys/wait.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#import <mach-o/dyld.h>
#import <objc/runtime.h>
#include "Draw.h"
#include <stdio.h>
#include <string>
#include <math.h>
#include "MemoryTool.hpp"
#include "VectorHeader.h"
#include "utf.h"

#define kTest   0
//#define kWidth  [UIScreen mainScreen].bounds.size.width
//#define kHeight [UIScreen mainScreen].bounds.size.height
#define KMTLColor           MTLClearColorMake(0, 0, 0, 0)
#define KWindowBgColor      ImVec4(235.0f / 255.0f, 235.0f / 255.0f, 235.0f / 255.0f, 1.0f)
#define KTextColor          ImVec4(70.0f / 255.0f, 70.0f / 255.0f, 70.0f / 255.0f, 1.0f)
#define KScrollbarBgColor   ImVec4(35.0f / 255.0f, 35.0f / 255.0f, 35.0f / 255.0f, 0.0f)
#define iPhone8P ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)
#define KClearColor         [UIColor clearColor]
#define SCREEN_WIDTH            [[UIScreen mainScreen] bounds].size.width

#define KImGuiWindowFlags   ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoSavedSettings | ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoScrollbar | ImGuiWindowFlags_NoScrollWithMouse | ImGuiWindowFlags_NoBackground
@interface 绘图吧()
@end

@implementation 绘图吧
CAShapeLayer* Draw_Line_绿色;
CAShapeLayer* Draw_Line_绿色填充;
CAShapeLayer* Draw_Line_红色填充;
CAShapeLayer* Draw_Line_人物填充;
CAShapeLayer* Draw_Line_白色_HP;
CAShapeLayer* Draw_Line_红色_HP;
CAShapeLayer* Draw_Line_红色;
CAShapeLayer* Draw_Line_白色;

UIBezierPath* Path_Line_绿色;
UIBezierPath* Path_Line_绿色填充;

UIBezierPath* Path_Line_白色_HP;
UIBezierPath* Path_Line_红色_HP;
UIBezierPath* Path_Line_红色填充;
UIBezierPath* Path_Line_人物填充;
UIBezierPath* Path_Line_红色;
UIBezierPath* Path_Line_白色;
int UseText,totalEnemies;
CGSize ScreenSize;
MGPGLabel* ShowPlayers;
static int chiqiang=0;
UILabel* PlayerName[200];
long GWorld,PersistentLevel,ActorArray,NetDriver,ServerConnection,PlayerController,PlayerCameraManager,Character;
static id _sharedInstance;
static dispatch_once_t _onceToken;
NSMutableDictionary *userDefaults;
NSString *deviceType;
Vector3 LocationWorldPos;
MinimalViewInfo POV;


static mach_port_t task;
extern "C" kern_return_t
mach_vm_region_recurse(
                       vm_map_t                 map,
                       mach_vm_address_t        *address,
                       mach_vm_size_t           *size,
                       uint32_t                 *depth,
                       vm_region_recurse_info_t info,
                       mach_msg_type_number_t   *infoCnt);



static int get_processes_pid() {
    static int PID;
    size_t length = 0;
    static const int name[] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
    int err = sysctl((int *)name, (sizeof(name) / sizeof(*name)) - 1, NULL, &length, NULL, 0);
    if (err == -1) err = errno;
    if (err == 0) {
        struct kinfo_proc *procBuffer = (struct kinfo_proc *)malloc(length);
        if(procBuffer == NULL) return -1;
        sysctl((int *)name, (sizeof(name) / sizeof(*name)) - 1, procBuffer, &length, NULL, 0);
        int count = (int)length / sizeof(struct kinfo_proc);
        for (int i = 0; i < count; ++i) {
            const char *procname = procBuffer[i].kp_proc.p_comm;
            NSString *进程名字=[NSString stringWithFormat:@"%s",procname];
            pid_t pid = procBuffer[i].kp_proc.p_pid;
            //自己写判断进程名 和平精英
            if([进程名字 containsString:@"ShadowTrackerExt"])
            {
                kern_return_t kret = task_for_pid(mach_task_self(), pid, &task);
                if (kret == KERN_SUCCESS) {
                    PID = pid;
                }
            }
            
        }
        
        
    }
    
    return  PID;
}
static long libbase;
static BOOL get_base_address() {
    vm_map_offset_t vmoffset = 0;
    vm_map_size_t vmsize = 0;
    uint32_t nesting_depth = 0;
    struct vm_region_submap_info_64 vbr;
    mach_msg_type_number_t vbrcount = 16;
    pid_t pid =get_processes_pid();;
    kern_return_t kret = task_for_pid(mach_task_self(), pid, &task);
    if (kret == KERN_SUCCESS) {
        mach_vm_region_recurse(task, &vmoffset, &vmsize, &nesting_depth, (vm_region_recurse_info_t)&vbr, &vbrcount);
        libbase= vmoffset;
        return YES;
    }
    return NO;
}


static bool Read(long address, void *buffer, int length)
{
    vm_size_t size = 0;
    kern_return_t error = vm_read_overwrite(task, (vm_address_t)address, length, (vm_address_t)buffer, &size);
    if(error != KERN_SUCCESS || size != length){
        return NO;
    }
    return YES;
}

template<typename T> T 内存地址(long address) {
    T data;
    Read(address, reinterpret_cast<void *>(&data), sizeof(T));
    return data;
}

struct ObjectName{
    const char data[64];
};

static ObjectName Read_name(long Address){
    ObjectName result={0};
    Read(Address,&result,sizeof(ObjectName));
    return result;
}

static Vector3 getRelativeLocation(uintptr_t actor){
    uintptr_t RootComponent = 内存地址<uintptr_t>(actor + 0x268);
    static Vector3 value;
    Read(RootComponent + 0x1b0, &value, sizeof(Vector3));
    return value;
}

static FTransform getMatrixConversion(uintptr_t address){
    static FTransform ret;
    Read(address, &ret.rot.x, sizeof(float));
    Read(address+4, &ret.rot.y, sizeof(float));
    Read(address+8,  &ret.rot.z, sizeof(float));
    Read(address+12,  &ret.rot.w, sizeof(float));
    
    Read(address+16,  &ret.translation.x, sizeof(float));
    Read(address+20,  &ret.translation.y, sizeof(float));
    Read(address+24,  &ret.translation.z, sizeof(float));
    
    Read(address+32,  &ret.scale.x, sizeof(float));
    Read(address+36,  &ret.scale.y, sizeof(float));
    Read(address+40,  &ret.scale.z, sizeof(float));
    
    return ret;
}

static Vector3 getBoneWithRotation(uintptr_t mesh, int Id, FTransform publicObj){
    static FTransform BoneMatrix;
    static Vector3 output = {0, 0, 0};
    
    uintptr_t addr;
    if (!Read(mesh + 0x6c8, &addr, sizeof(uintptr_t))) {
        return output;
    }
    BoneMatrix = getMatrixConversion(addr + Id * 0x30);
    
    D3DXMATRIX LocalSkeletonMatrix =toMatrixWithScale(BoneMatrix.rot, BoneMatrix.translation, BoneMatrix.scale);
    
    D3DXMATRIX PartTotheWorld = toMatrixWithScale(publicObj.rot, publicObj.translation, publicObj.scale);
    
    D3DXMATRIX NewMatrix = matrixMultiplication(LocalSkeletonMatrix, PartTotheWorld);
    

    
    Vector3 BoneCoordinates;
    BoneCoordinates.x = NewMatrix._41;
    BoneCoordinates.y = NewMatrix._42;
    BoneCoordinates.z = NewMatrix._43;
    
    return BoneCoordinates;
}

+ (instancetype)cjDrawView
{
    return [[绘图吧 alloc] initWithFrame:[UIScreen mainScreen].bounds];
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
       

     
        self.userInteractionEnabled = NO;
        self.layer.allowsEdgeAntialiasing = YES;
        Draw_Line_绿色 = [[CAShapeLayer alloc] init];
        Draw_Line_绿色.frame = self.bounds;
        Draw_Line_绿色.strokeColor = UIColor.greenColor.CGColor;
        Draw_Line_绿色.fillColor = UIColor.clearColor.CGColor;
        Draw_Line_绿色.lineWidth=0.5;
        [self.layer addSublayer:Draw_Line_绿色];
        
        Draw_Line_绿色 = [[CAShapeLayer alloc] init];
        Draw_Line_绿色.frame = self.bounds;
        Draw_Line_绿色.strokeColor = UIColor.greenColor.CGColor;
        Draw_Line_绿色.fillColor = UIColor.clearColor.CGColor;
        [self.layer addSublayer:Draw_Line_绿色];
        
        Draw_Line_白色_HP = [[CAShapeLayer alloc] init];
        Draw_Line_白色_HP.frame = self.bounds;
        Draw_Line_白色_HP.strokeColor = UIColor.whiteColor.CGColor;
        Draw_Line_白色_HP.fillColor = UIColor.clearColor.CGColor;
        Draw_Line_白色_HP.lineWidth = 3.8;
        [self.layer addSublayer:Draw_Line_白色_HP];
        
        Draw_Line_红色_HP = [[CAShapeLayer alloc] init];
        Draw_Line_红色_HP.frame = self.bounds;
        Draw_Line_红色_HP.strokeColor = UIColor.redColor.CGColor;
        Draw_Line_红色_HP.fillColor = UIColor.clearColor.CGColor;
        Draw_Line_红色_HP.lineWidth = 3.8;
        [self.layer addSublayer:Draw_Line_红色_HP];
        
        Draw_Line_红色 = [[CAShapeLayer alloc] init];
        Draw_Line_红色.frame = self.bounds;
        Draw_Line_红色.strokeColor = UIColor.redColor.CGColor;
        Draw_Line_红色.fillColor = UIColor.clearColor.CGColor;
        Draw_Line_红色.lineWidth=0.5;
        [self.layer addSublayer:Draw_Line_红色];
        
        Draw_Line_白色 = [[CAShapeLayer alloc] init];
        Draw_Line_白色.frame = self.bounds;
        Draw_Line_白色.strokeColor = UIColor.whiteColor.CGColor;
        Draw_Line_白色.fillColor = UIColor.clearColor.CGColor;
        [self.layer addSublayer:Draw_Line_白色];
        
        Draw_Line_人物填充 = [[CAShapeLayer alloc] init];
        Draw_Line_人物填充.frame = self.bounds;
       // Draw_Line_人物填充.strokeColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor;
        Draw_Line_人物填充.fillColor =[UIColor colorWithRed:(random()%255)/255.0 green:(random()%255)/255.0 blue:(random()%255)/255.0 alpha:0.7].CGColor;
        Draw_Line_人物填充.cornerRadius=2.0f;
        [self.layer addSublayer:Draw_Line_人物填充];
        
        Draw_Line_红色填充 = [[CAShapeLayer alloc] init];
        Draw_Line_红色填充.frame = self.bounds;
        Draw_Line_红色填充.strokeColor = UIColor.redColor.CGColor;
        Draw_Line_红色填充.fillColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1].CGColor;
        [self.layer addSublayer:Draw_Line_红色填充];
        
        Draw_Line_绿色填充 = [[CAShapeLayer alloc] init];
        Draw_Line_绿色填充.frame = self.bounds;
        Draw_Line_绿色填充.strokeColor = UIColor.greenColor.CGColor;
        Draw_Line_绿色填充.fillColor = UIColor.greenColor.CGColor;
        [self.layer addSublayer:Draw_Line_绿色填充];
        
        ShowPlayers = [[MGPGLabel alloc] init];
        ShowPlayers.frame = CGRectMake(0, 0, 120, 36);
        ShowPlayers.text = @"0";
        ShowPlayers.textColor = UIColor.redColor;
        ShowPlayers.font = [UIFont boldSystemFontOfSize:40.f];
        ShowPlayers.borderColor=[UIColor whiteColor];
        ShowPlayers.borderWidth=3;
        ShowPlayers.center = CGPointMake(self.bounds.size.height/2, 60);
        ShowPlayers.textAlignment = NSTextAlignmentCenter;
        [self addSubview:ShowPlayers];
        Path_Line_绿色 = [[UIBezierPath alloc] init];
        Path_Line_红色填充 = [[UIBezierPath alloc] init];
        Path_Line_绿色填充 = [[UIBezierPath alloc] init];
        Path_Line_白色_HP = [[UIBezierPath alloc] init];
        Path_Line_红色_HP = [[UIBezierPath alloc] init];
        Path_Line_红色 = [[UIBezierPath alloc] init];
        Path_Line_白色 = [[UIBezierPath alloc] init];
        Path_Line_人物填充 = [[UIBezierPath alloc] init];
        for (int i=0; i<100; i++) {
            
            PlayerName[i] = [[UILabel alloc] init];
            PlayerName[i].frame = CGRectMake(0, 0, 200, 11);
            PlayerName[i].text = @"";
            PlayerName[i].textColor = UIColor.whiteColor;
            PlayerName[i].font = [UIFont boldSystemFontOfSize:6.f];
            PlayerName[i].textAlignment = NSTextAlignmentCenter;
            PlayerName[i].hidden = YES;
            [self addSubview:PlayerName[i]];

                
          
          
        }
        
        
        CADisplayLink* Link = [CADisplayLink displayLinkWithTarget:self selector:@selector(huizhia)];
        Link.preferredFramesPerSecond = 60;
        [Link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat Width = CGRectGetWidth(self.frame);
    CGFloat Height = CGRectGetHeight(self.frame);
   

}
#define USER_DEFAULTS_PATH @"/var/mobile/Library/Preferences/com.leemin.helium.plist"






int get_Pid(NSString* GameName) {
    struct kinfo_proc *procBuffer = NULL; // 提前声明，初始化为NULL
    size_t length = 0;
    static const int name[] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
    int err = sysctl((int *)name, (sizeof(name) / sizeof(*name)) - 1, NULL, &length, NULL, 0);
    if (err == -1) err = errno;
    if (err == 0) {
        procBuffer = (struct kinfo_proc *)malloc(length);
        if (procBuffer == NULL) return -1;
        err = sysctl((int *)name, (sizeof(name) / sizeof(*name)) - 1, procBuffer, &length, NULL, 0);
        if (err == -1) {
            free(procBuffer); // 如果sysctl失败，释放内存
            return -1;
        }
        int count = (int)length / sizeof(struct kinfo_proc);
        for (int i = 0; i < count; ++i) {
            const char *procname = procBuffer[i].kp_proc.p_comm;
            NSString *进程名字 = [NSString stringWithFormat:@"%s", procname];
            pid_t pid = procBuffer[i].kp_proc.p_pid;
            if ([进程名字 containsString:GameName]) {
                free(procBuffer); // 找到匹配后释放内存
                return pid;
            }
        }
        free(procBuffer); // 遍历结束后释放内存
    }
    // 如果代码能够走到这里，说明没有找到匹配的进程，或者在调用 sysctl 时出现了错误。
    // 如果 procBuffer 被分配了内存，需要释放它。
    if (procBuffer != NULL) {
        free(procBuffer);
    }
    return -1; // 如果没有找到匹配的进程，返回 -1
}
void DrawLine(Vector2 startPoint, Vector2 endPoint, UIBezierPath *path) {
    [path moveToPoint:CGPointMake(startPoint.X, startPoint.Y)];
    [path addLineToPoint:CGPointMake(endPoint.X, endPoint.Y)];
}


static void DrawText(NSString* Text,Vector2 Pos,UIColor *sb)
{
    
    if (UseText >= 100) return;
    PlayerName[UseText].text = Text;
    PlayerName[UseText].center = CGPointMake(Pos.X, Pos.Y);
    PlayerName[UseText].textColor = sb;
    PlayerName[UseText].hidden = NO;
    UseText++;
}


void drawRectWithMin(CGPoint minPoint,CGSize size,UIBezierPath*path,UIColor *color){
    CGRect rect = CGRectMake(minPoint.x, minPoint.y, size.width, size.height);
    [path appendPath:[UIBezierPath bezierPathWithRect:rect]];
    
    [color setFill];
    [path fill];
}
void DrawRect(Vector2 Min,Vector2 Size,UIBezierPath* Path)
{
    [Path appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(Min.X, Min.Y, Size.X, Size.Y)]];
}

void DrawCircle(Vector2 Pos,float R,UIBezierPath* Path)
{
    [Path appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(Pos.X, Pos.Y) radius:R startAngle:0 endAngle:M_PI*2 clockwise:YES]];
}

#pragma mark - 事件
static bool isContain(std::string str, const char* check) {
    size_t found = str.find(check);
    return (found != std::string::npos);
}

-(void)huizhia{
    UseText = 0;
    ScreenSize = self.bounds.size;
    ShowPlayers.center = CGPointMake(ScreenSize.height/2, 60);
    NSString*gameName = @"ShadowTrackerExt";
    pid_t gamePid = get_Pid(gameName);
 
    get_base_address();
    
    [Path_Line_绿色 removeAllPoints];
    [Path_Line_红色填充 removeAllPoints];
    [Path_Line_绿色填充 removeAllPoints];
    [Path_Line_绿色填充 removeAllPoints];
    [Path_Line_白色_HP removeAllPoints];
    [Path_Line_红色 removeAllPoints];
    [Path_Line_人物填充 removeAllPoints];
    [Path_Line_白色 removeAllPoints];


    GetActor();
    
    
    for (int i=UseText; i<100; i++) {
        PlayerName[i].hidden = YES;
        
      
      

    }
 
    Draw_Line_绿色.path = Path_Line_绿色.CGPath;
    Draw_Line_白色_HP.path = Path_Line_白色_HP.CGPath;
    Draw_Line_红色_HP.path = Path_Line_红色_HP.CGPath;
    Draw_Line_红色.path = Path_Line_红色.CGPath;
    Draw_Line_白色.path = Path_Line_白色.CGPath;
    Draw_Line_红色填充.path = Path_Line_红色填充.CGPath;
    Draw_Line_人物填充.path = Path_Line_人物填充.CGPath;
    Draw_Line_绿色填充.path = Path_Line_绿色填充.CGPath;


}

void GetPlyaerData(long GWorld, long player)
{
    if (YES){
       
        
        
        long NetDriver = 内存地址<long>(GWorld + 0x98);
        if (!地址泄露(NetDriver)) return;

        long ServerConnection = 内存地址<long>(NetDriver + 0x88);
        if (!地址泄露(ServerConnection)) return;

        long PlayerController = 内存地址<long>(ServerConnection + 0x30);
        if (!地址泄露(PlayerController)) return;

        long PlayerCameraManager = 内存地址<long>(PlayerController + 0x5D8);
        if (!地址泄露(PlayerCameraManager)) return;

        long Character = 内存地址<long>(PlayerController + 0x2d50);
        if (!地址泄露(Character)) return;

        if (player == Character) return;

        MinimalViewInfo Moverd = 内存地址<MinimalViewInfo>(PlayerCameraManager +0x1120 + 0x10);

        // 判断死亡
        bool bDead = 内存地址<char>(player + 0xe28) & 1;
        if (bDead) return;

        // 团队号
        int TeamID = 内存地址<int>(player + 0xa60);
        int MyTeam = 内存地址<int>(Character + 0x9c0);
        if (TeamID == MyTeam) return;

        // 世界坐标
        LocationWorldPos = getRelativeLocation(player);
       Vector2 LocationScreen = worldToScreen(LocationWorldPos, Moverd, Vector2(ScreenSize.height, ScreenSize.width));
       
        // 距离
        float distance = getDistance(LocationWorldPos, Moverd.Location) / 100;
        if (distance > 600) return;
       

        FVectorRect rect;
        rect=worldToScreenForRect(LocationWorldPos, Moverd, Vector2(ScreenSize.height, ScreenSize.width));

      //  FVectorRect ss=(LocationWorldPos, Moverd, ScreenSize.width, ScreenSize.height);
     

        // 敌人数量统计
        totalEnemies++;

        // 人物骨骼
        userDefaults = [[NSDictionary dictionaryWithContentsOfFile:USER_DEFAULTS_PATH] mutableCopy] ?: [NSMutableDictionary dictionary];
        NSNumber *mode = [userDefaults objectForKey: @"shexian"];
        NSNumber *mode1 = [userDefaults objectForKey: @"guge"];
        NSNumber *mode2 = [userDefaults objectForKey: @"xinxi"];
        NSNumber *mode3 = [userDefaults objectForKey: @"xueliang"];
        bool shexian =YES;
        bool guge = YES;
        bool xinxi = YES;
        bool xueliang = YES;
        
        if (distance<500)
        {
            // 判断人机
            bool bIsAI = false;
            bIsAI = 内存地址<bool>(player + 0xA7C) != 0;
            //手持武器
            int ShootWeaponid = 0;
            long TheWeapon = *(long*)(player + 0x2bf8 + 0x20);
//            if(!地址泄露(TheWeapon))ShootWeaponid = *(int*)(TheWeapon + 0xa28);//否则crash
//            chiqiang=ShootWeaponid;

            long Mesh = 内存地址<long>(player +0x5D0);
            if (!地址泄露(Mesh)) return;

            FTransform RelativeScale3D = getMatrixConversion(Mesh +0x194 + 0xC);

            int Bone[18] = {6,5,4,3,2,1,12,13,14,33,34,35,53,54,55,57,58,59};
            int Bone1[18] = {6,5,4,3,2,1,12,13,14,34,35,53,56,57,58,60,61,62};
            int playmax=内存地址<int>(Mesh+0x6c8+0x8);
            
            bool Visible[18];
            Vector2 Bones_Pos[18];
            Vector3 Hitpart[18];

            Vector2 打击点屏幕坐标;
            Vector3 打击点世界坐标, root;

            for (int i = 0; i < 18; i++) {
                int bones= (playmax == 65)?Bone[i]:Bone1[i];
                Vector3 pos = getBoneWithRotation(Mesh, bones, RelativeScale3D);
                Hitpart[i] = pos;
             
                Bones_Pos[i] = worldToScreen(pos, Moverd, Vector2(ScreenSize.height, ScreenSize.width));
            }
            Vector2 HeadScreen = worldToScreen(getBoneWithRotation(Mesh, 6, RelativeScale3D), Moverd, Vector2(ScreenSize.height, ScreenSize.width));
          
            
            if(guge){
                
                
                   DrawLine(Vector2(Bones_Pos[1].X, Bones_Pos[1].Y), Vector2(Bones_Pos[2].X, Bones_Pos[2].Y), (bIsAI)?Path_Line_绿色:Path_Line_白色);
                   
                   DrawLine(Vector2(Bones_Pos[2].X, Bones_Pos[2].Y), Vector2(Bones_Pos[3].X, Bones_Pos[3].Y), (bIsAI)?Path_Line_绿色:Path_Line_白色);
                   DrawLine(Vector2(Bones_Pos[3].X, Bones_Pos[3].Y), Vector2(Bones_Pos[4].X, Bones_Pos[4].Y), (bIsAI)?Path_Line_绿色:Path_Line_白色);
                   DrawLine(Vector2(Bones_Pos[4].X, Bones_Pos[4].Y), Vector2(Bones_Pos[5].X, Bones_Pos[5].Y), (bIsAI)?Path_Line_绿色:Path_Line_白色);
                   
                   DrawLine(Vector2(Bones_Pos[2].X, Bones_Pos[2].Y), Vector2(Bones_Pos[6].X, Bones_Pos[6].Y), (bIsAI)?Path_Line_绿色:Path_Line_白色);
                   DrawLine(Vector2(Bones_Pos[6].X, Bones_Pos[6].Y), Vector2(Bones_Pos[7].X, Bones_Pos[7].Y), (bIsAI)?Path_Line_绿色:Path_Line_白色);
                   DrawLine(Vector2(Bones_Pos[7].X, Bones_Pos[7].Y), Vector2(Bones_Pos[8].X, Bones_Pos[8].Y), (bIsAI)?Path_Line_绿色:Path_Line_白色);
                   
                   DrawLine(Vector2(Bones_Pos[2].X, Bones_Pos[2].Y), Vector2(Bones_Pos[9].X, Bones_Pos[9].Y), (bIsAI)?Path_Line_绿色:Path_Line_白色);
                   DrawLine(Vector2(Bones_Pos[9].X, Bones_Pos[9].Y), Vector2(Bones_Pos[10].X, Bones_Pos[10].Y), (bIsAI)?Path_Line_绿色:Path_Line_白色);
                   DrawLine(Vector2(Bones_Pos[10].X, Bones_Pos[10].Y), Vector2(Bones_Pos[11].X, Bones_Pos[11].Y), (bIsAI)?Path_Line_绿色:Path_Line_白色);
                   
                   DrawLine(Vector2(Bones_Pos[5].X, Bones_Pos[5].Y), Vector2(Bones_Pos[12].X, Bones_Pos[12].Y), (bIsAI)?Path_Line_绿色:Path_Line_白色);
                   DrawLine(Vector2(Bones_Pos[12].X, Bones_Pos[12].Y), Vector2(Bones_Pos[13].X, Bones_Pos[13].Y), (bIsAI)?Path_Line_绿色:Path_Line_白色);
                   DrawLine(Vector2(Bones_Pos[13].X, Bones_Pos[13].Y), Vector2(Bones_Pos[14].X, Bones_Pos[14].Y), (bIsAI)?Path_Line_绿色:Path_Line_白色);
                   
                   DrawLine(Vector2(Bones_Pos[5].X, Bones_Pos[5].Y), Vector2(Bones_Pos[15].X, Bones_Pos[15].Y), (bIsAI)?Path_Line_绿色:Path_Line_白色);
                   DrawLine(Vector2(Bones_Pos[15].X, Bones_Pos[15].Y), Vector2(Bones_Pos[16].X, Bones_Pos[16].Y), (bIsAI)?Path_Line_绿色:Path_Line_白色);
                   DrawLine(Vector2(Bones_Pos[16].X, Bones_Pos[16].Y), Vector2(Bones_Pos[17].X, Bones_Pos[17].Y), (bIsAI)?Path_Line_绿色:Path_Line_白色);
            }
            if(shexian){
                if(distance <=50){
                    DrawLine(Vector2(ScreenSize.height/2, 10), Vector2(rect.X+ rect.W/2, rect.Y-57),Path_Line_绿色);
                }else if (distance>=50){
                    DrawLine(Vector2(ScreenSize.height/2, 10), Vector2(rect.X+ rect.W/2, rect.Y-57),Path_Line_红色);
                }
            }
            float Health = 内存地址<float>(player + 0xdc0);
            float HealthMax = 内存地址<float>(player + 0xdc8);
            
            float x=rect.X;
            float y=rect.Y;
            float dw = 40;//血量长短
                         float lineHeight = 1.8;
                         float spaceHeight = 1.0;
                         float rectHeight = lineHeight * 2 + spaceHeight;
                         float dx = rect.X + rect.W * 0.5 - dw * 0.5;
                         float dy = rect.Y - rectHeight * 2;
                         float HealthRatio = (Health / HealthMax * 100) / 100;
              float percent = dw * HealthRatio;
              
       
              if(xueliang){
                  if(Health<=20)
                      //人机血条颜色
                      
                      DrawRect(Vector2(dx-20, dy+1), Vector2(Health*0.8, 1), Path_Line_红色填充);
                  else
                      //真人血条颜色
                      
                      DrawRect(Vector2(dx-20, dy+1), Vector2(Health*0.8, 1), Path_Line_绿色填充);
                  
              }
            if(xinxi){
                DrawText([NSString stringWithFormat:@"%.f米",distance], Vector2(Bones_Pos[1].X  , Bones_Pos[1].Y + 25),[UIColor greenColor]);
                
                DrawRect(Vector2(dx-20, dy-15), Vector2(80, 15), Path_Line_人物填充);
                NSString* PlayerName = getPlayerName(player);
                DrawText([NSString stringWithFormat:bIsAI?@"%02d队.[AI]%@":@"%02d队.[玩家]%@",TeamID,PlayerName], Vector2(rect.X+ rect.W/2, rect.Y-17),[UIColor yellowColor]);
                
                
            }
            
            
          



        }else{
            DrawLine(Vector2(ScreenSize.height/2, 10), Vector2(LocationScreen.X, LocationScreen.Y),Path_Line_白色);
        }

    }

}



std::string GetFName(long TNameEntryArray)
{
    int32_t FNameID = 内存地址<int32_t>(TNameEntryArray + 0x18);
    uintptr_t UName = 内存地址<long>(libbase+0xB24A0F8);
    long FNameEntryArr = 内存地址<uintptr_t>(UName + ((FNameID / 0x4000) * 8));
    long FNameEntry = 内存地址<uintptr_t>(FNameEntryArr + ((FNameID % 0x4000) * 8));
    if(!地址泄露(FNameEntry))return "";
    std::string name(100, '\0');
    memcpy((void *) name.data(), reinterpret_cast<void *>(FNameEntry + 0xE), 100 * sizeof(char));
    name.shrink_to_fit();
    return name;
}

void GetActor()
{
        totalEnemies = 0;

        long GWorld = 内存地址<long>(libbase+0xB5F2CA8);
    uintptr_t gname = 内存地址<long>(libbase+0xB24A0F8);
        
        if (!地址泄露(GWorld)) return;
        long PersistentLevel = 内存地址<long>(GWorld + 0x90);
        if (!地址泄露(PersistentLevel)) return;
        long ActorArray = 内存地址<long>(PersistentLevel + 0xA0);
        if (!地址泄露(ActorArray)) return;


        Character = 内存地址<long>(PlayerController + 0x2d50);



        int ActorCount = 内存地址<int>(PersistentLevel +0xA8);
        if (ActorCount > 0 && ActorCount < 50000) {
            for (int i = 0; i < ActorCount; i++) {
                long actor = 内存地址<long>(ActorArray + i * 8);
                
                int class_id = 内存地址<int>(actor + 0x18);
                long fNamePtr = 内存地址<long>(gname + int(class_id / 0x4000) * 0x8);
                if(!fNamePtr) continue;
                long fName = 内存地址<long>(fNamePtr + int(class_id % 0x4000) * 0x8);
                if(!fName) continue;
                ObjectName pBuffer = Read_name(fName + 0xE);
                std::string bpname = pBuffer.data;
                NSString *ClassName= [NSString stringWithCString:bpname.c_str() encoding:[NSString defaultCStringEncoding]];
                
                
                
                if (地址泄露(actor)) {
//                    std::string FName = GetFName(actor);
//                    if (FName.empty()) continue;


                    NSLog(@"打印 FName %@",ClassName);
                    if ([ClassName containsString:@"PlayerPawn"]||[ClassName containsString:@"PlayerCharacter"]||[ClassName containsString:@"PlayerControllertSl"]||[ClassName containsString:@"_PlayerPawn_TPlanAI_C"]||[ClassName containsString:@"CharacterModelTaget"]||[ClassName containsString:@"FakePlayer_AIPawn"]) GetPlyaerData(GWorld, actor);

                }
            }
        }

        ShowPlayers.text = [NSString stringWithFormat:@"%d",totalEnemies];

}

NSString *getPlayerName(uintptr_t player)
{
    char Name[128];
    unsigned short buf16[16] = {0};
    uintptr_t PlayerName = 内存地址<long>(player+ 0x9E0);
    if (!地址泄露(PlayerName)) {
        return @"";
    }
    
    if (!Read(PlayerName,buf16,28)) {
        return @"";
    }
    
    unsigned short *tempbuf16 = buf16;
    char *tempbuf8 = Name;
    char *buf8 = tempbuf8 + 32;
    while (tempbuf16 < tempbuf16 + 28) {
        if (*tempbuf16 <= 0x007F && tempbuf8 + 1 < buf8) {
            *tempbuf8++ = (char) *tempbuf16;
        } else if (*tempbuf16 >= 0x0080 && *tempbuf16 <= 0x07FF && tempbuf8 + 2 < buf8) {
            *tempbuf8++ = (*tempbuf16 >> 6) | 0xC0;
            *tempbuf8++ = (*tempbuf16 & 0x3F) | 0x80;
        } else if (*tempbuf16 >= 0x0800 && *tempbuf16 <= 0xFFFF && tempbuf8 + 3 < buf8) {
            *tempbuf8++ = (*tempbuf16 >> 12) | 0xE0;
            *tempbuf8++ = ((*tempbuf16 >> 6) & 0x3F) | 0x80;
            *tempbuf8++ = (*tempbuf16 & 0x3F) | 0x80;
        } else {
            break;
        }
        tempbuf16++;
    }
    
    return [NSString stringWithUTF8String:Name];
}


//
//#pragma mark -------------------------------------懒加载-----------------------------------------



@end
