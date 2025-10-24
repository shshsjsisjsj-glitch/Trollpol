//
//  China Hacker 烟雨
//  XIOLI  QQ 151384204
//  Created by 烟雨 on 2023/12/29
//

#import "NSURL+hook.h"
#import <objc/runtime.h>

@implementation NSURL (hook)

+(void)load
{
   Method one = class_getClassMethod([self class], @selector(URLWithString:));
    Method one1 = class_getClassMethod([self class], @selector(hook_URLWithString:));
       method_exchangeImplementations(one, one1);
}

+(instancetype)hook_URLWithString:(NSString *)Str
{
    if ([Str containsString:@"https://down.anticheatexpert.com/iedsafe/Client/ios/2131/F4C7AF04/comm.zip"]) {
         return [NSURL hook_URLWithString:@""];
       
         }
    if ([Str containsString:@"https://down.anticheatexpert.com/iedsafe/Client/ios/2131/4F203300/ob_x.zip"]) {
         return [NSURL hook_URLWithString:@""];
       
         }
    if ([Str containsString:@"https://down.anticheatexpert.com/iedsafe/Client/ios/2131/CC48C632/mrpcs.data"]) {
         return [NSURL hook_URLWithString:@""];
       
         }
    if ([Str containsString:@"https://down.anticheatexpert.com/iedsafe/Client/ios/2131/config2.xml"]) {
         return [NSURL hook_URLWithString:@""];
       
         }

       
            return [NSURL hook_URLWithString:Str];
      

}

@end






