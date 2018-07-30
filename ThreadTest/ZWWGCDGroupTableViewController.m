//
//  ZWWGCDGroupTableViewController.m
//  ThreadTest
//
//  Created by mac on 2018/7/30.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ZWWGCDGroupTableViewController.h"

@interface ZWWGCDGroupTableViewController ()

@property (nonatomic, strong) NSArray *sectionArr;
@property (nonatomic, strong) NSArray *rowArr;
@property (nonatomic, strong) NSArray *selectorNameArr;

@end

@implementation ZWWGCDGroupTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _sectionArr = @[@"GCD多种组合方式",@"GCD常见使用场景"];
    _rowArr = @[@[@"1.1 同步+并行",@"1.2 同步+全局队列",
                  @"2.1 异步+并行",@"2.2 异步+全局队列",
                  @"3 同步+串行",@"4 异步+串行",
                  @"5 同步+主队列",@"6 异步+主队列"
                  ],
                @[@"1 执行一次代码",@"2 执行延时代码",@"3 调度组dispatch_group_t",
                  @"4 栅栏dispatch_barrier_async",@"5 快速迭代方法：dispatch_apply",
                  @"6.1 Dispatch Semaphore 线程同步",@"6.2 Dispatch Semaphore 线程同步(不使用semaphore,非安全)",@"6.3 Dispatch Semaphore 线程同步(使用semaphore加锁)"]
                ];
    _selectorNameArr = @[@[@"SyncAndConcurrent",@"syncAndGlobalQueue",
                           @"AsyncAndConcurrent",@"asyncAndGlobalQueue",
                           @"SyncAndSerial",@"AsyncAndSerial",
                           @"SyncAndMainQueue",@"AsyncAndMainQueue"
                           ],
                         @[@"once",@"delay",@"group",
                           @"barrier",@"apply",
                           @"semaphoreSync",@"initTicketStatusNotSafe",@"initTicketStatusSafe"]
                         ];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellID"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sectionArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [_rowArr[section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID" forIndexPath:indexPath];
    cell.textLabel.text = _rowArr[indexPath.section][indexPath.row];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return _sectionArr[section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SEL selector = NSSelectorFromString(_selectorNameArr[indexPath.section][indexPath.row]);
    IMP imp = [self methodForSelector:selector];
    void (*func)(id,SEL) = (void*)imp;
    func(self,selector);

}



@end
