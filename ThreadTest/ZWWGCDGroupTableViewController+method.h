//
//  ZWWGCDGroupTableViewController+method.h
//  ThreadTest
//
//  Created by mac on 2018/7/30.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ZWWGCDGroupTableViewController.h"

@interface ZWWGCDGroupTableViewController (method)


//1.1 同步+并发（手动创建并发队列）
- (void)SyncAndConcurrent;
//1.2 同步+全局队列 == 1.1
- (void)syncAndGlobalQueue;

//2.1 异步+并发（手动创建并发队列）
- (void)AsyncAndConcurrent;
//2.2 同步+全局队列 == 2.1
- (void)asyncAndGlobalQueue;


//3 同步+串行
- (void)SyncAndSerial;

//4 异步+串行
- (void)AsyncAndSerial;

//5 同步+主队列
- (void)SyncAndMainQueue;

//6 异步+主队列
- (void)AsyncAndMainQueue;

//GCD常用场景
//1 代码仅执行一次
- (void)once;

//2 延迟执行
- (void)delay;

//3 调度组实现顺序执行
- (void)group;

//4 快速迭代
- (void)apply;

//5 栅栏
- (void)barrier;

//6.1 线程同步
- (void)semaphoreSync;

//6.2 线程同步(不使用semaphore,非线程安全)
- (void)initTicketStatusNotSafe;

//6.2 线程同步(使用semaphore加锁,线程安全)
- (void)initTicketStatusSafe;

@end
