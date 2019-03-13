//
//  ProgressHUD.m
//  Test
//
//  Created by caven on 2019/3/12.
//  Copyright © 2019 com.caven. All rights reserved.
//

#import "ProgressHUD.h"
#import "AppDelegate.h"

@interface ProgressHUD ()

@end

@implementation ProgressHUD

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        [self setup];
    }
    return self;
}

- (void)setup {
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 90, 60)];
    tipLabel.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height / 2);
    tipLabel.text = @"下载完成";
    tipLabel.font = [UIFont systemFontOfSize:14];
    tipLabel.textColor = [UIColor whiteColor];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.9];
    tipLabel.layer.cornerRadius = 10;
    tipLabel.layer.masksToBounds = YES;
    [self addSubview:tipLabel];
}

+ (void)show {
    for (UIView *view in [[UIApplication sharedApplication].keyWindow subviews]) {
        if (view.tag == 1001) {
            [view removeFromSuperview];
            break;
        }
    }
    ProgressHUD *hud = [[ProgressHUD alloc] init];
    hud.tag = 1001;
    [[UIApplication sharedApplication].keyWindow addSubview:hud];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            hud.alpha = 0;
        } completion:^(BOOL finished) {
            [hud removeFromSuperview];
        }];
    });
}

@end
