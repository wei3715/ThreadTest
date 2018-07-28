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

//4.买票系统，模拟多个线程同时访问同一个资源：互斥锁
- (void)testSellTicket{
    
    NSThread *thread1 = [[NSThread alloc]initWithTarget:self selector:@selector(sellTicket) object:nil];
    [thread1 start];
    
    NSThread *thread2 = [[NSThread alloc]initWithTarget:self selector:@selector(sellTicket) object:nil];
    [thread2 start];
}

- (void)sellTicket{
    while (1) {
        
        //互斥锁
        @synchronized(self){//没有这句同步锁，票数将会重复出现相同余票
//添加锁以后log：
//        2018-05-09 14:42:07.355402+0800 ThreadTest[31336:295429] 当前剩余票数==99,当前线程==<NSThread: 0x604000265480>{number = 3, name = (null)}
//        2018-05-09 14:42:07.856944+0800 ThreadTest[31336:295430] 当前剩余票数==98,当前线程==<NSThread: 0x604000265340>{number = 4, name = (null)}
//        2018-05-09 14:42:08.361467+0800 ThreadTest[31336:295429] 当前剩余票数==97,当前线程==<NSThread: 0x604000265480>{number = 3, name = (null)}
//        2018-05-09 14:42:08.865723+0800 ThreadTest[31336:295430] 当前剩余票数==96,当前线程==<NSThread: 0x604000265340>{number = 4, name = (null)}
//        2018-05-09 14:42:09.366531+0800 ThreadTest[31336:295429] 当前剩余票数==95,当前线程==<NSThread: 0x604000265480>{number = 3, name = (null)}
//        2018-05-09 14:42:09.870295+0800 ThreadTest[31336:295430] 当前剩余票数==94,当前线程==<NSThread: 0x604000265340>{number = 4, name = (null)}

//未添加锁log：
//        2018-04-17 14:35:59.248002+0800 ThreadTest[33159:309307] 当前剩余票数==98,当前线程==<NSThread: 0x6040002670c0>{number = 4, name = (null)}
//        2018-04-17 14:35:59.248002+0800 ThreadTest[33159:309306] 当前剩余票数==99,当前线程==<NSThread: 0x6040002671c0>{number = 3, name = (null)}
//        2018-04-17 14:35:59.752893+0800 ThreadTest[33159:309306] 当前剩余票数==96,当前线程==<NSThread: 0x6040002671c0>{number = 3, name = (null)}
//        2018-04-17 14:35:59.752893+0800 ThreadTest[33159:309307] 当前剩余票数==97,当前线程==<NSThread: 0x6040002670c0>{number = 4, name = (null)}
//        2018-04-17 14:36:00.255519+0800 ThreadTest[33159:309307] 当前剩余票数==95,当前线程==<NSThread: 0x6040002670c0>{number = 4, name = (null)}
        
            if (count!=0) {
                [NSThread sleepForTimeInterval:0.5];
                count--;
                ZWWLog(@"当前剩余票数==%d,当前线程==%@",count,[NSThread currentThread]);
            } else {
                ZWWLog(@"票已卖完");
                break;
            }
        }
    }
}


//6.3 全局队列的异步请求
- (void)testGlobalQueueASyn{
    //GCD默认已经创建好了并发队列，不用手动创建
    //全局队列（优先级队列）：是并发队列 第一个参数是优先级（2：高，0：默认，-2：低）
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_TARGET_QUEUE_DEFAULT, 0);
    ZWWLog(@"任务开始");
//    ZWWLog(@"当前线程begin==%@",[NSThread currentThread]);
    for (int i = 0; i<10; i++) {
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

//6.4 全局队列的同步请求
- (void)testGlobalQueueSyn{
    //GCD默认已经创建好了并发队列，不用手动创建
    //全局队列（优先级队列）：是并发队列 第一个参数是优先级（2：高，0：默认，-2：低）
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_TARGET_QUEUE_DEFAULT, 0);
    ZWWLog(@"任务开始");
    ZWWLog(@"当前线程begin==%@",[NSThread currentThread]);
    for (int i = 0; i<10; i++) {
        //同步任务：要求立即执行
        dispatch_sync(globalQueue, ^{
            ZWWLog(@"当前线程==%@,打印值==%d",[NSThread currentThread],i);
        });
    }
    
    ZWWLog(@"任务结束");
    ZWWLog(@"当前线程end==%@",[NSThread currentThread]);
}

//8.1使用GCD场景1
- (void)useGCD1{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ZWWLog(@"使用GCD创建单例");
    });
}

//8.2使用GCD场景1
- (void)useGCD2{
    ZWWLog(@"任务开始,当前线程==%@",[NSThread currentThread]);
//    [self performSelector:@selector(handleThread) withObject:nil afterDelay:2];
    
    //DISPATCH_TIME_NOW  立即开始
    //DISPATCH_TIME_FOREVER 永远
    //NSEC_PER_SEC 秒
    //NSEC_PER_MSEC 毫秒
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2* NSEC_PER_SEC));
    dispatch_after(time, dispatch_get_main_queue(), ^{
        ZWWLog(@"延迟后打印任务");
    });
    ZWWLog(@"任务结束,当前线程==%@",[NSThread currentThread]);
}

//8.3使用GCD场景3
- (void)useGCD3{
    
    //创建一个调度组
    dispatch_group_t group = dispatch_group_create();
    
    //获取全局队列
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    //调度组使用情况1
    dispatch_group_async(group, queue, ^{
        [NSThread sleepForTimeInterval:2.0];
        ZWWLog(@"下载图片1,当前线程==%@",[NSThread currentThread]);
    });

    dispatch_group_async(group, queue, ^{
        [NSThread sleepForTimeInterval:1.0];
        ZWWLog(@"下载图片2,当前线程==%@",[NSThread currentThread]);
    });

    dispatch_group_async(group, queue, ^{
        [NSThread sleepForTimeInterval:3.0];
        ZWWLog(@"下载图片3,当前线程==%@",[NSThread currentThread]);
    });

    //notify通知，所有异步请求完毕后会通知
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        ZWWLog(@"下载完毕更新UI,当前线程==%@",[NSThread currentThread]);
    });
    
    //调度组使用情况2
    //进入队列
//    dispatch_group_enter(group);
//    dispatch_group_async(group, queue, ^{
//        [NSThread sleepForTimeInterval:2.0];
//        ZWWLog(@"下载图片1,当前线程==%@",[NSThread currentThread]);
//        //离开队列
//        dispatch_group_leave(group);
//    });
//
//    //进入队列
//    dispatch_group_enter(group);
//    dispatch_group_async(group, queue, ^{
//        [NSThread sleepForTimeInterval:1.0];
//        ZWWLog(@"下载图片2,当前线程==%@",[NSThread currentThread]);
//        //离开队列
//        dispatch_group_leave(group);
//    });
//
//    //进入队列
//    dispatch_group_enter(group);
//    dispatch_group_async(group, queue, ^{
//        [NSThread sleepForTimeInterval:3.0];
//        ZWWLog(@"下载图片3,当前线程==%@",[NSThread currentThread]);
//        //离开队列
//        dispatch_group_leave(group);
//    });
//
//    //wait 相当于阻塞
//    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
//    ZWWLog(@"下载完毕更新UI,当前线程==%@",[NSThread currentThread]);
    
}

//
- (void)useGCD4 {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    ZWWLog(@"apply---begin");
    dispatch_apply(6, queue, ^(size_t index) {
        NSLog(@"%zd---%@",index, [NSThread currentThread]);
    });
    ZWWLog(@"apply---end");
}

//9.中断  3,4肯定在1，2下面打印，1，2顺序不确定
- (void)barrierGCD{
    dispatch_queue_t queue = dispatch_queue_create("zoe", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        
        [NSThread sleepForTimeInterval:2.0];
        ZWWLog(@"任务1");
    });
    
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:2.0];
        for (int i = 0; i < 2; ++i){
        ZWWLog(@"任务2,i==%d",i);
        }
    });
    
    dispatch_barrier_async(queue, ^{
        ZWWLog(@"中断");
    });
    
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:2.0];
        for (int i = 0; i < 3; ++i){
            ZWWLog(@"任务3,i==%d",i);
        }
    });
    dispatch_async(queue, ^{
        ZWWLog(@"任务4");
    });
}
//打印log
//2018-04-21 15:23:33.509891+0800 ThreadTest[36765:338563] 打印2
//2018-04-21 15:23:35.514738+0800 ThreadTest[36765:338570] 打印1
//2018-04-21 15:23:35.514932+0800 ThreadTest[36765:338570] 中断
//2018-04-21 15:23:35.515067+0800 ThreadTest[36765:338570] 打印3
//2018-04-21 15:23:35.515083+0800 ThreadTest[36765:338563] 打印4


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
