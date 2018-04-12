//
//  ViewController+Method.m
//  ThreadTest
//
//  Created by mac on 2018/4/11.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ViewController+Method.h"
static int count = 100;
@implementation ViewController (Method)

//1.测试耗时操作阻塞主线程
- (void)testThread{
    int sum = 0;
    for (int i = 0; i<50000; i++) {
        sum+=i;
        NSLog(@"sum==%d",i);
    }
}

//2.简单测试多线程场景
- (void)testMoreThreads{
    //获取当前线程名称
    NSLog(@"获取当前线程名称%@",[NSThread currentThread]);
    
    //获取主线程
    NSLog(@"获取主线程%@",[NSThread mainThread]);
    
    //创建子线程
    NSThread *thread1 = [[NSThread alloc]initWithTarget:self selector:@selector(handleThread) object:nil];
    //给线程起名字方便区分
    thread1.name = @"zww1";
    //设置子线程优先级(0~1)
    thread1.threadPriority = 1;
    //把子线程放入可调度的线程队列中（开始线程）
    [thread1 start];
    
    //创建子线程
    NSThread *thread2 = [[NSThread alloc]initWithTarget:self selector:@selector(handleThread) object:nil];
    //给线程起名字方便区分
    thread2.name = @"zww2";
    //设置子线程优先级(0~1)
    thread2.threadPriority = 0.1;
    //把子线程放入可调度的线程池里（开始线程），此时线程处于"就绪”状态
    [thread2 start];
}

//3.测试创建线程的多种方法
- (void)testCreateThreadMethod{
    //方法1：类方法，不需要start开启线程
    //    [NSThread detachNewThreadSelector:@selector(handleThread) toTarget:self withObject:nil];
    
    //方法2,默认在主线程执行
    //    [self performSelector:@selector(handleThread) withObject:nil afterDelay:1.0];
    
    //方法3：隐式创建
    [self performSelectorInBackground:@selector(handleThread) withObject:nil];
    
}

//4.买票系统，模拟多个线程同时访问同一个资源
- (void)testSellTicket{
    
    NSThread *thread1 = [[NSThread alloc]initWithTarget:self selector:@selector(sellTicket) object:nil];
    [thread1 start];
    
    NSThread *thread2 = [[NSThread alloc]initWithTarget:self selector:@selector(sellTicket) object:nil];
    [thread2 start];
}

- (void)sellTicket{
    while (1) {
        
        //互斥锁
        @synchronized(self){
            
            if (count!=0) {
                [NSThread sleepForTimeInterval:0.5];
                count--;
                NSLog(@"当前剩余票数==%d,当前线程==%@",count,[NSThread currentThread]);
            } else {
                NSLog(@"票已卖完");
                break;
            }
        }
    }
}

- (void)handleThread{
    NSLog(@"当前线程名字==%@",[NSThread currentThread]);
    
    //在子线程中获取主线程
    //    NSLog(@"子线程中获取主线程名字==%@",[NSThread mainThread]);
}

@end
