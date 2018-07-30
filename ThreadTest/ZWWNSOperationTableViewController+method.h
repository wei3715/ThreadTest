//
//  ZWWNSOperationTableViewController+method.h
//  ThreadTest
//
//  Created by mac on 2018/7/30.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ZWWNSOperationTableViewController.h"

@interface ZWWNSOperationTableViewController (method)

//1.NSInvocation
- (void)testNSInvocationOperation;

//2.NSBlockOperation
- (void)testNSBlockOperation;

//3.NSOperationQueue
- (void)testNSOperationQueue;

//4.最大并发数
- (void)testOperationCount;

//5.依赖关系
- (void)testDependency;

@end
