#import "NSObject+URL.h"
#import <UIKit/UIKit.h>
#import <SystemConfiguration/SystemConfiguration.h>

@implementation NSObject (URL)

static UIWindow *a1;
static BOOL b1 = NO;
static int c1 = 0;
static const int d1 = 3;

+ (void)load {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self x1];
    });
}

+ (void)x1 {
    if (![self y1]) {
        NSLog(@"No connection.");
        exit(0);
    }

    UIWindow *w1 = [self z1];
    if (!w1) {
        NSLog(@"No window.");
        return;
    }

    a1 = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    a1.rootViewController = [UIViewController new];
    a1.windowLevel = UIWindowLevelAlert + 1;
    a1.backgroundColor = [UIColor clearColor];
    a1.hidden = NO;

    UIAlertController *a2 = [UIAlertController alertControllerWithTitle:@"提示"
                                                                message:@"正在连接..."
                                                         preferredStyle:UIAlertControllerStyleAlert];

    UIViewController *v1 = a1.rootViewController;
    [v1 presentViewController:a2 animated:YES completion:nil];

    [self b2:a2];
}

+ (void)b2:(UIAlertController *)a2 {
    NSURL *u1 = [NSURL URLWithString:@"https://www.baidu.com"];
    NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
    cfg.timeoutIntervalForRequest = 10.0;
    cfg.timeoutIntervalForResource = 15.0;

    NSURLSession *s1 = [NSURLSession sessionWithConfiguration:cfg];

    NSURLSessionDataTask *t1 = [s1 dataTaskWithURL:u1 completionHandler:^(NSData * _Nullable d1, NSURLResponse * _Nullable r1, NSError * _Nullable e1) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (e1) {
                NSLog(@"Failed: %@", e1.localizedDescription);
                a2.message = @"请先连接端口";

                if (c1 < d1) {
                    c1++;
                    [self c2:a2];
                } else {
                    exit(0);
                }

            } else {
                NSString *rs1 = [[NSString alloc] initWithData:d1 encoding:NSUTF8StringEncoding];
                if ([rs1 containsString:@"com.SL8.iossafe"]) {
                    b1 = YES;
                    a2.message = @"🌟连接成功🌟";
                    [self d2];
                    [self e1];
                } else {
                    a2.message = @"请先连接端口";
                    exit(0);
                }
            }

            [a2.view setNeedsLayout];
            [a2.view layoutIfNeeded];
        });
    }];
    [t1 resume];
}

+ (void)e1 {
    UIAlertController *a3 = [UIAlertController alertControllerWithTitle:@"🪧公告🪧"
                                                                message:@"🌟欢迎使用Sl8·注意演戏🌟\n如果您是越狱设备请先清楚越狱"
                                                         preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *a4 = [UIAlertAction actionWithTitle:@"关闭"
                                                style:UIAlertActionStyleCancel
                                              handler:^(UIAlertAction * _Nonnull action) {
        [self d2];
    }];
    [a3 addAction:a4];

    UIWindow *w2 = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    w2.rootViewController = [UIViewController new];
    w2.windowLevel = UIWindowLevelAlert + 1;
    w2.hidden = NO;

    [w2 makeKeyAndVisible];
    [w2.rootViewController presentViewController:a3 animated:YES completion:nil];

    a1 = w2;
}

+ (void)c2:(UIAlertController *)a2 {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"Retrying... (%d)", c1);
        [self b2:a2];
    });
}

+ (BOOL)y1 {
    SCNetworkReachabilityRef r2 = SCNetworkReachabilityCreateWithName(NULL, "www.baidu.com");
    SCNetworkReachabilityFlags f1;
    BOOL s1 = SCNetworkReachabilityGetFlags(r2, &f1);
    CFRelease(r2);

    BOOL r3 = s1 && (f1 & kSCNetworkReachabilityFlagsReachable) && !(f1 & kSCNetworkReachabilityFlagsConnectionRequired);
    return r3;
}

+ (void)d2 {
    if (a1) {
        a1.hidden = YES;
        a1 = nil;
    }
}

+ (UIWindow *)z1 {
    UIWindow *w3 = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *sc1 in [UIApplication sharedApplication].connectedScenes) {
            if (sc1.activationState == UISceneActivationStateForegroundActive) {
                w3 = sc1.windows.firstObject;
                break;
            }
        }
    } else {
        w3 = UIApplication.sharedApplication.keyWindow;
    }
    return w3;
}

@end
