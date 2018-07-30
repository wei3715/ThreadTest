//
//  ZWWNSOperationTableViewController+method.m
//  ThreadTest
//
//  Created by mac on 2018/7/30.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ZWWNSOperationTableViewController+method.h"

@implementation ZWWNSOperationTableViewController (method)

//NSOperation
//1.NSInvocationOperation
- (void)testNSInvocationOperation{
    //创建任务NSInvocationOperation 使用start开启，默认是同步执行
    NSInvocationOperation *operation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(downImage) object:nil];
    
    //监听任务结束
    [operation setCompletionBlock:^{
        NSLog(@"任务结束,当前线程==%@",[NSThread currentThread]);
    }];
    
    //开启任务,不写下面start，不会执行对应方法
    [operation start];
}

- (void)downImage{
    [NSThread sleepForTimeInterval:1.0];
    NSLog(@"下载图片1，当前线程==%@",[NSThread currentThread]);
}

//2.NSBlockOperation 可以并发执行一个或多个block对象，所有相关的block都执行完之后，操作才算完成
- (void)testNSBlockOperation{
    //创建任务NSInvocationOperation 使用start开启，默认是同步执行
    NSBlockOperation *blockOP = [NSBlockOperation blockOperationWithBlock:^{
        //任务
        [self downImage];
    }];
    
    //添加任务
    [blockOP addExecutionBlock:^{
        NSLog(@"任务2，当前线程==%@",[NSThread currentThread]);
    }];
    
    //添加任务
    [blockOP addExecutionBlock:^{
        NSLog(@"任务3，当前线程==%@",[NSThread currentThread]);
    }];
    
    //开启任务（这里还是同步执行）,不写下面start，不会执行对应方法
    [blockOP start];
}

//3.NSOperationQueue
- (void)testNSOperationQueue{
    
    
    //创建操作队列；全局并发队列，添加到队列里的任务都是异步执行的
    //NSOperationQueue相当于GCD中的 dispatch_get_global_queue
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    NSInvocationOperation *invoOP = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(downImage) object:nil];
    //    [queue addOperation:invoOP];
    
    NSBlockOperation *blockOP = [NSBlockOperation blockOperationWithBlock:^{
        //任务
        [self downImage];
    }];
    //添加任务到队列方法1
    //    [queue addOperation:blockOP];
    
     //添加多个任务到队列方法2
    [queue addOperations:@[invoOP,blockOP] waitUntilFinished:YES];
    
     //添加任务到队列方法2
//    [queue addOperationWithBlock:^{
//        NSLog(@"直接添加block任务，当前线程==%@",[NSThread currentThread]);
//    }];
//
//
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        ZWWLog(@"等同以上NSOperation操作");
//    });
}

//4.最大并发数
- (void)testOperationCount{
    //设置最大并发量，设置之后会两个两个一起来打印，不设置的话10个循环几乎同一时间并发打印
    //情况类似于 百度网盘同时勾选两个文件夹下载（可以把网速集中到某两个文件夹的下载上），不设置并发数的话，会多个线程共同并发执行，多个文件没有重要性区分
    self.opQueue.maxConcurrentOperationCount = 2;
    for (int i = 0; i<10; i++) {
        NSInvocationOperation *invoOP = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(downImage) object:nil];
        [self.opQueue addOperation:invoOP];
    }
}

//5.依赖关系
- (void)testDependency{
    NSInvocationOperation *invoOP1 =  [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(downImage) object:nil];
    
    NSBlockOperation *blockOP2 = [NSBlockOperation blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:10.0];
        NSLog(@"下载图片2,当前线程==%@",[NSThread currentThread]);
    }];
    NSBlockOperation *blockOP3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"下载图片3,当前线程==%@",[NSThread currentThread]);
    }];
    
    NSBlockOperation *blockOP4 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"更新UI,当前线程==%@",[NSThread currentThread]);
    }];
    
    //添加依赖关系 invoOP1依赖blockOP2，blockOP2依赖blockOP3，所以先执行blockOP3
    [blockOP4 addDependency:invoOP1];
    [invoOP1 addDependency:blockOP2];
    [blockOP2 addDependency:blockOP3];
    [self.opQueue addOperations:@[invoOP1,blockOP2,blockOP3,blockOP4] waitUntilFinished:YES];
}

@end
