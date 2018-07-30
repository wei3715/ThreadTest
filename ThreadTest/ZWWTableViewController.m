//
//  ZWWTableViewController.m
//  ThreadTest
//
//  Created by mac on 2018/4/16.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ZWWTableViewController.h"
#import "ZWWTableViewController+Method.h"
#import "FirstViewController.h"
#import "ZWWGCDGroupTableViewController.h"
#import "ZWWTestSuspendViewController.h"
#import "ZWWUseNSOperationViewController.h"
@interface ZWWTableViewController ()

@property (nonatomic, strong) NSMutableArray *dataArr;

@end

@implementation ZWWTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataArr = [[NSMutableArray alloc]initWithObjects:@"0.测试耗时操作阻塞主线程",@"1.测试NSThread多线程",@"2.测试创建多线程的多种方法",@"3.GCD使用（多种组合）",@"4.GCD的常见用法",@"5.测试线程间通信",@"6.NSOperation",@"7.挂起", @"8.练习NSOperation使用", nil];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"homeCellID"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"homeCellID" forIndexPath:indexPath];
    cell.textLabel.text = _dataArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:{//@"测试耗时操作阻塞主线程"
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            FirstViewController *firstVC = [story instantiateViewControllerWithIdentifier:@"FirstViewController"];
            [self.navigationController pushViewController:firstVC animated:YES];            
            break;
        }
        case 1:{//@"1.测试NSThread多线程"
            [self testMoreThreads];
            break;
        }
        case 2:{//@"测试创建多线程的多种方法"
            [self testCreateThreadMethod];
            break;
        }
        case 3:
        case 4:{//@"GCD使用（多种组合）及 @"GCD的常见用法"
            ZWWGCDGroupTableViewController *GCDGroupVC = [[ZWWGCDGroupTableViewController alloc]init];
            [self.navigationController pushViewController:GCDGroupVC animated:YES];
            break;
        }
       
        case 5:{//@"测试线程间通信"
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            FirstViewController *firstVC = [story instantiateViewControllerWithIdentifier:@"FirstViewController"];
            [self.navigationController pushViewController:firstVC animated:YES];
            break;
        }
       
        case 6:{//@"NSOperation"
//            [self testNSOperation1];         //NSInvocationOperation
//            [self testNSOperation2];         //NSBlockOperation
//            [self testNSOperation3];         //NSOperationQueue
//            [self testNSOperation4];         //maxConcurrentOperationCount:最大并发数
            [self testNSOperation5];           //依赖关系
            break;
        }
        case 7:{//挂起
            ZWWTestSuspendViewController *testSuspendVC = [[ZWWTestSuspendViewController alloc]init];
            [self.navigationController pushViewController:testSuspendVC animated:YES];
            break;
        }
        case 8:{// @"练习NSOperation使用"
            ZWWUseNSOperationViewController *useNSOperationVC = [[ZWWUseNSOperationViewController alloc]init];
            [self.navigationController pushViewController:useNSOperationVC animated:YES];
            break;
        }
        default:
            break;
    }
}

- (NSOperationQueue *)opQueue{
    if (!_opQueue) {
        _opQueue = [[NSOperationQueue alloc]init];
    }
    return _opQueue;
}


@end
