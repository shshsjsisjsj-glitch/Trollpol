#import "MGPGLabel.h"



@implementation MGPGLabel

- (void)drawTextInRect:(CGRect)rect {
    if (_borderWidth > 0) {
        CGSize shadowOffset = self.shadowOffset;
        UIColor *textColor = self.textColor;
        
        CGContextRef ref = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(ref, _borderWidth);
        CGContextSetLineJoin(ref, kCGLineJoinRound);
        
        CGContextSetTextDrawingMode(ref, kCGTextStroke);
        self.textColor = _borderColor;
        [super drawTextInRect:rect];
        
        CGContextSetTextDrawingMode(ref, kCGTextFill);
        self.textColor = textColor;
        self.shadowOffset = CGSizeMake(0, 0);
        [super drawTextInRect:rect];
        
        self.shadowOffset = shadowOffset;
    }
    
    [super drawTextInRect:rect];
}
@end

