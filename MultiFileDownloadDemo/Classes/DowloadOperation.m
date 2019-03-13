//
//  UploadOperation.m
//  Test
//
//  Created by caven on 2019/3/8.
//  Copyright © 2019 com.caven. All rights reserved.
//

#import "DowloadOperation.h"

@interface DowloadOperation ()

@property (nonatomic, copy) NSString *url;

@property (assign, nonatomic, getter = isFinished) BOOL finished;

@property (assign, nonatomic, getter = isExecuting) BOOL executing;

@end


@implementation DowloadOperation
@synthesize finished = _finished, executing = _executing;

- (instancetype)initWithUrl:(NSString *)url {
    if (self = [super init]) {
        self.url = url;
    }
    return self;
}

- (void)start {
    if (self.isCancelled) {
        return;
    }
    
    [self main];
}


- (void)main {
    
    if (self.isCancelled) {
        return;
    }
    
    self.executing = YES;
    self.finished = NO;
    NSLog(@"开启任务线程%@ ---- 异步线程 %@", self.url, [NSThread currentThread]);
    // 模拟异步上传图片的过程
    @autoreleasepool {
        
        dispatch_queue_t queue = dispatch_queue_create("asdf", DISPATCH_QUEUE_CONCURRENT);
        dispatch_async(queue, ^{
            NSLog(@"异步下载任务%@ ---- 异步线程 %@", self.url, [NSThread currentThread]);
            for (int i = 0; i < 150; i+=8) {
                sleep(1);
                if (i >= 100) { i = 100; }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.delegate && [self.delegate respondsToSelector:@selector(dowloadPercent:url:)]) {
                        [self.delegate dowloadPercent:i url:self.url];
                    }
                });
                if (i == 100) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        self.executing = NO;
                        self.finished = YES;
                        if (self.delegate && [self.delegate respondsToSelector:@selector(dowloadFinish:)]) {
                            [self.delegate dowloadFinish:self.url];
                        }
                    });
                    return ;
                }
            }
        });
    }

}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

#pragma mark - Actions
- (void)onChangePercent:(NSNumber *)percent {
    [self.delegate dowloadPercent:percent.intValue url:self.url];
}

- (void)onDownloadFinished {
     [self.delegate dowloadFinish:self.url];
}

@end
