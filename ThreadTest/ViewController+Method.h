//
//  ViewController+Method.h
//  ThreadTest
//
//  Created by mac on 2018/4/11.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (Method)

//1.测试耗时操作阻塞主线程
- (void)testThread;

//2.简单测试多线程场景
- (void)testMoreThreads;

//3.测试创建线程的多种方法
- (void)testCreateThreadMethod;

//4.买票系统，模拟多个线程同时访问同一个资源
- (void)testSellTicket;


@end
