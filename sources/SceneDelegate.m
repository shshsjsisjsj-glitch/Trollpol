//
//  SceneDelegate.m
//  UItable
//
//  Created by yanyan on 2023/2/28.
//

#import "SceneDelegate.h"
#import "RootViewController.h"

@interface SceneDelegate ()

//在线更新
@property (nonatomic, strong) NSString *currentVersion;
@property (nonatomic, strong) NSString *latestVersion;
@property (nonatomic, strong) NSString *updateURL;
@property (nonatomic, strong) NSString *updateMessage;

@end

@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {

    // 设置当前应用的版本号（您需要自己获取并设置此值）
    self.currentVersion = @"2.2.3";
    
  
    self.window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
       self.window.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    self.window.backgroundColor =[UIColor whiteColor];
       [self.window makeKeyAndVisible];
       
    RootViewController* vcFirst=[[RootViewController alloc]init];
       vcFirst.view.backgroundColor=[UIColor whiteColor];
       
       
   RootViewController* vcSecond=[[RootViewController alloc]init];
    vcSecond.view.backgroundColor=[UIColor whiteColor];
    
 
       vcFirst.title=@"首页";
    vcFirst.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"首页" image:[UIImage systemImageNamed:@"house.circle"] selectedImage:[UIImage systemImageNamed:@"house.circle.fill"]];
    
       vcSecond.title=@"工具";
    vcSecond.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"工具" image:[UIImage systemImageNamed:@"hammer.circle"] selectedImage:[UIImage systemImageNamed:@"hammer.circle.fill"]];
    
     
   //    创建试图控制器
       UITabBarController* tbController=[[UITabBarController alloc]init];
   //    创建视图控制器数组
   //    将所有分栏控制器加到数组中
       NSArray* arrayVC=[NSArray arrayWithObjects:vcFirst,vcSecond,nil];
   //    将分栏控制器管理数组赋值
       tbController.viewControllers=arrayVC;
   //    将分栏控制器为根视图控制器
       self.window.rootViewController=tbController;
   //    设置选中视图控制器的索引
       tbController.selectedIndex=0;
       
   //    设置透明度
       tbController.tabBar.translucent=NO;
}


@end
