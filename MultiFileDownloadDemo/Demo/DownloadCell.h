//
//  DownloadCell.h
//  Test
//
//  Created by caven on 2019/3/8.
//  Copyright © 2019 com.caven. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DownloadCell : UITableViewCell

@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign) int percent;  // 进度，直接传int类型，内部进行转换，自动除100

@end

NS_ASSUME_NONNULL_END
