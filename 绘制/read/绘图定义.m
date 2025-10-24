#import "绘图定义.h"

@implementation DrawingView {
    NSMutableArray *drawingOperations;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        drawingOperations = [NSMutableArray array];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    // 执行所有绘制操作
    for (void (^drawingBlock)(void) in drawingOperations) {
        drawingBlock();
    }
    
    // 清空绘制操作，以防重复绘制
    [drawingOperations removeAllObjects];
}
// 实现绘制线条的方法
- (void)drawLineFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint withColor:(UIColor *)color lineWidth:(CGFloat)lineWidth {
    [drawingOperations addObject:^{
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (context) {
            CGContextSetStrokeColorWithColor(context, color.CGColor);
            CGContextSetLineWidth(context, lineWidth);
            CGContextMoveToPoint(context, startPoint.x, startPoint.y);
            CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
            CGContextStrokePath(context);
        }
    }];
}
- (void)drawCircleWithCenter:(CGPoint)center
                      radius:(CGFloat)radius
                   thickness:(CGFloat)thickness
                  strokeColor:(UIColor *)strokeColor {
   [drawingOperations addObject:^{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 设置线宽
    CGContextSetLineWidth(context, thickness);
    
    // 设置颜色
    CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
    
    // 添加一个圆形路径
    CGContextAddArc(context, center.x, center.y, radius, 0, 2 * M_PI, 0);
    
    // 绘制路径
    CGContextStrokePath(context);
   }];
}
// 实现绘制圆圈的方法
- (void)drawCircleInRect:(CGRect)rect withColor:(UIColor *)color lineWidth:(CGFloat)lineWidth {
    [drawingOperations addObject:^{
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetStrokeColorWithColor(context, color.CGColor);
        CGContextSetLineWidth(context, lineWidth);
        CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
        CGFloat radius = MIN(CGRectGetWidth(rect), CGRectGetHeight(rect)) / 2.0 - lineWidth;
        CGContextAddArc(context, center.x, center.y, radius, 0, 2 * M_PI, 0);
        CGContextStrokePath(context);
    }];
}

// 实现绘制文本的方法
- (void)drawText:(NSString *)text inRect:(CGRect)rect withFont:(UIFont *)font color:(UIColor *)color isCentered:(BOOL)isCentered outline:(BOOL)outline {
    [drawingOperations addObject:^{
        CGRect mutableRect = rect;
        NSDictionary *attributes = @{ NSFontAttributeName: font, NSForegroundColorAttributeName: color };

        // 如果需要居中，调整文本框的位置
        if (isCentered) {
            CGSize textSize = [text sizeWithAttributes:attributes];
            mutableRect.origin.x += (CGRectGetWidth(mutableRect) - textSize.width) / 2.0;
            mutableRect.origin.y += (CGRectGetHeight(mutableRect) - textSize.height) / 2.0;
        }

        // 如果需要绘制轮廓，将颜色设置为白色
        if (outline) {
            NSDictionary *outlineAttributes = @{ NSFontAttributeName: font, NSForegroundColorAttributeName: [UIColor blackColor] };
            CGSize offsets[] = { {1, 1}, {-1, -1}, {1, -1}, {-1, 1} };

            for (int i = 0; i < 4; i++) {
                CGRect offsetRect = CGRectOffset(mutableRect, offsets[i].width, offsets[i].height);
                [text drawInRect:offsetRect withAttributes:outlineAttributes];
            }
        }

        // 绘制文本
        [text drawInRect:mutableRect withAttributes:attributes];
    }];
}



// 实现分段血条绘制的方法，颜色作为参数传入
- (void)drawSegmentedHealthBarWithCurrentHealth:(float)health
                                      maxHealth:(float)maxHealth
                                         inRect:(CGRect)rect
                                    filledColor:(UIColor *)filledColor
                                    emptyColor:(UIColor *)emptyColor {
    [drawingOperations addObject:^{
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (!context) return;

        // 定义血条参数
        float healthPercentage = health / maxHealth;  // 计算血量百分比
        float totalWidth = rect.size.width;  // 整个血条的总宽度
        float filledWidth = totalWidth * healthPercentage;  // 当前血量对应的填充宽度
        CGFloat cornerRadius = 1.0;  // 圆角半径

        // 绘制填充部分
        CGRect filledRect = CGRectMake(rect.origin.x, rect.origin.y, filledWidth, rect.size.height);
        UIBezierPath *filledPath = [UIBezierPath bezierPathWithRoundedRect:filledRect cornerRadius:cornerRadius];
        CGContextSetFillColorWithColor(context, filledColor.CGColor);
        [filledPath fill];

        // 绘制未填充部分
        if (filledWidth < totalWidth) {
            CGRect emptyRect = CGRectMake(rect.origin.x + filledWidth, rect.origin.y, totalWidth - filledWidth, rect.size.height);
            UIBezierPath *emptyPath = [UIBezierPath bezierPathWithRoundedRect:emptyRect cornerRadius:cornerRadius];
            CGContextSetFillColorWithColor(context, emptyColor.CGColor);
            [emptyPath fill];
        }

        // 绘制外部边框
        UIColor *borderColor = [UIColor blackColor];
        CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
        CGContextSetLineWidth(context, 1.0);
        UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
        [borderPath stroke];
    }];
}



//四角方框
- (void)drawUnclosedRectWithCenterX:(float)centerX
                           centerY:(float)centerY
                           centerW:(float)centerW
                           centerH:(float)centerH
                             color:(UIColor *)color
                         thickness:(float)thickness {
   
    // 左上横线
    [self drawLineFromPoint:CGPointMake(centerX - (centerW / 2), centerY - (centerH / 2))
                   toPoint:CGPointMake(centerX - (centerW / 4), centerY - (centerH / 2))
                  withColor:color
                  lineWidth:thickness];
    
    // 右上横线
    [self drawLineFromPoint:CGPointMake(centerX + (centerW / 2), centerY - (centerH / 2))
                   toPoint:CGPointMake(centerX + (centerW / 4), centerY - (centerH / 2))
                  withColor:color
                  lineWidth:thickness];
    
    // 左下横线
    [self drawLineFromPoint:CGPointMake(centerX - (centerW / 2), centerY + (centerH / 2))
                   toPoint:CGPointMake(centerX - (centerW / 4), centerY + (centerH / 2))
                  withColor:color
                  lineWidth:thickness];
    
    // 右下横线
    [self drawLineFromPoint:CGPointMake(centerX + (centerW / 2), centerY + (centerH / 2))
                   toPoint:CGPointMake(centerX + (centerW / 4), centerY + (centerH / 2))
                  withColor:color
                  lineWidth:thickness];
    
    // 左上竖线
    [self drawLineFromPoint:CGPointMake(centerX - (centerW / 2), centerY - (centerH / 2))
                   toPoint:CGPointMake(centerX - (centerW / 2), centerY - (centerH / 4))
                  withColor:color
                  lineWidth:thickness];
    
    // 右上竖线
    [self drawLineFromPoint:CGPointMake(centerX + (centerW / 2), centerY - (centerH / 2))
                   toPoint:CGPointMake(centerX + (centerW / 2), centerY - (centerH / 4))
                  withColor:color
                  lineWidth:thickness];
    
    // 左下竖线
    [self drawLineFromPoint:CGPointMake(centerX - (centerW / 2), centerY + (centerH / 2))
                   toPoint:CGPointMake(centerX - (centerW / 2), centerY + (centerH / 4))
                  withColor:color
                  lineWidth:thickness];
    
    // 右下竖线
    [self drawLineFromPoint:CGPointMake(centerX + (centerW / 2), centerY + (centerH / 2))
                   toPoint:CGPointMake(centerX + (centerW / 2), centerY + (centerH / 4))
                  withColor:color
                  lineWidth:thickness];

}



@end
