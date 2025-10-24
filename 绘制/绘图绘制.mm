#import "绘图绘制.h"
#import <notify.h>
#import <objc/runtime.h>
#import "绘图定义.h"
#import <sys/utsname.h>
#import "memmm.hpp"


@implementation 绘图绘制

CGFloat width;
CGFloat height;
CGSize ScreenSize;
float aimBotSize=999999;
float aimSpeed =1;

static DrawingView *CosmkzbView;
static dispatch_once_t _onceToken;
static id _sharedInstance;


- (void)viewDidLoad {
   [super viewDidLoad];
   
   [UIDevice.currentDevice setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
   
   CosmkzbView = [[DrawingView alloc] init];
   [self configureFullScreenView];
   
   CosmkzbView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
   CosmkzbView.userInteractionEnabled = YES;
   [self.view addSubview:CosmkzbView];
   
   [self startDraw];
   
  
          
          
}


- (void)configureFullScreenView {
   CGRect screenBounds = [UIScreen mainScreen].bounds;
   
   if (screenBounds.size.width < screenBounds.size.height) {
      width = screenBounds.size.height;
      height = screenBounds.size.width;
      CosmkzbView.frame = CGRectMake(0, 0, width, height);
   } else {
      CosmkzbView.frame = screenBounds;
   }
   
   ScreenSize = CosmkzbView.frame.size;
}

- (void)viewWillLayoutSubviews {
   [super viewWillLayoutSubviews];
   [self configureFullScreenView];
}

- (void)startDraw {
   CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(Tickfuncc)];
   [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

+ (instancetype)sharedInstance {
   dispatch_once(&_onceToken, ^{
      _sharedInstance = [[self alloc] init];
   });
   return _sharedInstance;
}





- (void)Tickfuncc {
   [CosmkzbView setNeedsDisplay];
   Cosmk();
   
   
   CGPoint screenCenter = CGPointMake(width / 2.0,height / 2.0);
   
   
   [CosmkzbView drawCircleWithCenter:screenCenter
                       radius:FovRadius
                    thickness:1
                   strokeColor:[UIColor greenColor]];
   UIColor *color = [UIColor redColor];
   UIFont *font = [UIFont systemFontOfSize:18];

   // "人机" text setup
   NSString *人机人数 = [NSString stringWithFormat:@"人机:%d", AItotalEnemies];
   CGSize 人机字体大小 = [人机人数 sizeWithAttributes:@{ NSFontAttributeName: font }];
   CGRect 人机字体位置 = CGRectMake(width / 2 - 65, 15, 人机字体大小.width, 人机字体大小.height);

   // "玩家" text setup
   NSString *玩家人数 = [NSString stringWithFormat:@"玩家:%d", totalEnemies];
   CGSize 玩家字体大小 = [玩家人数 sizeWithAttributes:@{ NSFontAttributeName: font }];
   CGRect 玩家字体位置 = CGRectMake(width / 2 + 15, 15, 玩家字体大小.width, 玩家字体大小.height);

   // Draw "人机" and "玩家" texts
   [CosmkzbView drawText:人机人数 inRect:人机字体位置 withFont:font color:color isCentered:YES outline:YES];
   [CosmkzbView drawText:玩家人数 inRect:玩家字体位置 withFont:font color:color isCentered:YES outline:YES];

   // "0527 内部" centered text setup below "人机" and "玩家"
   NSString *additionalText = @"SK·三角洲";
   UIFont *additionalFont = [UIFont systemFontOfSize:18];
   UIColor *additionalColor = [UIColor whiteColor];
   CGSize additionalTextSize = [additionalText sizeWithAttributes:@{ NSFontAttributeName: additionalFont }];
   CGRect additionalTextPosition = CGRectMake((width - additionalTextSize.width) / 2.0, CGRectGetMaxY(人机字体位置) + 25, additionalTextSize.width, additionalTextSize.height);

   // Draw "0527 内部" text centered below "人机" and "玩家"
   [CosmkzbView drawText:additionalText inRect:additionalTextPosition withFont:additionalFont color:additionalColor isCentered:YES outline:YES];
   
   
   
   const char* targetProcessName = "DeltaForceClient";
   pid_t targetPID = GetProcessPID(targetProcessName);
   
   if (targetPID == -1) {
      NSLog(@"Cosmk2137  无法找到进程: %s", targetProcessName);
   } else {
      
      global_task_port = get_task_port(targetPID);
      
      if (global_task_port == MACH_PORT_NULL) {
         NSLog(@"Cosmk2137  无法获取 task port");
      } else {
         
         const char* targetModuleName = "DeltaForceClient";
         mach_vm_address_t moduleBaseAddress = GetModuleBaseAddress(global_task_port, targetModuleName);
         
         if (moduleBaseAddress != 0) {
            Cosmksence = moduleBaseAddress;
            
         }
      }
   }
}


static long Character, PlayerCameraManager, PlayerController;
static int MyTeamId;
static long ControlRotation;
bool isFiring;
int MYId;
最小视图信息 POV;
矩阵 tempMatrix;
char PlayerName[100];

static int totalEnemies,AItotalEnemies = 0;
float FovRadius=60;
static void Cosmk() {
   if (Cosmksence != 0) {
      totalEnemies = 0;
      AItotalEnemies= 0;
      
      long GWorld = DuQu<long>(Cosmksence + 0x111CF05F8);
      if (!IsValidAddress(GWorld)) return;
      
      auto NetDriver = DuQu<long>(GWorld + 0x30);
      if (!IsValidAddress(NetDriver)) return;
      
      auto ServerConnection = DuQu<long>(NetDriver + 0x88);
      if (!IsValidAddress(ServerConnection)) return;
      
      PlayerController = DuQu<long>(ServerConnection + 0x30);
      if (!IsValidAddress(PlayerController)) return;
      
      PlayerCameraManager = DuQu<long>(PlayerController + 0x408);
      if (!IsValidAddress(PlayerCameraManager)) return;
      
      POV = DuQu<最小视图信息>(PlayerCameraManager + 0x1540 + 0x10);
      
      ControlRotation = PlayerController + 0x3d8;
      if (!IsValidAddress(ControlRotation)) return;
      
      Character = DuQu<long>(PlayerController + 0x3d8);
      if (!IsValidAddress(Character)) return;
      
      
      long BlackBoard = DuQu<long>(Character + 0x448);
      if (!IsValidAddress(BlackBoard)) return;
      
      bool bIsLeftWeaponFiring = DuQu<char>(BlackBoard +0x50B) & 1;

      
      long PersistentLevel = DuQu<long>(GWorld + 0xF8);
      if (!IsValidAddress(PersistentLevel)) return;
      
      long Actors =  DuQu<long>(PersistentLevel + 0x98);
      if (!IsValidAddress(Actors)) return;
      
      int Count =  DuQu<int>(PersistentLevel + 0xA0);
      
      for (int i = 0; i < Count; i++) {
         
         long Actor = DuQu<long>(Actors + i * 8);
         if (!IsValidAddress(Actor )) continue;
         long HealthComp = DuQu<long>(Actor + 0xF68);
         if (!IsValidAddress(HealthComp)) continue;
         
         long HealthSet = DuQu<long>(HealthComp + 0x248);
         if (!IsValidAddress(HealthSet)) continue;
         
         float Health = DuQu<float>(HealthSet + 0x38 + 0x8);
         
         float MaxHealth = DuQu<float>(HealthSet + 0x48 + 0x8);
         
         if (Health > 0 && Health <= MaxHealth) {
            
            long Mesh = DuQu<long>(Actor + 0x3d0);
            if (!IsValidAddress(Mesh)) continue;
            
            VV3 LocationWorldPos = DuQu<VV3>(DuQu<long>(Actor + 0x180) + 0x220);
            
            
            int Team = DuQu<int>(DuQu<uintptr_t>(Actor + 0xEE8) + 0x108);
            int MyTeam = DuQu<int>(DuQu<uintptr_t>(Character + 0xEE8) + 0x108);
            if (Team == MyTeam) continue;
            
            float distance = VV3::Distance(LocationWorldPos, POV.Location) / 100;
            if (distance > 600) continue;
            
            
            long PlayerState = DuQu<long>(Actor + 0x378);
            

            getUTF8(PlayerName,DuQu<long>(DuQu<long>(Actor + 0x378) + 0x470));
            std::string Name = PlayerName;    // 人物名称
            
      //      bool Dead = DuQu<char>(Actor + 0xbc0) & 1;
            if (Health==0) continue;
            
            
            bool bIsAI = (Team == 508 || Team == 512 || Team == 528);
            
            if (bIsAI) {
               AItotalEnemies++;
            } else {
               totalEnemies++;
            }
            
            
            VV3 Bon[15],Pos_World;
            VVV2 Bones_Pos[15],Pos_Screen;
            
            int BoneList[15] = {31, 30, 1, 34, 6, 35, 7, 36, 8, 58, 62, 59, 63, 60, 64};
            
            for (int n = 0; n < 15; n++) {
               Bon[n] = GetBoneFTransform(Mesh, BoneList[n]);
               Bones_Pos[n] =世界坐标转屏幕坐标(Bon[n]);
               Pos_Screen = Bones_Pos[1];
               Pos_World = Bon[1];
            }
            
            float 压枪速率 = 0.3; // 可以根据需要调整
            float yq = 压枪速率;
            float tDistance = 0;
            float markDistance = width;
            VVV2 markScreenPos;
            markScreenPos.X = height / 2;
            markScreenPos.Y = height / 2;

            if (GetInsideFov(Pos_Screen,FovRadius)) {
               tDistance = GetCenterOffsetForVector(Pos_Screen);
               if (tDistance <= FovRadius && tDistance < markDistance) {
                  markDistance = tDistance;
                  markScreenPos = Pos_Screen;
                  FRotator aimRotation = Clamp(ToRotator(POV.Location, Pos_World));
                  FRotator myRotation = DuQu<FRotator>(ControlRotation);
                  FRotator angDelta = Clamp(aimRotation - myRotation);
                 if (distance > 1 && distance < 250) {
                        if (bIsLeftWeaponFiring) {
                           FRotator newRotation = Clamp(myRotation + angDelta * aimSpeed);
                           XieRu<FRotator>(ControlRotation, FRotator(newRotation.Pitch - yq, newRotation.Yaw, 0)); // 在俯仰角上减去压枪值

                        }
                     
                  }
               }
            }
            
           
            
            
            //绘制点位
            VVV2 rect = Bones_Pos[0];

            
            UIColor *color = [UIColor yellowColor];
            UIColor *AIcolor = [UIColor whiteColor];
            UIFont *font = [UIFont systemFontOfSize:6]; // 根据需要调整字体大小
            
            NSString *text = [NSString stringWithFormat:@"【%.f米】", distance];
            CGSize textSize = [text sizeWithAttributes:@{ NSFontAttributeName: font }];
            CGRect textRect = CGRectMake(rect.X-12, rect.Y+10, textSize.width, textSize.height);
            
            NSString *aiText = @"【AI】";
            CGSize aiTextSize = [aiText sizeWithAttributes:@{ NSFontAttributeName: font }];
            CGRect aiTextRect = CGRectMake(rect.X - 8, rect.Y - 18, aiTextSize.width, aiTextSize.height);
            
            NSString *nameString = [NSString stringWithUTF8String:Name.c_str()];
            NSString *WjText = [NSString stringWithFormat:@"团队:%d %@", Team, nameString];
            CGSize WjTextSize = [WjText sizeWithAttributes:@{ NSFontAttributeName: font }];
            CGRect WjTextRect = CGRectMake(rect.X - 20, rect.Y - 18, WjTextSize.width, WjTextSize.height);
            
            

               if (bIsAI) {
//                  NSLog(@"CosmkzbView1");
                  [CosmkzbView drawSegmentedHealthBarWithCurrentHealth:Health maxHealth:MaxHealth inRect:CGRectMake(rect.X - 15, rect.Y - 10, 30, 5) filledColor:[UIColor whiteColor] emptyColor:[UIColor colorWithWhite:0.8 alpha:0.6]];
                  
                  [CosmkzbView drawText:text inRect:textRect withFont:font color:AIcolor isCentered:YES outline:NO];
                  
                  [CosmkzbView drawText:aiText inRect:aiTextRect withFont:font color:AIcolor isCentered:YES outline:NO];
                  
               } else {
//                  NSLog(@"CosmkzbView2");
                  [CosmkzbView drawSegmentedHealthBarWithCurrentHealth:Health maxHealth:MaxHealth inRect:CGRectMake(rect.X - 15, rect.Y - 10, 30, 5) filledColor:[UIColor yellowColor] emptyColor:[UIColor colorWithWhite:0.8 alpha:0.6]];
                  
                  [CosmkzbView drawText:text inRect:textRect withFont:font color:color isCentered:YES outline:NO];
                  
                  [CosmkzbView drawText:WjText inRect:WjTextRect withFont:font color:color isCentered:YES outline:NO];
                  
                  
               }
               
               
//               [CosmkzbView drawLineFromPoint:CGPointMake(width / 2, 10) toPoint:CGPointMake(rect.X, rect.Y - 10) withColor:HZColos(bIsAI) lineWidth:0.5];
               
               
               [CosmkzbView drawLineFromPoint:CGPointMake(Bones_Pos[1].X, Bones_Pos[1].Y)
                                      toPoint:CGPointMake(Bones_Pos[2].X, Bones_Pos[2].Y)
                                    withColor:HZColos(bIsAI)
                                    lineWidth:0.5];
               
               [CosmkzbView drawLineFromPoint:CGPointMake(Bones_Pos[1].X, Bones_Pos[1].Y)
                                      toPoint:CGPointMake(Bones_Pos[3].X, Bones_Pos[3].Y)
                                    withColor:HZColos(bIsAI)
                                    lineWidth:0.5];
               
               [CosmkzbView drawLineFromPoint:CGPointMake(Bones_Pos[1].X, Bones_Pos[1].Y)
                                      toPoint:CGPointMake(Bones_Pos[4].X, Bones_Pos[4].Y)
                                    withColor:HZColos(bIsAI)
                                    lineWidth:0.5];
               
               [CosmkzbView drawLineFromPoint:CGPointMake(Bones_Pos[3].X, Bones_Pos[3].Y)
                                      toPoint:CGPointMake(Bones_Pos[5].X, Bones_Pos[5].Y)
                                    withColor:HZColos(bIsAI)
                                    lineWidth:0.5];
               
               [CosmkzbView drawLineFromPoint:CGPointMake(Bones_Pos[4].X, Bones_Pos[4].Y)
                                      toPoint:CGPointMake(Bones_Pos[6].X, Bones_Pos[6].Y)
                                    withColor:HZColos(bIsAI)
                                    lineWidth:0.5];
               
               [CosmkzbView drawLineFromPoint:CGPointMake(Bones_Pos[5].X, Bones_Pos[5].Y)
                                      toPoint:CGPointMake(Bones_Pos[7].X, Bones_Pos[7].Y)
                                    withColor:HZColos(bIsAI)
                                    lineWidth:0.5];
               
               [CosmkzbView drawLineFromPoint:CGPointMake(Bones_Pos[6].X, Bones_Pos[6].Y)
                                      toPoint:CGPointMake(Bones_Pos[8].X, Bones_Pos[8].Y)
                                    withColor:HZColos(bIsAI)
                                    lineWidth:0.5];
               

               
               [CosmkzbView drawLineFromPoint:CGPointMake(Bones_Pos[2].X, Bones_Pos[2].Y)
                                      toPoint:CGPointMake(Bones_Pos[9].X, Bones_Pos[9].Y)
                                    withColor:HZColos(bIsAI)
                                    lineWidth:0.5];
               
               [CosmkzbView drawLineFromPoint:CGPointMake(Bones_Pos[2].X, Bones_Pos[2].Y)
                                      toPoint:CGPointMake(Bones_Pos[10].X, Bones_Pos[10].Y)
                                    withColor:HZColos(bIsAI)
                                    lineWidth:0.5];
               
               [CosmkzbView drawLineFromPoint:CGPointMake(Bones_Pos[9].X, Bones_Pos[9].Y)
                                      toPoint:CGPointMake(Bones_Pos[11].X, Bones_Pos[11].Y)
                                    withColor:HZColos(bIsAI)
                                    lineWidth:0.5];
               
               [CosmkzbView drawLineFromPoint:CGPointMake(Bones_Pos[10].X, Bones_Pos[10].Y)
                                      toPoint:CGPointMake(Bones_Pos[12].X, Bones_Pos[12].Y)
                                    withColor:HZColos(bIsAI)
                                    lineWidth:0.5];
               
               [CosmkzbView drawLineFromPoint:CGPointMake(Bones_Pos[11].X, Bones_Pos[11].Y)
                                      toPoint:CGPointMake(Bones_Pos[13].X, Bones_Pos[13].Y)
                                    withColor:HZColos(bIsAI)
                                    lineWidth:0.5];
               
               [CosmkzbView drawLineFromPoint:CGPointMake(Bones_Pos[12].X, Bones_Pos[12].Y)
                                      toPoint:CGPointMake(Bones_Pos[14].X, Bones_Pos[14].Y)
                                    withColor:HZColos(bIsAI)
                                    lineWidth:0.5];
               
             
               
               
               
            
         }
      }
   }
}




static 矩阵 RotatorToMatrix(FRotator rotation) {
   @autoreleasepool {
      float radPitch = rotation.Pitch * ((float) M_PI / 180.0f);
      float radYaw = rotation.Yaw * ((float) M_PI / 180.0f);
      float radRoll = rotation.Roll * ((float) M_PI / 180.0f);
      
      float SP = sinf(radPitch);
      float CP = cosf(radPitch);
      float SY = sinf(radYaw);
      float CY = cosf(radYaw);
      float SR = sinf(radRoll);
      float CR = cosf(radRoll);
      
      矩阵 matrix;
      
      matrix[0][0] = (CP * CY);
      matrix[0][1] = (CP * SY);
      matrix[0][2] = (SP);
      matrix[0][3] = 0;
      
      matrix[1][0] = (SR * SP * CY - CR * SY);
      matrix[1][1] = (SR * SP * SY + CR * CY);
      matrix[1][2] = (-SR * CP);
      matrix[1][3] = 0;
      
      matrix[2][0] = (-(CR * SP * CY + SR * SY));
      matrix[2][1] = (CY * SR - CR * SP * SY);
      matrix[2][2] = (CR * CP);
      matrix[2][3] = 0;
      
      matrix[3][0] = 0;
      matrix[3][1] = 0;
      matrix[3][2] = 0;
      matrix[3][3] = 1;
      
      return matrix;
   }
   
}



static VVV2 世界坐标转屏幕坐标(VV3 worldlocation) {
   tempMatrix = RotatorToMatrix(POV.Rotation);
   
   VV3 vAxisX(tempMatrix[0][0], tempMatrix[0][1], tempMatrix[0][2]);
   VV3 vAxisY(tempMatrix[1][0], tempMatrix[1][1], tempMatrix[1][2]);
   VV3 vAxisZ(tempMatrix[2][0], tempMatrix[2][1], tempMatrix[2][2]);
   VV3 vDelta = worldlocation - POV.Location;
   
   VV3 vTransformed(VV3::Dot(vDelta, vAxisY), VV3::Dot(vDelta, vAxisZ), VV3::Dot(vDelta, vAxisX));
   
   if (vTransformed.Z < 1.0f) {
      vTransformed.Z = 1.f;
   }
   
   float fov = POV.FOV;
   float screenCenterX = width * 0.5f;
   float screenCenterY = height * 0.5f;
   return VVV2(
               (screenCenterX + vTransformed.X * (screenCenterX / tanf(fov * ((float) M_PI / 360.0f))) / vTransformed.Z),
               (screenCenterY - vTransformed.Y * (screenCenterX / tanf(fov * ((float) M_PI / 360.0f))) / vTransformed.Z)
               );
   
}


typedef struct FVector3D {
   float X;
   float Y;
   float Z;
} FVector3D;

typedef struct FVector4D {
   float X;
   float Y;
   float Z;
   float W;
} FVector4D;

typedef struct D3DXMATRIX {
   float _11, _12, _13, _14;
   float _21, _22, _23, _24;
   float _31, _32, _33, _34;
   float _41, _42, _43, _44;
} D3DXMATRIX;


struct FTransform
{
   FVector4D rot;
   FVector3D translation;
   FVector3D scale;
   D3DXMATRIX ToMatrixWithScale()
   {
      D3DXMATRIX m;
      m._41 = translation.X;
      m._42 = translation.Y;
      m._43 = translation.Z;
      
      float X2 = rot.X + rot.X;
      float Y2 = rot.Y + rot.Y;
      float Z2 = rot.Z + rot.Z;
      
      float XX2 = rot.X * X2;
      float YY2 = rot.Y * Y2;
      float ZZ2 = rot.Z * Z2;
      m._11 = (1.0f - (YY2 + ZZ2)) * scale.X;
      m._22 = (1.0f - (XX2 + ZZ2)) * scale.Y;
      m._33 = (1.0f - (XX2 + YY2)) * scale.Z;
      
      float YZ2 = rot.Y * Z2;
      float WX2 = rot.W * X2;
      m._32 = (YZ2 - WX2) * scale.Z;
      m._23 = (YZ2 + WX2) * scale.Y;
      
      float XY2 = rot.X * Y2;
      float WZ2 = rot.W * Z2;
      m._21 = (XY2 - WZ2) * scale.Y;
      m._12 = (XY2 + WZ2) * scale.X;
      
      float XZ2 = rot.X * Z2;
      float WY2 = rot.W * Y2;
      
      m._31 = (XZ2 + WY2) * scale.Z;
      m._13 = (XZ2 - WY2) * scale.X;
      
      m._14 = 0.0f;
      m._24 = 0.0f;
      m._34 = 0.0f;
      m._44 = 1.0f;
      
      return m;
   }
   static D3DXMATRIX MatrixMultiplication(D3DXMATRIX pM1, D3DXMATRIX pM2) {
      
      D3DXMATRIX pOut;
      pOut._11 = pM1._11 * pM2._11 + pM1._12 * pM2._21 + pM1._13 * pM2._31 + pM1._14 * pM2._41;
      pOut._12 = pM1._11 * pM2._12 + pM1._12 * pM2._22 + pM1._13 * pM2._32 + pM1._14 * pM2._42;
      pOut._13 = pM1._11 * pM2._13 + pM1._12 * pM2._23 + pM1._13 * pM2._33 + pM1._14 * pM2._43;
      pOut._14 = pM1._11 * pM2._14 + pM1._12 * pM2._24 + pM1._13 * pM2._34 + pM1._14 * pM2._44;
      pOut._21 = pM1._21 * pM2._11 + pM1._22 * pM2._21 + pM1._23 * pM2._31 + pM1._24 * pM2._41;
      pOut._22 = pM1._21 * pM2._12 + pM1._22 * pM2._22 + pM1._23 * pM2._32 + pM1._24 * pM2._42;
      pOut._23 = pM1._21 * pM2._13 + pM1._22 * pM2._23 + pM1._23 * pM2._33 + pM1._24 * pM2._43;
      pOut._24 = pM1._21 * pM2._14 + pM1._22 * pM2._24 + pM1._23 * pM2._34 + pM1._24 * pM2._44;
      pOut._31 = pM1._31 * pM2._11 + pM1._32 * pM2._21 + pM1._33 * pM2._31 + pM1._34 * pM2._41;
      pOut._32 = pM1._31 * pM2._12 + pM1._32 * pM2._22 + pM1._33 * pM2._32 + pM1._34 * pM2._42;
      pOut._33 = pM1._31 * pM2._13 + pM1._32 * pM2._23 + pM1._33 * pM2._33 + pM1._34 * pM2._43;
      pOut._34 = pM1._31 * pM2._14 + pM1._32 * pM2._24 + pM1._33 * pM2._34 + pM1._34 * pM2._44;
      pOut._41 = pM1._41 * pM2._11 + pM1._42 * pM2._21 + pM1._43 * pM2._31 + pM1._44 * pM2._41;
      pOut._42 = pM1._41 * pM2._12 + pM1._42 * pM2._22 + pM1._43 * pM2._32 + pM1._44 * pM2._42;
      pOut._43 = pM1._41 * pM2._13 + pM1._42 * pM2._23 + pM1._43 * pM2._33 + pM1._44 * pM2._43;
      pOut._44 = pM1._41 * pM2._14 + pM1._42 * pM2._24 + pM1._43 * pM2._34 + pM1._44 * pM2._44;
      
      return pOut;
   }
};
// 读取字符信息
void getUTF8(UTF8 * buf, unsigned long namepy)
{
    UTF16 buf16[16] = { 0 };
    ReadMemory(namepy, buf16, 28);
    UTF16 *pTempUTF16 = buf16;
    UTF8 *pTempUTF8 = buf;
    UTF8 *pUTF8End = pTempUTF8 + 32;
    while (pTempUTF16 < pTempUTF16 + 28)
    {
        if (*pTempUTF16 <= 0x007F && pTempUTF8 + 1 < pUTF8End)
        {
            *pTempUTF8++ = (UTF8) * pTempUTF16;
        }
        else if (*pTempUTF16 >= 0x0080 && *pTempUTF16 <= 0x07FF && pTempUTF8 + 2 < pUTF8End)
        {
            *pTempUTF8++ = (*pTempUTF16 >> 6) | 0xC0;
            *pTempUTF8++ = (*pTempUTF16 & 0x3F) | 0x80;
        }
        else if (*pTempUTF16 >= 0x0800 && *pTempUTF16 <= 0xFFFF && pTempUTF8 + 3 < pUTF8End)
        {
            *pTempUTF8++ = (*pTempUTF16 >> 12) | 0xE0;
            *pTempUTF8++ = ((*pTempUTF16 >> 6) & 0x3F) | 0x80;
            *pTempUTF8++ = (*pTempUTF16 & 0x3F) | 0x80;
        }
        else
        {
            break;
        }
        pTempUTF16++;
    }
}


static bool GetInsideFov(VVV2 PlayerBone, float FovRadius) {
   VVV2 Cenpoint;
   
    Cenpoint.X = PlayerBone.X - width/ 2;
    Cenpoint.Y = PlayerBone.Y - height / 2;
   
    return Cenpoint.X * Cenpoint.X + Cenpoint.Y * Cenpoint.Y <= FovRadius * FovRadius;
}


static int GetCenterOffsetForVector(VVV2 point) {
    return sqrt(pow(point.X - width / 2, 2) + pow(point.Y - height / 2, 2));
}

// 角度范围限制
static FRotator Clamp(FRotator r) {
    // Yaw值的范围调整到[-180, 180]
    if (r.Yaw > 180.f)
        r.Yaw -= 360.f;
    else if (r.Yaw < -180.f)
        r.Yaw += 360.f;
    
    // Pitch值的范围调整到[-180, 180]
    if (r.Pitch > 180.f)
        r.Pitch -= 360.f;
    else if (r.Pitch < -180.f)
        r.Pitch += 360.f;
    
    // Pitch值的范围限制在[-89, 89]
    if (r.Pitch < -89.f)
        r.Pitch = -89.f;
    else if (r.Pitch > 89.f)
        r.Pitch = 89.f;
    
    // Roll值强制设为0
    r.Roll = 0.f;
    
    return r;
}


// 将向量转换为角度值
static FRotator ToRotator(VV3 aimPos, VV3 tatget) {
    VV3 rotation = aimPos - tatget;
    float hyp = sqrt(rotation.X * rotation.X + rotation.Y * rotation.Y);
    
    FRotator newViewAngle = FRotator();
    // 根据旋转量计算Pitch和Yaw
    newViewAngle.Pitch = -atan(rotation.Z / hyp) * (180.f / M_PI);
    newViewAngle.Yaw = atan(rotation.Y / rotation.X) * (180.f / M_PI);
    newViewAngle.Roll = 0.f;
    
    // 根据旋转方向调整Yaw
    if (rotation.X >= 0.f)
        newViewAngle.Yaw += 180.0f;
    
    return newViewAngle;
}



static VV3 GetBoneFTransform(uintptr_t Mesh, const int Id)
{
   uintptr_t BoneActor = DuQu<long>(Mesh + 0x700);
   FTransform lpFTransform =DuQu<FTransform>(BoneActor + Id * 0x30);
   FTransform ComponentToWorld = DuQu<FTransform>(Mesh + 0x210);
   D3DXMATRIX Matrix = FTransform::MatrixMultiplication(lpFTransform.ToMatrixWithScale(), ComponentToWorld.ToMatrixWithScale());
   return VV3(Matrix._41, Matrix._42, Matrix._43);
}



@end
