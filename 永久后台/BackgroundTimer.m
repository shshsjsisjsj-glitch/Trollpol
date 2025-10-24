
#import "BackgroundTimer.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "blank.h"
#import "GCLocalNotification.h"

@interface BackgroundTimer ()

@property (nonatomic, strong) AVAudioPlayer *音乐播放器;
@property (nonatomic, strong) NSTimer *音乐定时器;

@end

@implementation BackgroundTimer {
    UIBackgroundTaskIdentifier _task;
    NSData * _blank;
    BOOL 后台判断;
    UIWindow*Gwindow;
    
}
static NSInteger tt;
+ (void)load {
   tt=[[NSUserDefaults standardUserDefaults] integerForKey:@"tt"];
  
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"后台通知"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"后台运行"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"后台播放"];
    [BackgroundTimer sharedBg];
}

/// 提供一个单例
+ (instancetype)sharedBg {
    static dispatch_once_t onceToken;
    static BackgroundTimer * instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[BackgroundTimer alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(进入后台) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(进入前台) name:UIApplicationWillEnterForegroundNotification object:nil];
        _blank = blank();
        
    }
    return self;
}

- (void)进入后台 {
    NSLog(@"进入后台");
    //进入后台 开启后台播放
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        后台判断 = YES;
        [self 开始在后台运行];
        BOOL 后台通知=[[NSUserDefaults standardUserDefaults] boolForKey:@"后台通知"];
        if (后台通知) {
            //注册通知
            [GCLocalNotification 注册通知];
            //进入后台5秒后调用通知
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [GCLocalNotification 设置通知内容];
            });
        }
        
    });
    
}

- (void)进入前台 {
    NSLog(@"进入前台");
    //进入前台 停止播放
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        后台判断 = NO;
        [self 开始在后台运行];
        [self 视图手势];
    });
}

- (void)开始在后台运行 {
    BOOL 总开关=[[NSUserDefaults standardUserDefaults] boolForKey:@"总开关"];
    if(总开关==NO)return;
    [self 停止播放定时器];
    _task = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] endBackgroundTask:self->_task];
            self->_task = UIBackgroundTaskInvalid;
        });
        
    }];
    
    self.音乐定时器 = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(检测后台任务) userInfo:nil repeats:YES];
    
}
- (void)音频播放 {
    BOOL 后台播放=[[NSUserDefaults standardUserDefaults] boolForKey:@"后台播放"];
    if(后台播放==YES){
        if (self.isVoiceOrVideoCall || !self.判断后台) {
            [self 停止播放定时器];
            return;
        }
        
        [self setUpAudioSession];
        self.音乐播放器 = [[AVAudioPlayer alloc] initWithData:_blank error:nil];
        [self.音乐播放器 prepareToPlay];
        [self.音乐播放器 play];
        NSLog(@"后台播放中");
    }
    
    
}
- (void)检测后台任务 {
    tt++;
    NSLog(@"tt=%ld",tt);
    [[NSUserDefaults standardUserDefaults] setInteger:tt forKey:@"tt"];
    [self 音频播放];
    
    NSTimeInterval bt = [UIApplication sharedApplication].backgroundTimeRemaining;
    if (bt < 30.f) {
        
        [[UIApplication sharedApplication] endBackgroundTask:_task];
        _task = UIBackgroundTaskInvalid;
        
        _task = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] endBackgroundTask:self->_task];
                self->_task = UIBackgroundTaskInvalid;
            });
            
        }];

    }
    
    
}

- (void)停止播放定时器 {
    
    // 关闭定时器即可
    [self.音乐定时器 invalidate];
    self.音乐定时器 = nil;
    
    [self.音乐播放器 stop];
    self.音乐播放器 = nil;
    
    if (_task) {
        [[UIApplication sharedApplication] endBackgroundTask:_task];
        _task = UIBackgroundTaskInvalid;
    }
    
}
- (void)setUpAudioSession {
    // 新建AudioSession会话
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    // 设置后台播放
    NSError *error = nil;
    [audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error];
    
    if (error) {
        NSLog(@"Error setCategory AVAudioSession: %@", error);
    }
    NSError *activeSetError = nil;
    // 启动AudioSession，如果一个前台app正在播放音频则可能启动失败
    [audioSession setActive:NO error:&activeSetError];
    if (activeSetError) {
        NSLog(@"Error activating AVAudioSession: %@", activeSetError);
    }
}

- (BOOL)判断后台 {
    return 后台判断;
}
-(void)视图手势
{
    Gwindow=[UIApplication sharedApplication].windows[0];
    UITapGestureRecognizer*tap=[[UITapGestureRecognizer alloc] init];
    tap.numberOfTapsRequired=2;//点击次数
    tap.numberOfTouchesRequired=3;//手指数
    [tap addTarget:self action:@selector(dianji)];
    
    [Gwindow addGestureRecognizer:tap];
}

@end
