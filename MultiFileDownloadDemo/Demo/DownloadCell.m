//
//  DownloadCell.m
//  Test
//
//  Created by caven on 2019/3/8.
//  Copyright © 2019 com.caven. All rights reserved.
//

#import "DownloadCell.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width

@interface DownloadCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIView *processBGView;

@property (nonatomic, strong) UIView *processView;

@end

@implementation DownloadCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.processBGView];
    [self.processBGView addSubview:self.processView];
}

#pragma mark - Setter
- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (void)setPercent:(int)percent {
    self.processView.frame = CGRectMake(0, 0, self.processBGView.frame.size.width * percent / 100.0, 2);
}

#pragma mark - Getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, ScreenWidth - 20, self.contentView.frame.size.height)];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont systemFontOfSize:15];
    }
    return _titleLabel;
}

- (UIView *)processBGView {
    if (!_processBGView) {
        _processBGView = [[UIView alloc] initWithFrame:CGRectMake(10, self.contentView.frame.size.height - 2, ScreenWidth - 20, 2)];
        _processBGView.backgroundColor = [UIColor colorWithRed:200 / 255.0 green:200 / 255.0 blue:200 / 255.0 alpha:1];
    }
    return _processBGView;
}

- (UIView *)processView {
    if (!_processView) {
        _processView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,0, 2)];
        _processView.backgroundColor = [UIColor redColor];
    }
    return _processView;
}

@end
