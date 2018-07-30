//
//  ViewController+Method.h
//  ThreadTest
//
//  Created by mac on 2018/4/11.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ZWWTableViewController.h"

@interface ZWWTableViewController (Method)

//2.简单测试多线程场景
- (void)testMoreThreads;

//3.测试创建线程的多种方法
- (void)testCreateThreadMethod;

//4.买票系统，模拟多个线程同时访问同一个资源
- (void)testSellTicket;


//7.测试系统队列
- (void)testGCDQueue;

//8.GCD的常用方法
//8.1使用GCD场景1
- (void)useGCD1;

//8.2使用GCD场景2
- (void)useGCD2;

//8.3使用GCD场景3
- (void)useGCD3;

- (void)useGCD4;

//9.中断
- (void)barrierGCD;

//NSOperation
//1.NSInvocation
- (void)testNSOperation1;

//2.NSBlockOperation
- (void)testNSOperation2;

//3.NSOperationQueue
- (void)testNSOperation3;

//4.最大并发数
- (void)testNSOperation4;

//5.依赖关系
- (void)testNSOperation5;


@end
