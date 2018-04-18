//
//  ZWWMainTableViewController.m
//  ThreadTest
//
//  Created by mac on 2018/4/16.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ZWWMainTableViewController.h"
#import "ZWWMainTableViewController+Method.h"
#import "FirstViewController.h"
@interface ZWWMainTableViewController ()

@property (nonatomic, strong) NSMutableArray *dataArr;

@end

@implementation ZWWMainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataArr = [[NSMutableArray alloc]initWithObjects:@"测试耗时操作阻塞主线程",@"测试多线程",@"测试创建多线程的多种方法",@"测试同步锁问题",@"GCD使用（多种组合）",@"测试系统队列（主队列，全局队列）",@"测试线程间通信", nil];
    
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
    
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:{
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            FirstViewController *firstVC = [story instantiateViewControllerWithIdentifier:@"FirstViewController"];
            [self.navigationController pushViewController:firstVC animated:YES];            
            break;
        }
        case 1:{
            [self testMoreThreads];
            break;
        }
        case 2:{
            [self testCreateThreadMethod];
            break;
        }
        case 3:{
            [self testSellTicket];
            break;
        }
        case 4:{
            [self GCDSerialSyn];
            [self GCDSerialAsyn];
            [self GCDConcurrentSyn];
            [self GCDConcurrentAsyn];
            break;
        }
        case 5:{
        
            //主队列
//            [self testMainQueueSyn];
//            [self testMainQueueAysn];
            
            //全局队列
            
                [self testGlobalQueueASyn];
            //    [self testGlobalQueueSyn];
            break;
        }
        case 6:{
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            FirstViewController *firstVC = [story instantiateViewControllerWithIdentifier:@"FirstViewController"];
            [self.navigationController pushViewController:firstVC animated:YES];
            break;
        }
        default:
            break;
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
