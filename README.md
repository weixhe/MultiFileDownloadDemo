# MultiFileDownloadDemo

这里只是做了一个上传和下载多文件的 demo，文件上传和下载需要在异步线程中处理，并且，下载和上传的过程同样也是异步，在任务结束后回调通知主线程任务完成。

方法一：
GCD：使用GCD中的`group`分组，将异步下载任务放在 group 中，通过信号量`semaphore`，等待信号和发射信号控制异步下载和上传的结束（成功或失败），最后`group`中的所有任务全部结束后，进行通知`group_notify`
主要代码：
```
dispatch_group_async(self.groupGCD, self.queueGCD, ^{
        dispatch_queue_t qt = dispatch_queue_create("queue_qt", DISPATCH_QUEUE_CONCURRENT);
        dispatch_async(qt, ^{
            for (int i = 0; i < 150; i+=8) {
                sleep(1);
                if (i >= 100) { i = 100; }
                if (i == 100) {
                    dispatch_semaphore_signal(self.sema);
                    return ;
                }
            }
        });
        dispatch_semaphore_wait(self.sema, DISPATCH_TIME_FOREVER);
    });
    
    dispatch_group_notify(self.groupGCD, self.queueGCD, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [ProgressHUD show];
        });
    });
```

另：在GCD的group中使用`dispatch_group_enter()    dispatch_group_leave()` 也能达到semaphore的效果

方法二：
NSOperationQueue & NSOperation
自定义子类，继承 `NSOperation` ，实现`main`方法，在 main 方法中实现上传和下载的任务，一定要重写`finished`和`executing`的 setter 方法，实现 KVO 监听，只有实现了这两个监听，队列 queue 才能监听到任务的进度是否完成，从而将完成或取消的任务移除队列 queue，最终监听 queue 的 `operationCount` 属性或者 `operations.count` 属性，当 count == 0 时，即所有的任务结束。

```
@property (assign, nonatomic, getter = isFinished) BOOL finished;
@property (assign, nonatomic, getter = isExecuting) BOOL executing;

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
```

重写 main 方法：
```
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
```
