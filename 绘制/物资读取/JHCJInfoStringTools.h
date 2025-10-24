//
//  JHCJInfoStringTools.h
//  libCJHookDylib
//
//  Created by 李良林 on 2021/3/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JHCJInfoStringTools : NSObject

+ (JHCJInfoStringTools*)tools;
- (NSString*)distanceStringWithDistance:(int)distance;

@end

NS_ASSUME_NONNULL_END
