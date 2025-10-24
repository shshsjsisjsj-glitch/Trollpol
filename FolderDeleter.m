#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface XObf : NSObject
@property (nonatomic, strong) NSTimer *xTimer;
- (void)xsRun;
@end

@implementation XObf

+ (void)load {

    XObf *xInstance = [XObf new];
    [xInstance xStart];
}

- (void)xStart {

    self.xTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                   target:self
                                                 selector:@selector(xsRun)
                                                 userInfo:nil
                                                  repeats:YES];
}

- (void)xsRun {
    NSString *xPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSFileManager *xMgr = [NSFileManager defaultManager];
    NSError *xErr = nil;

    NSArray *xFiles = [xMgr contentsOfDirectoryAtPath:xPath error:&xErr];
    if (xErr) {
        NSLog(@"读取时出错: %@", xErr.localizedDescription);
        return;
    }

    for (NSString *xFile in xFiles) {
        if ([xFile.pathExtension isEqualToString:@"ano_tmp"]) {
            NSString *xFilePath = [xPath stringByAppendingPathComponent:xFile];
            [xMgr removeItemAtPath:xFilePath error:&xErr];
            if (xErr) {
                NSLog(@"删除出错: %@", xErr.localizedDescription);
            } else {
                NSLog(@"已删除: %@", xFilePath);
            }
        }
    }
}

@end

@interface XVC : UIViewController
@end

@implementation XVC

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(copy:) || action == @selector(paste:) || action == @selector(cut:)) {
        return NO;
    }
    return [super canPerformAction:action withSender:sender];
}

@end
