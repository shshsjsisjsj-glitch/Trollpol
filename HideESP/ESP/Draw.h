//
//  JHCJDrawView.h
//  JHCJDraw
//
//  Created by 佚名 on 2021/1/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface 绘图吧 : UIView

+ (instancetype)cjDrawView;

- (void)show;
- (void)hide;


@end

NS_ASSUME_NONNULL_END

//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        ViewController *view = [ViewController initWithNibName];
//        [view show];
//        [[[[UIApplication sharedApplication] windows]lastObject] addSubview:view];
//    });
//- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil

