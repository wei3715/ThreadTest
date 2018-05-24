//
//  ViewController+Method.m
//  ThreadTest
//
//  Created by mac on 2018/4/11.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ZWWMainTableViewController+Method.h"
static int count = 100;

@implementation ZWWMainTableViewController (Method)

//2.简单测试多线程场景
- (void)testMoreThreads{
    //获取当前线程名称
    NSLog(@"获取当前线程名称%@",[NSThread currentThread]);
    
    //获取主线程
    NSLog(@"获取主线程%@",[NSThread mainThread]);
    
    //创建子线程1
    NSThread *thread1 = [[NSThread alloc]initWithTarget:self selector:@selector(handleThread) object:nil];
    //给线程起名字方便区分
    thread1.name = @"zww1";
    //设置子线程优先级(0~1)
    thread1.threadPriority = 1;
    //把子线程放入可调度的线程队列中（开始线程）
    [thread1 start];
    
    //创建子线程2
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
        [NSThread detachNewThreadSelector:@selector(handleThread) toTarget:self withObject:nil];
//log：    当前线程名字==<NSThread: 0x604000269640>{number = 3, name = (null)}

    //方法2,默认在主线程执行
    //    [self performSelector:@selector(handleThread) withObject:nil afterDelay:1.0];
    
    //方法3：隐式创建
//    [self performSelectorInBackground:@selector(handleThread) withObject:nil];
//log：    当前线程名字==<NSThread: 0x604000269640>{number = 3, name = (null)}

}

- (void)handleThread{
    NSLog(@"当前线程名字==%@",[NSThread currentThread]);
    
    //在子线程中获取主线程
    //    NSLog(@"子线程中获取主线程名字==%@",[NSThread mainThread]);
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
                NSLog(@"当前剩余票数==%d,当前线程==%@",count,[NSThread currentThread]);
            } else {
                NSLog(@"票已卖完");
                break;
            }
        }
    }
}

//5.GCD测试
//5.1 串行+同步
//不创建新线程，依次按顺序执行，所有任务在主线程上按顺序执行
- (void)GCDSerialSyn{
    // 创建一个串行队列：DISPATCH_QUEUE_SERIAL串行队列的优先级没有主队列优先级高，所以在这个串行队列中开启同步任务不会堵塞主线程
    dispatch_queue_t queue = dispatch_queue_create("com.zoe1", DISPATCH_QUEUE_SERIAL);
    
    NSLog(@"任务开始");
    NSLog(@"当前线程begin==%@",[NSThread currentThread]);
    for (int i = 0; i<10; i++) {
        //同步函数
        dispatch_sync(queue, ^{
            
            NSLog(@"当前打印值==%d,线程==%@",i,[NSThread currentThread]);
            //情况1
            // 下面开启同步造成死锁：因为串行队列中线程是有执行顺序的，需要等上面开启的同步任务执行完毕，才会执行下面开启的同步任务。而上面的同步任务还没执行完，要到下面的大括号才算执行完毕，而下面的同步任务已经在抢占资源了，就会发生死锁。
//            dispatch_sync(queue, ^{
//                NSLog(@"串行队列同步函数嵌套同步操作造成死锁");
//            });
            
            //情况2：
            //开启异步，就会开启一个新的线程,不会阻塞线程
            //串行队列开启同步任务后嵌套异步任务不造成死锁
            dispatch_async(queue, ^{
                NSLog(@"异步任务 %@", [NSThread currentThread]);
            });
        });
    }
    NSLog(@"任务结束");
    NSLog(@"当前线程end==%@",[NSThread currentThread]);
}
//运行结果打印log：
//2018-04-14 15:05:23.434885+0800 ThreadTest[33170:303605] 任务开始
//2018-04-14 15:05:23.435046+0800 ThreadTest[33170:303605] 当前线程==<NSThread: 0x604000071340>{number = 1, name = main}
//2018-04-14 15:05:23.435180+0800 ThreadTest[33170:303605] 当前打印值==0,线程==<NSThread: 0x604000071340>{number = 1, name = main}
//2018-04-14 15:05:23.435322+0800 ThreadTest[33170:303605] 当前打印值==1,线程==<NSThread: 0x604000071340>{number = 1, name = main}
//2018-04-14 15:05:23.435423+0800 ThreadTest[33170:303605] 当前打印值==2,线程==<NSThread: 0x604000071340>{number = 1, name = main}
//2018-04-14 15:05:23.435508+0800 ThreadTest[33170:303605] 当前打印值==3,线程==<NSThread: 0x604000071340>{number = 1, name = main}
//2018-04-14 15:05:23.435595+0800 ThreadTest[33170:303605] 当前打印值==4,线程==<NSThread: 0x604000071340>{number = 1, name = main}
//2018-04-14 15:05:23.435675+0800 ThreadTest[33170:303605] 当前打印值==5,线程==<NSThread: 0x604000071340>{number = 1, name = main}
//2018-04-14 15:05:23.435768+0800 ThreadTest[33170:303605] 当前打印值==6,线程==<NSThread: 0x604000071340>{number = 1, name = main}
//2018-04-14 15:05:23.435884+0800 ThreadTest[33170:303605] 当前打印值==7,线程==<NSThread: 0x604000071340>{number = 1, name = main}
//2018-04-14 15:05:23.435989+0800 ThreadTest[33170:303605] 当前打印值==8,线程==<NSThread: 0x604000071340>{number = 1, name = main}
//2018-04-14 15:05:23.456798+0800 ThreadTest[33170:303605] 当前打印值==9,线程==<NSThread: 0x604000071340>{number = 1, name = main}
//2018-04-14 15:05:23.457058+0800 ThreadTest[33170:303605] 任务结束
//2018-04-14 15:05:23.457155+0800 ThreadTest[33170:303605] 当前线程==<NSThread: 0x604000071340>{number = 1, name = main}

//5.2 串行+异步
//创建一个新线程，该线程上的任务依次按顺序执行，但是该线程以外前后（主队列上任务）的任务和该线程上任务执行顺序不确定
- (void)GCDSerialAsyn{
    // 创建一个串行队列
    dispatch_queue_t queue = dispatch_queue_create("com.zoe2", DISPATCH_QUEUE_SERIAL);
    
    NSLog(@"任务开始");
    NSLog(@"当前线程begin==%@",[NSThread currentThread]);
    for (int i = 0; i<10; i++) {
        //异步函数
        dispatch_async(queue, ^{
            
            NSLog(@"当前打印值==%d,线程==%@",i,[NSThread currentThread]);
            
            // 下面开启同步造成死锁：因为串行队列中线程是有执行顺序的，需要等上面开启的异步任务执行完毕，才会执行下面开启的同步任务。而上面的异步任务还没执行完，要到下面的大括号才算执行完毕，而下面的同步任务已经在抢占资源了，就会发生死锁。
            dispatch_sync(queue, ^{
                NSLog(@"串行队列开启异步任务后嵌套同步任务造成死锁");
            });
            
            
        });
    }
    
    NSLog(@"任务结束");
    NSLog(@"当前线程end==%@",[NSThread currentThread]);
}

//运行结果打印log：
//2018-04-14 14:55:03.993414+0800 ThreadTest[32126:291687] 任务开始
//2018-04-14 14:55:03.993579+0800 ThreadTest[32126:291687] 当前线程==<NSThread: 0x60400007ce80>{number = 1, name = main}
//2018-04-14 14:55:03.994262+0800 ThreadTest[32126:291687] 任务结束
//2018-04-14 14:55:03.994318+0800 ThreadTest[32126:291771] 当前打印值==0,线程==<NSThread: 0x60000007bc80>{number = 3, name = (null)}
//2018-04-14 14:55:03.994475+0800 ThreadTest[32126:291687] 当前线程==<NSThread: 0x60400007ce80>{number = 1, name = main}
//2018-04-14 14:55:03.994495+0800 ThreadTest[32126:291771] 当前打印值==1,线程==<NSThread: 0x60000007bc80>{number = 3, name = (null)}
//2018-04-14 14:55:03.994651+0800 ThreadTest[32126:291771] 当前打印值==2,线程==<NSThread: 0x60000007bc80>{number = 3, name = (null)}
//2018-04-14 14:55:03.994855+0800 ThreadTest[32126:291771] 当前打印值==3,线程==<NSThread: 0x60000007bc80>{number = 3, name = (null)}
//2018-04-14 14:55:03.994966+0800 ThreadTest[32126:291771] 当前打印值==4,线程==<NSThread: 0x60000007bc80>{number = 3, name = (null)}
//2018-04-14 14:55:03.995035+0800 ThreadTest[32126:291771] 当前打印值==5,线程==<NSThread: 0x60000007bc80>{number = 3, name = (null)}
//2018-04-14 14:55:03.995360+0800 ThreadTest[32126:291771] 当前打印值==6,线程==<NSThread: 0x60000007bc80>{number = 3, name = (null)}
//2018-04-14 14:55:03.995645+0800 ThreadTest[32126:291771] 当前打印值==7,线程==<NSThread: 0x60000007bc80>{number = 3, name = (null)}
//2018-04-14 14:55:03.995797+0800 ThreadTest[32126:291771] 当前打印值==8,线程==<NSThread: 0x60000007bc80>{number = 3, name = (null)}
//2018-04-14 14:55:03.996028+0800 ThreadTest[32126:291771] 当前打印值==9,线程==<NSThread: 0x60000007bc80>{number = 3, name = (null)}

//5.3 并发+同步
//不创建新线程，所有任务依次按顺序执行
- (void)GCDConcurrentSyn{
    
    // 创建一个并发队列
    dispatch_queue_t queue = dispatch_queue_create("com.zoe3", DISPATCH_QUEUE_CONCURRENT);
    
    NSLog(@"任务开始");
    NSLog(@"当前线程begin==%@",[NSThread currentThread]);
    for (int i = 0; i<10; i++) {
        //同步函数
        dispatch_sync(queue, ^{
            NSLog(@"当前打印值==%d,线程==%@",i,[NSThread currentThread]);
            
        });
    }
    NSLog(@"任务结束");
    NSLog(@"当前线程end==%@",[NSThread currentThread]);
}
//运行结果打印log：
//2018-04-14 14:59:06.128632+0800 ThreadTest[32519:296159] 任务开始
//2018-04-14 14:59:06.128787+0800 ThreadTest[32519:296159] 当前线程==<NSThread: 0x608000071ac0>{number = 1, name = main}
//2018-04-14 14:59:06.128997+0800 ThreadTest[32519:296159] 当前打印值==0,线程==<NSThread: 0x608000071ac0>{number = 1, name = main}
//2018-04-14 14:59:06.129225+0800 ThreadTest[32519:296159] 当前打印值==1,线程==<NSThread: 0x608000071ac0>{number = 1, name = main}
//2018-04-14 14:59:06.129327+0800 ThreadTest[32519:296159] 当前打印值==2,线程==<NSThread: 0x608000071ac0>{number = 1, name = main}
//2018-04-14 14:59:06.129399+0800 ThreadTest[32519:296159] 当前打印值==3,线程==<NSThread: 0x608000071ac0>{number = 1, name = main}
//2018-04-14 14:59:06.129462+0800 ThreadTest[32519:296159] 当前打印值==4,线程==<NSThread: 0x608000071ac0>{number = 1, name = main}
//2018-04-14 14:59:06.129522+0800 ThreadTest[32519:296159] 当前打印值==5,线程==<NSThread: 0x608000071ac0>{number = 1, name = main}
//2018-04-14 14:59:06.129587+0800 ThreadTest[32519:296159] 当前打印值==6,线程==<NSThread: 0x608000071ac0>{number = 1, name = main}
//2018-04-14 14:59:06.129729+0800 ThreadTest[32519:296159] 当前打印值==7,线程==<NSThread: 0x608000071ac0>{number = 1, name = main}
//2018-04-14 14:59:06.129900+0800 ThreadTest[32519:296159] 当前打印值==8,线程==<NSThread: 0x608000071ac0>{number = 1, name = main}
//2018-04-14 14:59:06.130018+0800 ThreadTest[32519:296159] 当前打印值==9,线程==<NSThread: 0x608000071ac0>{number = 1, name = main}
//2018-04-14 14:59:06.130077+0800 ThreadTest[32519:296159] 任务结束
//2018-04-14 14:59:06.130135+0800 ThreadTest[32519:296159] 当前线程==<NSThread: 0x608000071ac0>{number = 1, name = main}

//5.4 并发+异步（常用）
//创建新线程，不按顺序打印（新建线程和新建线程以外的任务都不按顺序执行）
- (void)GCDConcurrentAsyn{
    
    // 创建一个并发队列
    dispatch_queue_t queue = dispatch_queue_create("com.zoe4", DISPATCH_QUEUE_CONCURRENT);
    
    NSLog(@"任务开始");
    NSLog(@"当前线程begin==%@",[NSThread currentThread]);
    for (int i = 0; i<10; i++) {
        //异步函数
        dispatch_async(queue, ^{            
            NSLog(@"当前打印值==%d,线程==%@",i,[NSThread currentThread]);
        });
    }
    NSLog(@"任务结束");
    NSLog(@"当前线程end==%@",[NSThread currentThread]);
}
//运行结果打印log：
//2018-04-14 15:01:29.947798+0800 ThreadTest[32789:299183] 任务开始
//2018-04-14 15:01:29.948210+0800 ThreadTest[32789:299183] 当前线程==<NSThread: 0x60c00007ddc0>{number = 1, name = main}
//2018-04-14 15:01:29.948363+0800 ThreadTest[32789:299183] 任务结束
//2018-04-14 15:01:29.948450+0800 ThreadTest[32789:299267] 当前打印值==3,线程==<NSThread: 0x604000261840>{number = 6, name = (null)}
//2018-04-14 15:01:29.948451+0800 ThreadTest[32789:299268] 当前打印值==1,线程==<NSThread: 0x6040002614c0>{number = 4, name = (null)}
//2018-04-14 15:01:29.948470+0800 ThreadTest[32789:299269] 当前打印值==0,线程==<NSThread: 0x600000272440>{number = 3, name = (null)}
//2018-04-14 15:01:29.948471+0800 ThreadTest[32789:299266] 当前打印值==2,线程==<NSThread: 0x60c00047bb40>{number = 5, name = (null)}
//2018-04-14 15:01:29.948636+0800 ThreadTest[32789:299183] 当前线程==<NSThread: 0x60c00007ddc0>{number = 1, name = main}
//2018-04-14 15:01:29.948710+0800 ThreadTest[32789:299293] 当前打印值==4,线程==<NSThread: 0x608000263880>{number = 7, name = (null)}
//2018-04-14 15:01:29.948718+0800 ThreadTest[32789:299267] 当前打印值==6,线程==<NSThread: 0x604000261840>{number = 6, name = (null)}
//2018-04-14 15:01:29.948742+0800 ThreadTest[32789:299294] 当前打印值==5,线程==<NSThread: 0x600000272840>{number = 8, name = (null)}
//2018-04-14 15:01:29.948774+0800 ThreadTest[32789:299295] 当前打印值==7,线程==<NSThread: 0x608000267ec0>{number = 9, name = (null)}
//2018-04-14 15:01:29.948812+0800 ThreadTest[32789:299297] 当前打印值==9,线程==<NSThread: 0x600000272700>{number = 11, name = (null)}
//2018-04-14 15:01:29.948814+0800 ThreadTest[32789:299296] 当前打印值==8,线程==<NSThread: 0x6040002611c0>{number = 10, name = (null)}

//队列有5种：主队列，优先级队列也就是全局队列（低，默认，高）,**
//6.1 主队列的同步请求
//同步函数 dispatch_sync : 立刻执行,并且必须等这个函数执行完才能往下执行
//主队列特点:凡是放到主队列中的任务,都会放到主线程中执行..如果主队列发现当前主线程有任务在执行,那么主队列会暂停调度队列中的任务,直到主线程空闲为止
//综合同步函数与主队列各自的特点,不难发现为何会产生死锁的现象,主线程在执行同步函数的时候主队列也暂停调度任务,而同步函数没有执行完就没法往下执行
//阻塞原因: 在主队列开启同步任务，因为主队列是串行队列，里面的线程是有顺序的，先执行完一个线程才执行下一个线程，而主队列始终就只有一个主线程，主线程是不会执行完毕的，因为他是无限循环的，除非关闭应用开发程序。因此在主线程开启一个同步任务，同步任务会想抢占执行的资源，而主线程任务一直在执行某些操作，不肯放手。两个的优先级都很高，最终导致死锁，阻塞线程了。
- (void)testMainQueueSyn{
    //主队列+同步请求=死锁=线程阻塞（viewDidLoad方法未执行完，同步又要求立即执行循环打印任务，造成死锁）
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    NSLog(@"任务开始");
    NSLog(@"当前线程begin==%@",[NSThread currentThread]);
    for (int i = 0; i<10; i++) {
        //同步任务：要求立即执行
        dispatch_sync(mainQueue, ^{
            NSLog(@"当前线程==%@,打印值==%d",[NSThread currentThread],i);
        });
    }
    
    NSLog(@"任务结束");
    NSLog(@"当前线程end==%@",[NSThread currentThread]);
}
////运行结果打印log：crash


//6.1 主队列的异步请求:所有任务在主线程上按顺序执行
//不阻塞原因：主队列开启异步任务，虽然不会开启新的线程，但是他会把异步任务降低优先级，等闲着的时候，就会在主线程上执行异步任务
//serial queue = main_queue 主队列是串行队列（但开辟不了新线程，只有一个主线程），主队列中任务都放在主线程（mainThread）中执行
- (void)testMainQueueAysn{
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    NSLog(@"任务开始");
    NSLog(@"当前线程begin==%@",[NSThread currentThread]);
    for (int i = 0; i<10; i++) {
        //异步任务：不要求立即执行
        dispatch_async(mainQueue, ^{
            NSLog(@"当前线程==%@,打印值==%d",[NSThread currentThread],i);
        });
    }
    
    NSLog(@"任务结束");
    NSLog(@"当前线程end==%@",[NSThread currentThread]);
}
//运行结果打印log：
//2018-04-14 15:08:37.067965+0800 ThreadTest[33170:303605] 任务开始
//2018-04-14 15:08:37.068122+0800 ThreadTest[33170:303605] 当前线程==<NSThread: 0x604000071340>{number = 1, name = main}
//2018-04-14 15:08:37.068231+0800 ThreadTest[33170:303605] 任务结束
//2018-04-14 15:08:37.068626+0800 ThreadTest[33170:303605] 当前线程==<NSThread: 0x604000071340>{number = 1, name = main}
//2018-04-14 15:08:37.068843+0800 ThreadTest[33170:303605] 当前线程==<NSThread: 0x604000071340>{number = 1, name = main},打印值==0
//2018-04-14 15:08:37.068948+0800 ThreadTest[33170:303605] 当前线程==<NSThread: 0x604000071340>{number = 1, name = main},打印值==1
//2018-04-14 15:08:37.069089+0800 ThreadTest[33170:303605] 当前线程==<NSThread: 0x604000071340>{number = 1, name = main},打印值==2
//2018-04-14 15:08:37.069249+0800 ThreadTest[33170:303605] 当前线程==<NSThread: 0x604000071340>{number = 1, name = main},打印值==3
//2018-04-14 15:08:37.069338+0800 ThreadTest[33170:303605] 当前线程==<NSThread: 0x604000071340>{number = 1, name = main},打印值==4
//2018-04-14 15:08:37.069409+0800 ThreadTest[33170:303605] 当前线程==<NSThread: 0x604000071340>{number = 1, name = main},打印值==5
//2018-04-14 15:08:37.069558+0800 ThreadTest[33170:303605] 当前线程==<NSThread: 0x604000071340>{number = 1, name = main},打印值==6
//2018-04-14 15:08:37.069678+0800 ThreadTest[33170:303605] 当前线程==<NSThread: 0x604000071340>{number = 1, name = main},打印值==7
//2018-04-14 15:08:37.069748+0800 ThreadTest[33170:303605] 当前线程==<NSThread: 0x604000071340>{number = 1, name = main},打印值==8
//2018-04-14 15:08:37.069812+0800 ThreadTest[33170:303605] 当前线程==<NSThread: 0x604000071340>{number = 1, name = main},打印值==9



//6.3 全局队列的异步请求
- (void)testGlobalQueueASyn{
    //GCD默认已经创建好了并发队列，不用手动创建
    //全局队列（优先级队列）：是并发队列 第一个参数是优先级（2：高，0：默认，-2：低）
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_TARGET_QUEUE_DEFAULT, 0);
    NSLog(@"任务开始");
//    NSLog(@"当前线程begin==%@",[NSThread currentThread]);
    for (int i = 0; i<10; i++) {
        //异步任务：不要求立即执行
        dispatch_async(globalQueue, ^{
            NSLog(@"当前线程1==%@,打印值==%d",[NSThread currentThread],i);
            
            NSLog(@"当前线程2==%@,打印值==%d",[NSThread currentThread],i);
        });
    }
//
    NSLog(@"任务结束");
//    NSLog(@"当前线程end==%@",[NSThread currentThread]);

//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"回到主线程==%@",[NSThread currentThread]);
//    });
//    __block long sum = 0;
//    dispatch_async(globalQueue, ^{
//        for (int i = 0; i<50000; i++) {
//            NSLog(@"当前线程==%@，打印值==%ld",[NSThread currentThread],i);
//            sum+=i;
//        }
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSLog(@"sum==%ld",sum);
//        });
//    });
    
    
}

//6.4 全局队列的同步请求
- (void)testGlobalQueueSyn{
    //GCD默认已经创建好了并发队列，不用手动创建
    //全局队列（优先级队列）：是并发队列 第一个参数是优先级（2：高，0：默认，-2：低）
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_TARGET_QUEUE_DEFAULT, 0);
    NSLog(@"任务开始");
    NSLog(@"当前线程begin==%@",[NSThread currentThread]);
    for (int i = 0; i<10; i++) {
        //同步任务：要求立即执行
        dispatch_sync(globalQueue, ^{
            NSLog(@"当前线程==%@,打印值==%d",[NSThread currentThread],i);
        });
    }
    
    NSLog(@"任务结束");
    NSLog(@"当前线程end==%@",[NSThread currentThread]);
}

//8.1使用GCD场景1
- (void)useGCD1{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"使用GCD创建单例");
    });
}

//8.2使用GCD场景1
- (void)useGCD2{
    NSLog(@"任务开始,当前线程==%@",[NSThread currentThread]);
//    [self performSelector:@selector(handleThread) withObject:nil afterDelay:2];
    
    //DISPATCH_TIME_NOW  立即开始
    //DISPATCH_TIME_FOREVER 永远
    //NSEC_PER_SEC 秒
    //NSEC_PER_MSEC 毫秒
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2* NSEC_PER_SEC));
    dispatch_after(time, dispatch_get_main_queue(), ^{
        NSLog(@"延迟后打印任务");
    });
}

//8.3使用GCD场景3
- (void)useGCD3{
    
    //创建一个调度组
    dispatch_group_t group = dispatch_group_create();
    
    //获取全局队列
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    //调度组使用情况1
//    dispatch_group_async(group, queue, ^{
//        [NSThread sleepForTimeInterval:2.0];
//        NSLog(@"下载图片1,当前线程==%@",[NSThread currentThread]);
//    });
//
//    dispatch_group_async(group, queue, ^{
//        [NSThread sleepForTimeInterval:1.0];
//        NSLog(@"下载图片2,当前线程==%@",[NSThread currentThread]);
//    });
//
//    dispatch_group_async(group, queue, ^{
//        [NSThread sleepForTimeInterval:3.0];
//        NSLog(@"下载图片3,当前线程==%@",[NSThread currentThread]);
//    });
//
//    //notify通知，所有异步请求完毕后会通知
//    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
//        NSLog(@"下载完毕更新UI,当前线程==%@",[NSThread currentThread]);
//    });
    
    //调度组使用情况2
    //进入队列
    dispatch_group_enter(group);
    dispatch_group_async(group, queue, ^{
        [NSThread sleepForTimeInterval:2.0];
        NSLog(@"下载图片1,当前线程==%@",[NSThread currentThread]);
        //离开队列
        dispatch_group_leave(group);
    });
    
    //进入队列
    dispatch_group_enter(group);
    dispatch_group_async(group, queue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"下载图片2,当前线程==%@",[NSThread currentThread]);
        //离开队列
        dispatch_group_leave(group);
    });
    
    //进入队列
    dispatch_group_enter(group);
    dispatch_group_async(group, queue, ^{
        [NSThread sleepForTimeInterval:3.0];
        NSLog(@"下载图片3,当前线程==%@",[NSThread currentThread]);
        //离开队列
        dispatch_group_leave(group);
    });
    
    //wait 相当于阻塞
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    NSLog(@"下载完毕更新UI,当前线程==%@",[NSThread currentThread]);
    
}

//9.中断  3,4肯定在1，2下面打印，1，2顺序不确定
- (void)barrierGCD{
    dispatch_queue_t queue = dispatch_queue_create("zoe", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        
        [NSThread sleepForTimeInterval:2.0];
        NSLog(@"打印1");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"打印2");
    });
    
    dispatch_barrier_async(queue, ^{
        NSLog(@"中断");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"打印3");
    });
    dispatch_async(queue, ^{
        NSLog(@"打印4");
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
        NSLog(@"任务结束");
    }];
    
    //开启任务,不写下面start，不会执行对应方法
    [operation start];
}

- (void)downImage{
    [NSThread sleepForTimeInterval:1.0];
    NSLog(@"下载图片1，当前线程==%@",[NSThread currentThread]);
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
        NSLog(@"任务2，当前线程==%@",[NSThread currentThread]);
    }];
    
    //添加任务
    [blockOP addExecutionBlock:^{
        NSLog(@"任务3，当前线程==%@",[NSThread currentThread]);
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
        NSLog(@"直接添加block任务，当前线程==%@",[NSThread currentThread]);
    }];
    
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"等同以上NSOperation操作");
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
        NSLog(@"下载图片2");
    }];
    NSBlockOperation *blockOP3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"下载图片3");
    }];
    
    NSBlockOperation *blockOP4 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"更新UI");
    }];
    
    //添加依赖关系 invoOP1依赖blockOP2，blockOP2依赖blockOP3，所以先执行blockOP3
    [blockOP4 addDependency:invoOP1];
    [invoOP1 addDependency:blockOP2];
    [blockOP2 addDependency:blockOP3];
    [self.opQueue addOperations:@[invoOP1,blockOP2,blockOP3,blockOP4] waitUntilFinished:YES];
}


@end
