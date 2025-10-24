//
//  绘图定义.h
//  THOR-HUD
//
//  Created by Cosmkz on 2024/8/25.
//

#import <UIKit/UIKit.h>

@interface DrawingView : UIView

// 声明绘制线条的方法
- (void)drawLineFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint withColor:(UIColor *)color lineWidth:(CGFloat)lineWidth;

// 声明绘制圆圈的方法
- (void)drawCircleInRect:(CGRect)rect withColor:(UIColor *)color lineWidth:(CGFloat)lineWidth;

// 声明绘制文本的方法
- (void)drawText:(NSString *)text inRect:(CGRect)rect withFont:(UIFont *)font color:(UIColor *)color isCentered:(BOOL)isCentered outline:(BOOL)outline;

//声明绘制血条的方法
- (void)drawSegmentedHealthBarWithCurrentHealth:(float)health maxHealth:(float)maxHealth inRect:(CGRect)rect filledColor:(UIColor *)filledColor emptyColor:(UIColor *)emptyColor;


- (void)drawUnclosedRectWithCenterX:(float)centerX centerY:(float)centerY centerW:(float)centerW centerH:(float)centerH color:(UIColor *)color thickness:(float)thickness;


- (void)drawCircleWithCenter:(CGPoint)center
                      radius:(CGFloat)radius
                   thickness:(CGFloat)thickness
                 strokeColor:(UIColor *)strokeColor;
@end
