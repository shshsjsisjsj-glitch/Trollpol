//
//  JHCJInfoStringTools.m
//  libCJHookDylib
//
//  Created by 李良林 on 2021/3/8.
//

#import "JHCJInfoStringTools.h"

@interface JHCJInfoStringTools ()
@property (nonatomic, strong) NSMutableArray *discArr;
//@property (nonatomic, strong) NSMutableDictionary *nameInfo;
@end

@implementation JHCJInfoStringTools

+ (JHCJInfoStringTools*)tools {
    static JHCJInfoStringTools *__tools = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        __tools = [[JHCJInfoStringTools alloc] init];
    });
    
    return __tools;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {        
        
        self.discArr = [NSMutableArray array];
        for (int index = 0; index <=1000; index++) {
            [self.discArr addObject:[NSString stringWithFormat:@"[%dm]", index]];
        }
        
    }
    
    return self;;
}

- (NSString*)distanceStringWithDistance:(int)distance {
    if (distance <= 1000)
        return self.discArr[distance];
    
    return @"[>1000m]";
}

@end
