//
//  ZWWNSOperationTableViewController.m
//  ThreadTest
//
//  Created by mac on 2018/7/30.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ZWWNSOperationTableViewController.h"
#import "ZWWTestSuspendViewController.h"
#import "ZWWUseNSOperationViewController.h"

@interface ZWWNSOperationTableViewController ()

@property (nonatomic, strong) NSArray *sectionArr;
@property (nonatomic, strong) NSArray *rowArr;
@property (nonatomic, strong) NSArray *selectorNameArr;

@end

@implementation ZWWNSOperationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _sectionArr = @[@"NSOperation",@"NSOperation常见使用场景"];
    _rowArr = @[@[@"1 NSInvocationOperation",@"2 NSBlockOperation",
                  @"3 NSOperationQueue",@"4 最大并发量OperationCount",
                  @"5 依赖关系Dependency"
                  ],
                @[@"1 挂起",@"2 具体使用"]
                ];
    _selectorNameArr = @[@[@"testNSInvocationOperation",@"testNSBlockOperation",
                           @"testNSOperationQueue",@"testOperationCount",
                           @"testDependency"
                           ],
                         @[@"ZWWTestSuspendViewController",@"ZWWUseNSOperationViewController"]
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
    if (indexPath.section == 0) {
        SEL selector = NSSelectorFromString(_selectorNameArr[indexPath.section][indexPath.row]);
        IMP imp = [self methodForSelector:selector];
        void (*func)(id,SEL) = (void*)imp;
        func(self,selector);
    } else if (indexPath.section == 1) {
        Class clsName = NSClassFromString(_selectorNameArr[indexPath.section][indexPath.row]);
        UIViewController *vc = [[clsName alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    
}

- (NSOperationQueue *)opQueue{
    if (!_opQueue) {
        _opQueue = [[NSOperationQueue alloc]init];
    }
    return _opQueue;
}

@end
