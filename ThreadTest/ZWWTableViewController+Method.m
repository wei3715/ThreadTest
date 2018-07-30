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


//NSOperation
//1.NSInvocationOperation
- (void)testNSOperation1{
    //创建任务NSInvocationOperation 使用start开启，默认是同步执行
    NSInvocationOperation *operation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(downImage) object:nil];
    
    //监听任务结束
    [operation setCompletionBlock:^{
        ZWWLog(@"任务结束");
    }];
    
    //开启任务,不写下面start，不会执行对应方法
    [operation start];
}

- (void)downImage{
    [NSThread sleepForTimeInterval:1.0];
    ZWWLog(@"下载图片1，当前线程==%@",[NSThread currentThread]);
}

//2.NSBlockOperation 可以并发执行一个或多个block对象，所有相关的block都执行完之后，操作才算完成
- (void)testNSOperation2{
    //创建任务NSInvocationOperation 使用start开启，默认是同步执行
    NSBlockOperation *blockOP = [NSBlockOperation blockOperationWithBlock:^{
        //任务
        [self downImage];
    }];
    
    //添加任务
    [blockOP addExecutionBlock:^{
        ZWWLog(@"任务2，当前线程==%@",[NSThread currentThread]);
    }];
    
    //添加任务
    [blockOP addExecutionBlock:^{
        ZWWLog(@"任务3，当前线程==%@",[NSThread currentThread]);
    }];
    
    //开启任务,不写下面start，不会执行对应方法
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
    //添加任务到队列
//    [queue addOperation:blockOP];
    [queue addOperations:@[invoOP,blockOP] waitUntilFinished:YES];
    [queue addOperationWithBlock:^{
        ZWWLog(@"直接添加block任务，当前线程==%@",[NSThread currentThread]);
    }];
    
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        ZWWLog(@"等同以上NSOperation操作");
    });
}

//4.最大并发数
- (void)testNSOperation4{
    //设置最大并发量，设置之后会两个两个一起来打印，不设置的话10个循环几乎同一时间并发打印
    //情况类似于 百度网盘同时勾选两个文件夹下载（可以把网速集中到某两个文件夹的下载上），不设置并发数的话，会多个线程共同并发执行，多个文件没有重要性区分
    self.opQueue.maxConcurrentOperationCount = 2;
    for (int i = 0; i<10; i++) {
        NSInvocationOperation *invoOP = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(downImage) object:nil];
        [self.opQueue addOperation:invoOP];
    }
}

//5.依赖关系
- (void)testNSOperation5{
    NSInvocationOperation *invoOP1 =  [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(downImage) object:nil];
    
    NSBlockOperation *blockOP2 = [NSBlockOperation blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:10.0];
        ZWWLog(@"下载图片2");
    }];
    NSBlockOperation *blockOP3 = [NSBlockOperation blockOperationWithBlock:^{
        ZWWLog(@"下载图片3");
    }];
    
    NSBlockOperation *blockOP4 = [NSBlockOperation blockOperationWithBlock:^{
        ZWWLog(@"更新UI");
    }];
    
    //添加依赖关系 invoOP1依赖blockOP2，blockOP2依赖blockOP3，所以先执行blockOP3
    [blockOP4 addDependency:invoOP1];
    [invoOP1 addDependency:blockOP2];
    [blockOP2 addDependency:blockOP3];
    [self.opQueue addOperations:@[invoOP1,blockOP2,blockOP3,blockOP4] waitUntilFinished:YES];
}


@end
