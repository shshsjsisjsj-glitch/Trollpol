

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BackgroundTimer : NSObject

@property (nonatomic, assign) BOOL isVoiceOrVideoCall;

+ (instancetype)sharedBg;
// 调用此方法后，程序进入后台也不会死掉
- (void)开始在后台运行;
@end

NS_ASSUME_NONNULL_END
