
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#include "utf.h"


#ifndef JHCJInfoModel_h
#define JHCJInfoModel_h

#include <arm_neon.h>

typedef struct Vector{
    float X;
    float Y;
    float Z;
}Vector;


#endif /* JHCJTypeHeader_h */

NS_ASSUME_NONNULL_BEGIN

@interface JHCJInfoModel : NSObject
/// 距离
@property (nonatomic,  assign) CGFloat  distance;
/// 方框
@property (nonatomic,  assign) CGRect  rect;

@property (nonatomic,  assign) NSInteger flag;


@end


NS_ASSUME_NONNULL_END
