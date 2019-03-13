//
//  ViewController.m
//  MultiFileDownloadDemo
//
//  Created by caven on 2019/3/13.
//  Copyright © 2019 com.caven. All rights reserved.
//

#import "ViewController.h"
#import "DowloadOperation.h"
#import "DownloadCell.h"
#import "ProgressHUD.h"

@interface ViewController () <DowloadOperationDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSOperationQueue *queue;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UIButton *addBtn;
@property (nonatomic, strong) UIButton *addBtn2;

@property (nonatomic, assign) int taskKey;

@property (nonatomic, strong) dispatch_queue_t queueGCD;
@property (nonatomic, strong) dispatch_group_t groupGCD;
@property (nonatomic, strong) dispatch_semaphore_t sema;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.addBtn];
    [self.view addSubview:self.addBtn2];
    
    self.queue = [[NSOperationQueue alloc] init];
    self.queue.maxConcurrentOperationCount = 3;
    self.dataSource = [NSMutableArray array];
    
    // GCD
    self.queueGCD = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
    self.groupGCD = dispatch_group_create();
    self.sema = dispatch_semaphore_create(0);
}

#pragma mark - Actions
- (void)onClickAddBtn {
    self.addBtn2.enabled = NO;
    self.taskKey++;
    NSString *key = [NSString stringWithFormat:@"weixhe://image-%d", self.taskKey];
    [self.dataSource addObject:@{@"key":key, @"value":@(0)}];
    [self.tableView reloadData];
    
    DowloadOperation *op = [[DowloadOperation alloc] initWithUrl:key];
    op.delegate = self;
    [self.queue addOperation:op];
}

- (void)onClickAddBtnGCD {
    self.addBtn.enabled = NO;
    self.taskKey++;
    NSString *key = [NSString stringWithFormat:@"weixhe://image-%d", self.taskKey];
    [self.dataSource addObject:@{@"key":key, @"value":@(0)}];
    [self.tableView reloadData];
    
    dispatch_group_async(self.groupGCD, self.queueGCD, ^{
        dispatch_queue_t qt = dispatch_queue_create("queue_qt", DISPATCH_QUEUE_CONCURRENT);
        dispatch_async(qt, ^{
            for (int i = 0; i < 150; i+=8) {
                sleep(1);
                if (i >= 100) { i = 100; }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self dowloadPercent:i url:key];
                });
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
}

#pragma mark - DowloadOperationDelegate
- (void)dowloadPercent:(int)percent url:(NSString *)url {
    
    for (int i = 0; i < self.dataSource.count; i++) {
        @autoreleasepool {
            NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary: self.dataSource[i]];
            if ([[info objectForKey:@"key"] isEqualToString:url]) {
                [info setObject:@(percent) forKey:@"value"];
                [self.dataSource replaceObjectAtIndex:i withObject:info];
                [self.tableView beginUpdates];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView endUpdates];
                break;
            }
        }
    }
}

- (void)dowloadFinish:(NSString *)url {
    
    if (self.queue.operationCount == 0) {
        [ProgressHUD show];
    }
    
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadCell"];
    
    
    NSDictionary *info = [self.dataSource objectAtIndex:indexPath.row];
    
    cell.title = [info objectForKey:@"key"];
    cell.percent = [[info objectForKey:@"value"] intValue];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, self.view.frame.size.width, self.view.frame.size.height - 80) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[DownloadCell class] forCellReuseIdentifier:@"DownloadCell"];
    }
    return _tableView;
}

- (UIButton *)addBtn {
    if (!_addBtn) {
        _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addBtn.frame = CGRectMake(0, 40, self.view.frame.size.width / 2 - 5, 40);
        [_addBtn setTitle:@"添加一个下载任务\nNSOperationQueue" forState:UIControlStateNormal];
        _addBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        _addBtn.titleLabel.numberOfLines = 0;
        [_addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _addBtn.backgroundColor = [UIColor redColor];
        [_addBtn addTarget:self action:@selector(onClickAddBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addBtn;
}

- (UIButton *)addBtn2 {
    if (!_addBtn2) {
        _addBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
        _addBtn2.frame = CGRectMake(self.view.frame.size.width / 2 + 5, 40, self.view.frame.size.width / 2 - 5, 40);
        [_addBtn2 setTitle:@"添加一个下载任务\nGCD" forState:UIControlStateNormal];
        _addBtn2.titleLabel.font = [UIFont systemFontOfSize:13];
        _addBtn2.titleLabel.numberOfLines = 0;
        [_addBtn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _addBtn2.backgroundColor = [UIColor redColor];
        [_addBtn2 addTarget:self action:@selector(onClickAddBtnGCD) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addBtn2;
}


@end

