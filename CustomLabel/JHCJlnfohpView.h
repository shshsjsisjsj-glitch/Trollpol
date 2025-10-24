//
//  JHCJlnfohpView.h
//  libCJHookDylib
//
//  Created by 李良林 on 2021/3/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JHCJlnfohpView : UIView

@property (assign,  nonatomic) CGFloat   progress;  /**< value:0.0~1.0 */

- (instancetype)initWithFrame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
