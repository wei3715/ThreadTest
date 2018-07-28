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
#import "ZWWGCDGroupViewController.h"
#import "ZWWTestSuspendViewController.h"
#import "ZWWUseNSOperationViewController.h"
@interface ZWWTableViewController ()

@property (nonatomic, strong) NSMutableArray *dataArr;

@end

@implementation ZWWTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataArr = [[NSMutableArray alloc]initWithObjects:@"0.测试耗时操作阻塞主线程",@"1.测试NSThread多线程",@"2.测试创建多线程的多种方法",@"3.测试同步锁问题",@"4.GCD使用（多种组合）",@"5.测试系统队列（主队列，全局队列）",@"6.测试线程间通信",@"7.GCD的常见用法",@"8.中断",@"9.NSOperation",@"10.挂起", @"11.练习NSOperation使用", nil];
    
    
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"firstCell" forIndexPath:indexPath];
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
        case 3:{//@"测试同步锁问题"
            [self testSellTicket];
            break;
        }
        case 4:{//@"GCD使用（多种组合）
            ZWWGCDGroupViewController *GCDGroupVC = [[ZWWGCDGroupViewController alloc]init];
            [self.navigationController pushViewController:GCDGroupVC animated:YES];
//            [self GCDSerialSyn];        //同步+串行
//            [self GCDSerialAsyn];       //异步+串行
//            [self GCDConcurrentSyn];    //同步+并行
//            [self GCDConcurrentAsyn];   //异步+并行
            break;
        }
        case 5:{//测试系统队列（主队列，全局队列）
        
            //主队列
//            [self testMainQueueSyn];  //主队列+同步
//            [self testMainQueueAysn]; //主队列+异步
            
            //全局队列
                [self testGlobalQueueASyn];     //全局队列+同步
            //    [self testGlobalQueueSyn];    //全局队列+异步
            break;
        }
        case 6:{//@"测试线程间通信"
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            FirstViewController *firstVC = [story instantiateViewControllerWithIdentifier:@"FirstViewController"];
            [self.navigationController pushViewController:firstVC animated:YES];
            break;
        }
        case 7:{//@"GCD的常见用法"
//            [self useGCD1];         //单例
//            [self useGCD2];         //回主线程刷新UI
//            [self useGCD3];           //通过调度组回主线程刷新UI
            [self useGCD4];
            break;
        }
        case 8:{//@"中断"
            [self barrierGCD];
            break;
        }
        case 9:{//@"NSOperation"
//            [self testNSOperation1];         //NSInvocationOperation
//            [self testNSOperation2];         //NSBlockOperation
//            [self testNSOperation3];         //NSOperationQueue
//            [self testNSOperation4];         //maxConcurrentOperationCount:最大并发数
            [self testNSOperation5];           //依赖关系
            break;
        }
        case 10:{//挂起
            ZWWTestSuspendViewController *testSuspendVC = [[ZWWTestSuspendViewController alloc]init];
            [self.navigationController pushViewController:testSuspendVC animated:YES];
            break;
        }
        case 11:{// @"练习NSOperation使用"
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
