//
//  JHCJlnfohpView.m
//  libCJHookDylib
//
//  Created by 李良林 on 2021/3/8.
//

#import "JHCJlnfohpView.h"

@interface JHCJlnfohpView()

@property (strong,  nonatomic) UIView *inView;
@property (assign,  nonatomic) CGFloat width;

@end

@implementation JHCJlnfohpView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self jhSetupViews:frame];
    }
    return self;
}

- (void)jhSetupViews:(CGRect)frame
{
    //
    CGFloat iX = 1;
    CGFloat iY = 1;
    CGFloat iW = frame.size.width - 2*iX;
    CGFloat iH = frame.size.height - 2*iY;
    CGRect iframe = CGRectMake(iX, iY, 0, iH);
    _width = iW;
    
    UIView *inView = [[UIView alloc] init];
    inView.frame = iframe;
    inView.layer.cornerRadius = iH*0.5;
    inView.backgroundColor = [UIColor grayColor];
    [self addSubview:inView];
    _inView = inView;
    
}

- (void)setProgress:(CGFloat)progress
{
    if (progress >= 0 && progress <= 1.0) {
        CGRect frame = _inView.frame;
        frame.size.width = _width * progress;
        _inView.frame = frame;
        
        if (progress <= 0.33) {
            _inView.backgroundColor = [UIColor redColor];
        }else if (progress > 0.33 && progress <= 0.66){
            _inView.backgroundColor = [UIColor orangeColor];
        }else{
            _inView.backgroundColor = [UIColor whiteColor];
        }
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
