//
//  ViewController+Method.h
//  ThreadTest
//
//  Created by mac on 2018/4/11.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ZWWMainTableViewController.h"

@interface ZWWMainTableViewController (Method)

//2.简单测试多线程场景
- (void)testMoreThreads;

//3.测试创建线程的多种方法
- (void)testCreateThreadMethod;

//4.买票系统，模拟多个线程同时访问同一个资源
- (void)testSellTicket;

//5.GCD测试
//5.1 串行+同步
- (void)GCDSerialSyn;

//5.2 串行+异步
//创建新线程，依次按顺序打印
- (void)GCDSerialAsyn;

//5.3 并发+同步
//不创建新线程，依次按顺序打印
- (void)GCDConcurrentSyn;

//5.4 并发+异步
//创建新线程，不按顺序打印
- (void)GCDConcurrentAsyn;

//6.利用系统队列，非手动创建队列

//6.1 主队列的同步请求
- (void)testMainQueueSyn;

//6.2 主队列的异步请求
- (void)testMainQueueAysn;

//6.3 全局队列的异步请求
- (void)testGlobalQueueASyn;

//6.4 全局队列的同步请求
- (void)testGlobalQueueSyn;

//7.测试系统队列
- (void)testGCDQueue;

//8.GCD的常用方法
//8.1使用GCD场景1
- (void)useGCD1;

//8.2使用GCD场景2
- (void)useGCD2;

//8.3使用GCD场景3
- (void)useGCD3;

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

//6.挂起
- (void)testNSOperationSuspend;

@end
