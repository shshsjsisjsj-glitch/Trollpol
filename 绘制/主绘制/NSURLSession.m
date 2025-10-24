#import <Foundation/Foundation.h>

@interface CustomURLProtocol : NSURLProtocol

@end

@implementation CustomURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    NSArray<NSString *> *targetURLs = @[
        @"https://down.anticheatexpert.com/iedsafe/Client/ios/2131/F4C7AF04/comm.zip",
        @"https://down.anticheatexpert.com/iedsafe/Client/ios/2131/4F203300/ob_x.zip",
        @"https://down.anticheatexpert.com/iedsafe/Client/ios/2131/CC48C632/mrpcs.dat",
        @"https://down.anticheatexpert.com/iedsafe/Client/ios/2131/config2.xml"
    ];


        if ([targetURLs containsObject:request.URL.absoluteString]) {
          
           NSLog(@"打印 拦截到URL:%@",request.URL);
        }
    

    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    // 在这里可以修改请求，返回自定义数据等
    // 例如，可以使用NSURLSession发起一个新的请求

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:self.request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // 处理响应数据
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [self.client URLProtocol:self didLoadData:data];
        [self.client URLProtocolDidFinishLoading:self];
    }];
    [task resume];
}

- (void)stopLoading {
    // 在这里停止加载
}

+ (void)load {
   NSLog(@"打印3 开始加载");
 [NSURLProtocol registerClass:[CustomURLProtocol class]];

}

@end
