//
//  ZWWGCDGroupTableViewController+method.m
//  ThreadTest
//
//  Created by mac on 2018/7/30.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ZWWGCDGroupTableViewController+method.h"
static int ticketSurplusCountNotSafe = 50;
static int ticketSurplusCountSafe = 50;
static dispatch_semaphore_t semaphoreLock;

@implementation ZWWGCDGroupTableViewController (method)

/**
 同步执行 + 并发队列
 特点：在当前线程中执行任务，不会开启新线程，执行完一个任务，再执行下一个任务
 */
- (void)SyncAndConcurrent {
    dispatch_queue_t queue = dispatch_queue_create("com.zoe3", DISPATCH_QUEUE_CONCURRENT);
    
    NSLog(@"syncConcurrent begin，当前线程==%@",[NSThread currentThread]);
    [NSThread sleepForTimeInterval:2];
    
    for (int i = 0; i<5; i++) {
        dispatch_sync(queue, ^{
            if (i==1) {
                [NSThread sleepForTimeInterval:10];
            }
            NSLog(@"当前打印值==%d,线程==%@",i,[NSThread currentThread]);
            
            //嵌套1
//            dispatch_async(queue, ^{
//                NSLog(@"当前打印值==%d，同步并行+嵌套+异步",i);
//            });
            
            //嵌套2
//            dispatch_sync(queue, ^{
//                NSLog(@"当前打印值==%d，同步并行+嵌套+同步",i);
//            });
            
        });
    }
    NSLog(@"syncConcurrent end,当前线程==%@",[NSThread currentThread]);
}

/**
 异步 + 并发
 特点：可以开启多个线程，任务交替（同时）执行。
 */
- (void)AsyncAndConcurrent {
    
    dispatch_queue_t queue = dispatch_queue_create("com.zoe4", DISPATCH_QUEUE_CONCURRENT);
    
    NSLog(@"AsyncConcurrent begin，当前线程==%@",[NSThread currentThread]);
    [NSThread sleepForTimeInterval:2];
    
    for (int i = 0; i<5; i++) {
        dispatch_async(queue, ^{
            if (i==1) {
                [NSThread sleepForTimeInterval:10];
            }
            NSLog(@"当前打印值==%d,线程==%@",i,[NSThread currentThread]);
            
            //嵌套1
//            dispatch_async(queue, ^{
//                NSLog(@"当前打印值==%d，异步并行+嵌套+异步",i);
//            });
            
            //嵌套2
//            dispatch_sync(queue, ^{
//                NSLog(@"当前打印值==%d，异步并行+嵌套+同步",i);
//            });
        });
    }
    
    NSLog(@"AsyncConcurrent end，当前线程==%@",[NSThread currentThread]);
}

/**
 同步 + 串行
 特点：不会开启新线程，在当前线程（主线程）执行任务。任务是串行的，执行完一个任务，再执行下一个任务
 */
- (void)SyncAndSerial {
    // 创建一个串行队列：DISPATCH_QUEUE_SERIAL串行队列的优先级没有主队列优先级高，所以在这个串行队列中开启同步任务不会堵塞主线程
    dispatch_queue_t queue = dispatch_queue_create("com.zoe1", DISPATCH_QUEUE_SERIAL);
    
    NSLog(@"syncSerial begin，当前线程==%@",[NSThread currentThread]);
    [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
    for (int i = 0; i<5; i++) {

        dispatch_sync(queue, ^{
            if (i==1) {
                [NSThread sleepForTimeInterval:10];
            }
            NSLog(@"当前打印值==%d,线程==%@",i,[NSThread currentThread]);
            //情况1
            // 下面开启同步造成死锁：因为串行队列中线程是有执行顺序的，需要等上面开启的同步任务执行完毕，才会执行下面开启的同步任务。而上面的同步任务还没执行完，要到下面的大括号才算执行完毕，而下面的同步任务已经在抢占资源了，就会发生死锁。
//                dispatch_sync(queue, ^{
//                    NSLog(@"串行队列同步函数嵌套同步操作造成死锁");
//                });
            
            //情况2：
            //开启异步，就会开启一个新的线程,不会阻塞线程
            //串行队列开启同步任务后嵌套异步任务不造成死锁
//                dispatch_async(queue, ^{
//                    NSLog(@"异步任务 %@", [NSThread currentThread]);
//                });
        });
    }
    
    NSLog(@"syncSerial end,当前线程==%@",[NSThread currentThread]);
}


/**
 异步 + 串行
 特点：会开启新线程，但是因为任务是串行的，执行完一个任务，再执行下一个任务（该线程里的任务依次顺序执行，但是该线程以外（主队列上任务）的任务和该线程上任务执行顺序不确定）
 */
- (void)AsyncAndSerial {
    
    dispatch_queue_t queue = dispatch_queue_create("com.zoe2", DISPATCH_QUEUE_SERIAL);
    
    NSLog(@"AsyncSerial begin,当前线程==%@",[NSThread currentThread]);
    [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
    for (int i = 0; i<5; i++) {
        
        dispatch_async(queue, ^{
            if (i==1) {
                [NSThread sleepForTimeInterval:10];
            }
            NSLog(@"当前打印值==%d,线程==%@",i,[NSThread currentThread]);

            // 下面开启同步造成死锁：(串行队列中添加同步任务)因为串行队列中线程是有执行顺序的，需要等上面开启的异步任务执行完毕，才会执行下面开启的同步任务。而上面的异步任务还没执行完，要到下面的大括号才算执行完毕，而下面的同步任务已经在抢占资源了，就会发生死锁。
            //            dispatch_sync(queue, ^{
            //                NSLog(@"串行队列开启异步任务后嵌套同步任务造成死锁");
            //            });
            
            
        });
    }
    
    NSLog(@"AsyncSerial end,当前线程==%@",[NSThread currentThread]);
}

//利用系统创建队列，非手动创建队列

/**
 同步 + 主队列：在主线程中调用同步执行 + 主队列
 特点：互等卡住不执行。
 */
- (void)SyncAndMainQueue {
    //主队列+同步请求=死锁=线程阻塞（viewDidLoad方法未执行完，同步又要求立即执行循环打印任务，造成死锁）
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    NSLog(@"SyncMainQueue begin，当前线程begin==%@",[NSThread currentThread]);
    [NSThread sleepForTimeInterval:2];
    for (int i = 0; i<5; i++) {
        //同步任务：要求立即执行
        dispatch_sync(mainQueue, ^{
            NSLog(@"当前线程==%@,打印值==%d",[NSThread currentThread],i);
        });
    }
    
    NSLog(@"SyncMainQueue end，当前线程end==%@",[NSThread currentThread]);
}

/**
 同步 + 主队列：在其它线程中调用同步执行 + 主队列
 特点：不会开启新线程，执行完一个任务，再执行下一个任务
 */
- (void)AsyncAndMainQueueOtherThread {
    [NSThread detachNewThreadSelector:@selector(SyncAndMainQueue) toTarget:self withObject:nil];
}


/**
 异步 + 主队列
 特点：只在主线程中执行任务，执行完一个任务，再执行下一个任务
 */
- (void)AsyncAndMainQueue {
    
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    NSLog(@"AsyncMainQueue begin，当前线程begin==%@",[NSThread currentThread]);
    [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
    for (int i = 0; i<5; i++) {
        //异步任务：不要求立即执行
        dispatch_async(mainQueue, ^{
            NSLog(@"当前线程==%@,打印值==%d",[NSThread currentThread],i);
        });
    }
    
    NSLog(@"AsyncMainQueue end，当前线程end==%@",[NSThread currentThread]);
}

//同步+全局队列
- (void)syncAndGlobalQueue {
    //GCD默认已经创建好了并发队列，不用手动创建
    //全局队列（优先级队列）：是并发队列 第一个参数是优先级（2：高，0：默认，-2：低）
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_TARGET_QUEUE_DEFAULT, 0);
    NSLog(@"syncGlobalQueue begin，当前线程==%@",[NSThread currentThread]);
    [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
    //    NSLog(@"当前线程begin==%@",[NSThread currentThread]);
    for (int i = 0; i<5; i++) {
        //异步任务：不要求立即执行
        dispatch_sync(globalQueue, ^{
            NSLog(@"当前线程==%@,打印值==%d",[NSThread currentThread],i);
        });
    }
    NSLog(@"syncGlobalQueue end，当前线程==%@",[NSThread currentThread]);
}

//异步+全局队列
- (void)asyncAndGlobalQueue {
    //GCD默认已经创建好了并发队列，不用手动创建
    //全局队列（优先级队列）：是并发队列 第一个参数是优先级（2：高，0：默认，-2：低）
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_TARGET_QUEUE_DEFAULT, 0);
    NSLog(@"asyncGlobalQueue begin，当前线程==%@",[NSThread currentThread]);
    [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
    for (int i = 0; i<5; i++) {
        //同步任务：要求立即执行
        dispatch_async(globalQueue, ^{
            NSLog(@"当前线程==%@,打印值==%d",[NSThread currentThread],i);
        });
    }
    
    NSLog(@"asyncGlobalQueue end，当前线程==%@",[NSThread currentThread]);
}

//GCD常见用法
- (void)once{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 只执行1次的代码(这里面默认是线程安全的)
        NSLog(@"使用GCD创建单例");
    });
}

- (void)delay{
    NSLog(@"任务开始,当前线程==%@",[NSThread currentThread]);
    //    [self performSelector:@selector(handleThread) withObject:nil afterDelay:2];
    
    //DISPATCH_TIME_NOW  立即开始
    //DISPATCH_TIME_FOREVER 永远
    //NSEC_PER_SEC 秒
    //NSEC_PER_MSEC 毫秒
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2* NSEC_PER_SEC));
    dispatch_after(time, dispatch_get_main_queue(), ^{
        // 2.0秒后异步追加任务代码到主队列，并开始执行
        NSLog(@"延迟后打印任务，当前线程==%@",[NSThread currentThread]);
    });
    NSLog(@"任务结束,当前线程==%@",[NSThread currentThread]);
}

- (void)group{
    
    //创建一个调度组
    dispatch_group_t group = dispatch_group_create();
    
    //获取全局队列
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    NSLog(@"任务开始,当前线程==%@",[NSThread currentThread]);
    //调度组使用情况1
    dispatch_group_async(group, queue, ^{
        [NSThread sleepForTimeInterval:2.0];
        NSLog(@"下载图片1,当前线程==%@",[NSThread currentThread]);
    });

    dispatch_group_async(group, queue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"下载图片2,当前线程==%@",[NSThread currentThread]);
    });

    dispatch_group_async(group, queue, ^{
        [NSThread sleepForTimeInterval:3.0];
        NSLog(@"下载图片3,当前线程==%@",[NSThread currentThread]);
    });
    
    //回主线程刷新UI方法1：notify通知，所有异步请求完毕后会通知，不会阻塞当前调用线程；会先打印任务结束，再执行block
//    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
//        NSLog(@"下载完毕更新UI,当前线程==%@",[NSThread currentThread]);
//    });
    
    //调度组使用情况2
    //进入队列
    //    dispatch_group_enter(group);
    //    dispatch_group_async(group, queue, ^{
    //        [NSThread sleepForTimeInterval:2.0];
    //        NSLog(@"下载图片1,当前线程==%@",[NSThread currentThread]);
    //        //离开队列
    //        dispatch_group_leave(group);
    //    });
    //
    //    //进入队列
    //    dispatch_group_enter(group);
    //    dispatch_group_async(group, queue, ^{
    //        [NSThread sleepForTimeInterval:1.0];
    //        NSLog(@"下载图片2,当前线程==%@",[NSThread currentThread]);
    //        //离开队列
    //        dispatch_group_leave(group);
    //    });
    //
    //    //进入队列
    //    dispatch_group_enter(group);
    //    dispatch_group_async(group, queue, ^{
    //        [NSThread sleepForTimeInterval:3.0];
    //        NSLog(@"下载图片3,当前线程==%@",[NSThread currentThread]);
    //        //离开队列
    //        dispatch_group_leave(group);
    //    });
    //
    
    
        //回主线程刷新UI方法2：wait 相当于阻塞，会阻塞当前调用线程 “任务结束”会在最后面打印
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        NSLog(@"下载完毕更新UI,当前线程==%@",[NSThread currentThread]);
    
    
    
//    dispatch_async(queue, ^{
//        dispatch_group_enter(group);
//        [NSThread sleepForTimeInterval:2.0];
//        NSLog(@"下载图片1,当前线程==%@",[NSThread currentThread]);
//        //离开队列
//        dispatch_group_leave(group);
//
//        dispatch_group_enter(group);
//        [NSThread sleepForTimeInterval:1.0];
//        NSLog(@"下载图片2,当前线程==%@",[NSThread currentThread]);
//        //离开队列
//        dispatch_group_leave(group);
//
//        dispatch_group_enter(group);
//        [NSThread sleepForTimeInterval:3.0];
//        NSLog(@"下载图片3,当前线程==%@",[NSThread currentThread]);
//        //离开队列
//        dispatch_group_leave(group);
//
//        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
//        NSLog(@"下载完毕更新UI,当前线程==%@",[NSThread currentThread]);
//    });
//
   
    
    NSLog(@"任务结束,当前线程==%@",[NSThread currentThread]);
}


- (void)apply {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSLog(@"apply---begin");
    dispatch_apply(6, queue, ^(size_t index) {
        NSLog(@"index==%zd，当前线程==%@",index, [NSThread currentThread]);
    });
    NSLog(@"apply---end");
}
//等同于异步+并发，但是因为dispatch_apply函数会等待全部任务执行完毕，所以apply---end最后打印

- (void)barrier{
    //注意一定要使用自己创建的并发队列，如果使用全局并发队列会产生错误的结果
    dispatch_queue_t queue = dispatch_queue_create("zoe", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    NSLog(@"任务开始,当前线程==%@",[NSThread currentThread]);
    [NSThread sleepForTimeInterval:2.0];
    
    dispatch_async(queue, ^{
        
        [NSThread sleepForTimeInterval:2.0];
        NSLog(@"任务1,当前线程==%@",[NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:2.0];
        for (int i = 0; i < 2; ++i){
            NSLog(@"任务2,i==%d,当前线程==%@",i,[NSThread currentThread]);
        }
    });
    
    dispatch_barrier_async(queue, ^{
        // 追加任务 barrier
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"中断，i==%d,当前线程==%@",i,[NSThread currentThread]);
        }
    });
    
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:2.0];
        for (int i = 0; i < 5; ++i){
            NSLog(@"任务3,i==%d,当前线程==%@",i,[NSThread currentThread]);
        }
    });
    
    dispatch_async(queue, ^{
        NSLog(@"任务4,当前线程==%@",[NSThread currentThread]);
    });
    
     NSLog(@"任务结束,当前线程==%@",[NSThread currentThread]);
}
//结果：在执行完栅栏前面的操作之后，才执行栅栏操作，最后再执行栅栏后边的操作

//semaphore线程同步
- (void)semaphoreSync{
    NSLog(@"semaphore begin，当前线程==%@",[NSThread currentThread]);
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    //dispatch_semaphore_create参数是信号量值， 表示最多几个资源可访问，如果小于0则返回NULL
    //由于设定的信号值为2，先执行两个线程，等执行完一个，才会继续执行下一个，保证同一时间执行的线程数不超过2。
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(2);
    __block int number = 0;
    
    //追加任务可以用dispatch_async也可以用dispatch_sync
    dispatch_async(queue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        // 追加任务1
        [NSThread sleepForTimeInterval:2];
        NSLog(@"任务1，当前线程==%@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:25];
        number = 100;
        NSLog(@"任务1完成，当前线程==%@",[NSThread currentThread]);
        dispatch_semaphore_signal(semaphore);
    });
    dispatch_async(queue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        // 追加任务2
        [NSThread sleepForTimeInterval:2];
        NSLog(@"任务2，当前线程==%@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:5];
        number = 50;
        NSLog(@"任务2完成，当前线程==%@",[NSThread currentThread]);
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_async(queue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        // 追加任务2
        [NSThread sleepForTimeInterval:2];
        NSLog(@"任务3，当前线程==%@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:5];
        number = 10;
        NSLog(@"任务3完成，当前线程==%@",[NSThread currentThread]);
        dispatch_semaphore_signal(semaphore);
    });
    NSLog(@"semaphore---end,number = %d",number);
    
}

- (void)initTicketStatusNotSafe {
    NSLog(@"semaphore begin，当前线程==%@",[NSThread currentThread]);
   
    // queue1 代表北京火车票售卖窗口
    dispatch_queue_t queue1 = dispatch_queue_create("net.bujige.testQueue1", DISPATCH_QUEUE_SERIAL);
    // queue2 代表上海火车票售卖窗口
    dispatch_queue_t queue2 = dispatch_queue_create("net.bujige.testQueue2", DISPATCH_QUEUE_SERIAL);
    kWeakSelf(self);
    dispatch_async(queue1, ^{
        [weakself saleTicketNotSafe];
    });
    dispatch_async(queue2, ^{
        [weakself saleTicketNotSafe];
    });
    NSLog(@"semaphore begin，当前线程==%@",[NSThread currentThread]);
}
/**
 * 售卖火车票(非线程安全)
 */
- (void)saleTicketNotSafe {
    while (1) {
        if (ticketSurplusCountNotSafe > 0) { //如果还有票，继续售卖
            ticketSurplusCountNotSafe--;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%d 窗口：%@", ticketSurplusCountNotSafe, [NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.5];
        } else { //如果已卖完，关闭售票窗口
            NSLog(@"所有火车票均已售完");
            break;
        }
    }
}

- (void)initTicketStatusSafe {
    NSLog(@"semaphore begin，当前线程==%@",[NSThread currentThread]);
    semaphoreLock = dispatch_semaphore_create(1);
    // queue1 代表北京火车票售卖窗口
    dispatch_queue_t queue1 = dispatch_queue_create("net.bujige.testQueue1", DISPATCH_QUEUE_SERIAL);
    // queue2 代表上海火车票售卖窗口
    dispatch_queue_t queue2 = dispatch_queue_create("net.bujige.testQueue2", DISPATCH_QUEUE_SERIAL);
    kWeakSelf(self);
    dispatch_async(queue1, ^{
        [weakself saleTicketSafe];
    });
    dispatch_async(queue2, ^{
        [weakself saleTicketSafe];
    });
     NSLog(@"semaphore end，当前线程==%@",[NSThread currentThread]);
}
/**
 * 售卖火车票(线程安全)
 */
- (void)saleTicketSafe {
    while (1) {
        // 相当于加锁
        dispatch_semaphore_wait(semaphoreLock, DISPATCH_TIME_FOREVER);
        if (ticketSurplusCountSafe > 0) { //如果还有票，继续售卖
           ticketSurplusCountSafe--;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%d 窗口：%@", ticketSurplusCountSafe, [NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.5];
        } else { //如果已卖完，关闭售票窗口
            NSLog(@"所有火车票均已售完");
            // 相当于解锁
            dispatch_semaphore_signal(semaphoreLock);
            break;
        }
        // 相当于解锁
        dispatch_semaphore_signal(semaphoreLock);
    }
}

- (void)saleTicketSafe1{
    while (1) {
        
        //互斥锁
        @synchronized(self){//没有这句同步锁，票数将会重复出现相同余票
            if (ticketSurplusCountSafe > 0) {
                ticketSurplusCountSafe--;
                NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%d 窗口：%@", ticketSurplusCountSafe, [NSThread currentThread]]);
                [NSThread sleepForTimeInterval:0.5];
            } else {
                NSLog(@"所有火车票均已售完");
                break;
            }
        }
    }
}

@end
