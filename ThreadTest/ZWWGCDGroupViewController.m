//
//  ZWWGCDGroupViewController.m
//  ThreadTest
//
//  Created by mac on 2018/7/28.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ZWWGCDGroupViewController.h"

@interface ZWWGCDGroupViewController ()

@end

@implementation ZWWGCDGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

//同步+并发
//在当前线程中执行任务，不会开启新线程，执行完一个任务，再执行下一个任务
- (IBAction)SyncAndConcurrent:(id)sender {
    // 创建一个并发队列
    dispatch_queue_t queue = dispatch_queue_create("com.zoe3", DISPATCH_QUEUE_CONCURRENT);
    
    ZWWLog(@"syncConcurrent begin，当前线程==%@",[NSThread currentThread]);
    [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
   
    for (int i = 0; i<5; i++) {
        //同步函数
        dispatch_sync(queue, ^{
            ZWWLog(@"当前打印值==%d,线程==%@",i,[NSThread currentThread]);
            
        });
    }
    ZWWLog(@"syncConcurrent end,当前线程==%@",[NSThread currentThread]);
}

//异步+并发（常用）
//创建新线程，不按顺序打印（新建线程和新建线程以外的任务都不按顺序执行）
- (IBAction)AsyncAndConcurrent:(id)sender {
    
    // 创建一个并发队列
    dispatch_queue_t queue = dispatch_queue_create("com.zoe4", DISPATCH_QUEUE_CONCURRENT);
    
    ZWWLog(@"AsyncConcurrent begin，当前线程==%@",[NSThread currentThread]);
    [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
    
    for (int i = 0; i<5; i++) {
        //异步函数
        dispatch_async(queue, ^{
            ZWWLog(@"当前打印值==%d,线程==%@",i,[NSThread currentThread]);
        });
    }
    
    ZWWLog(@"AsyncConcurrent end，当前线程==%@",[NSThread currentThread]);
}

//同步+串行
- (IBAction)SyncAndSerial:(id)sender {
    // 创建一个串行队列：DISPATCH_QUEUE_SERIAL串行队列的优先级没有主队列优先级高，所以在这个串行队列中开启同步任务不会堵塞主线程
    dispatch_queue_t queue = dispatch_queue_create("com.zoe1", DISPATCH_QUEUE_SERIAL);
    
    ZWWLog(@"syncSerial begin，当前线程==%@",[NSThread currentThread]);
    [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
    for (int i = 0; i<5; i++) {
        //同步函数
        dispatch_sync(queue, ^{
            
            ZWWLog(@"当前打印值==%d,线程==%@",i,[NSThread currentThread]);
            //情况1
            // 下面开启同步造成死锁：因为串行队列中线程是有执行顺序的，需要等上面开启的同步任务执行完毕，才会执行下面开启的同步任务。而上面的同步任务还没执行完，要到下面的大括号才算执行完毕，而下面的同步任务已经在抢占资源了，就会发生死锁。
//            dispatch_sync(queue, ^{
//                ZWWLog(@"串行队列同步函数嵌套同步操作造成死锁");
//            });
            
            //情况2：
            //开启异步，就会开启一个新的线程,不会阻塞线程
            //串行队列开启同步任务后嵌套异步任务不造成死锁
//            dispatch_async(queue, ^{
//                ZWWLog(@"异步任务 %@", [NSThread currentThread]);
//            });
        });
    }
   
    ZWWLog(@"syncSerial end,当前线程==%@",[NSThread currentThread]);
}

//异步+串行
//创建一个新线程，该线程上的任务依次按顺序执行，但是该线程以外前后（主队列上任务）的任务和该线程上任务执行顺序不确定
- (IBAction)AsyncAndSerial:(id)sender {
    
    // 创建一个串行队列
    dispatch_queue_t queue = dispatch_queue_create("com.zoe2", DISPATCH_QUEUE_SERIAL);
    
   
    ZWWLog(@"AsyncSerial begin,当前线程==%@",[NSThread currentThread]);
    [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
    for (int i = 0; i<5; i++) {
        //异步函数
        dispatch_async(queue, ^{
            
            ZWWLog(@"当前打印值==%d,线程==%@",i,[NSThread currentThread]);
            
            
            // 下面开启同步造成死锁：(串行队列中添加同步任务)因为串行队列中线程是有执行顺序的，需要等上面开启的异步任务执行完毕，才会执行下面开启的同步任务。而上面的异步任务还没执行完，要到下面的大括号才算执行完毕，而下面的同步任务已经在抢占资源了，就会发生死锁。
            //            dispatch_sync(queue, ^{
            //                ZWWLog(@"串行队列开启异步任务后嵌套同步任务造成死锁");
            //            });
            
            
        });
    }
    
    ZWWLog(@"AsyncSerial end,当前线程==%@",[NSThread currentThread]);
}


//同步+主队列
//同步函数 dispatch_sync : 立刻执行,并且必须等这个函数执行完才能往下执行
//主队列特点:凡是放到主队列中的任务,都会放到主线程中执行..如果主队列发现当前主线程有任务在执行,那么主队列会暂停调度队列中的任务,直到主线程空闲为止
//综合同步函数与主队列各自的特点,不难发现为何会产生死锁的现象,主线程在执行同步函数的时候主队列也暂停调度任务,而同步函数没有执行完就没法往下执行
//阻塞原因: 在主队列开启同步任务，因为主队列是串行队列，里面的线程是有顺序的，先执行完一个线程才执行下一个线程，而主队列始终就只有一个主线程，主线程是不会执行完毕的，因为他是无限循环的，除非关闭应用开发程序。因此在主线程开启一个同步任务，同步任务会想抢占执行的资源，而主线程任务一直在执行某些操作，不肯放手。两个的优先级都很高，最终导致死锁，阻塞线程了。
- (IBAction)SyncAndMainQueue:(id)sender {
    //主队列+同步请求=死锁=线程阻塞（viewDidLoad方法未执行完，同步又要求立即执行循环打印任务，造成死锁）
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
   
    ZWWLog(@"SyncMainQueue begin，当前线程begin==%@",[NSThread currentThread]);
    [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
    for (int i = 0; i<5; i++) {
        //同步任务：要求立即执行
        dispatch_sync(mainQueue, ^{
            ZWWLog(@"当前线程==%@,打印值==%d",[NSThread currentThread],i);
        });
    }
    
    ZWWLog(@"SyncMainQueue end，当前线程end==%@",[NSThread currentThread]);
}

- (IBAction)AsyncAndMainQueueOtherThread:(id)sender {
    [NSThread detachNewThreadSelector:@selector(SyncAndMainQueue:) toTarget:self withObject:nil];
}

//异步+主队列:所有任务在主线程上按顺序执行
//不阻塞原因：主队列开启异步任务，虽然不会开启新的线程，但是他会把异步任务降低优先级，等闲着的时候，就会在主线程上执行异步任务
//serial queue = main_queue 主队列是串行队列（但开辟不了新线程，只有一个主线程），主队列中任务都放在主线程（mainThread）中执行
- (IBAction)AsyncAndMainQueue:(id)sender {
    
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    ZWWLog(@"AsyncMainQueue begin，当前线程begin==%@",[NSThread currentThread]);
    [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
    for (int i = 0; i<5; i++) {
        //异步任务：不要求立即执行
        dispatch_async(mainQueue, ^{
            ZWWLog(@"当前线程==%@,打印值==%d",[NSThread currentThread],i);
        });
    }

    ZWWLog(@"AsyncMainQueue end，当前线程end==%@",[NSThread currentThread]);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
