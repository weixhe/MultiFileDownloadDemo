//
//  UploadOperation.h
//  Test
//
//  Created by caven on 2019/3/8.
//  Copyright © 2019 com.caven. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol DowloadOperationDelegate;
@interface DowloadOperation : NSOperation

@property (nonatomic, weak) id <DowloadOperationDelegate> delegate;

- (instancetype)initWithUrl:(NSString *)url;

@end

@protocol DowloadOperationDelegate <NSObject>

- (void)dowloadPercent:(int)percent url:(NSString *)url;

- (void)dowloadFinish:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
