//
//  ViewController+Method.m
//  ThreadTest
//
//  Created by mac on 2018/4/11.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ZWWTableViewController+Method.h"
static int count = 100;

@implementation ZWWTableViewController (Method)

//2.简单测试多线程场景
- (void)testMoreThreads{
    //获取当前线程名称
    ZWWLog(@"获取当前线程名称%@",[NSThread currentThread]);
    
    //获取主线程
    ZWWLog(@"获取主线程%@",[NSThread mainThread]);
    
    //创建子线程1
    NSThread *thread1 = [[NSThread alloc]initWithTarget:self selector:@selector(handleThread) object:nil];
    //给线程起名字方便区分
    thread1.name = @"zww1";
    //设置子线程优先级(0~1)
    thread1.threadPriority = 1;
    //把子线程放入可调度的线程池里（开始线程），此时线程处于"就绪”状态
    [thread1 start];
    
    //创建子线程2
    NSThread *thread2 = [[NSThread alloc]initWithTarget:self selector:@selector(handleThread) object:nil];
    thread2.name = @"zww2";
    thread2.threadPriority = 0.1;
    [thread2 start];
}

//3.测试创建线程的多种方法
- (void)testCreateThreadMethod{
    //方法1：类方法，不需要start开启线程
        [NSThread detachNewThreadSelector:@selector(handleThread) toTarget:self withObject:nil];


    //方法2,默认在主线程执行
//      [self performSelector:@selector(handleThread) withObject:nil afterDelay:1.0];
    
    //方法3：隐式创建
//     [self performSelectorInBackground:@selector(handleThread) withObject:nil];


}

- (void)handleThread{
    ZWWLog(@"当前线程名字==%@",[NSThread currentThread]);
    
    //在子线程中获取主线程
    //    ZWWLog(@"子线程中获取主线程名字==%@",[NSThread mainThread]);
}

//6.3 全局队列的异步请求
- (void)testGlobalQueueASyn{
    //GCD默认已经创建好了并发队列，不用手动创建
    //全局队列（优先级队列）：是并发队列 第一个参数是优先级（2：高，0：默认，-2：低）
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_TARGET_QUEUE_DEFAULT, 0);
    ZWWLog(@"任务开始");
//    ZWWLog(@"当前线程begin==%@",[NSThread currentThread]);
    for (int i = 0; i<5; i++) {
        //异步任务：不要求立即执行
        dispatch_async(globalQueue, ^{
            ZWWLog(@"当前线程1==%@,打印值==%d",[NSThread currentThread],i);
            
            ZWWLog(@"当前线程2==%@,打印值==%d",[NSThread currentThread],i);
        });
    }
//
    ZWWLog(@"任务结束");
//    ZWWLog(@"当前线程end==%@",[NSThread currentThread]);

//    dispatch_async(dispatch_get_main_queue(), ^{
//        ZWWLog(@"回到主线程==%@",[NSThread currentThread]);
//    });
//    __block long sum = 0;
//    dispatch_async(globalQueue, ^{
//        for (int i = 0; i<50000; i++) {
//            ZWWLog(@"当前线程==%@，打印值==%ld",[NSThread currentThread],i);
//            sum+=i;
//        }
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            ZWWLog(@"sum==%ld",sum);
//        });
//    });
    
    
}





@end
