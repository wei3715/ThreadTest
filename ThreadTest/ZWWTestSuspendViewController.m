//
//  ZWWTestSuspendViewController.m
//  ThreadTest
//
//  Created by mac on 2018/5/24.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ZWWTestSuspendViewController.h"

@interface ZWWTestSuspendViewController ()

@property (nonatomic, strong) NSOperationQueue   *queue;

@end

@implementation ZWWTestSuspendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(NSOperationQueue *)queue{
    if (!_queue) {
        _queue = [[NSOperationQueue alloc]init];
    }
    return _queue;
}

- (IBAction)createOperation:(id)sender {
    //设置最大并发量
    self.queue.maxConcurrentOperationCount = 2;
    for (NSInteger i = 0; i<10; i++) {
        NSInvocationOperation *invoOperation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(downImage) object:nil];
        [self.queue addOperation:invoOperation];
    }
}


- (void)downImage{
    [NSThread sleepForTimeInterval:1.0];
    NSLog(@"下载图片1，当前线程==%@",[NSThread currentThread]);
}

//暂停/继续
//点击：挂起，并不会马上停止打印任务，正在执行的操作不会暂停，而是暂停未开启的任务
- (IBAction)pauseAndStart:(id)sender {
    if (self.queue.operationCount == 0) {//当任务全部取消时，不再执行挂起状态改变等操作
        return;
    }
     self.queue.suspended = !self.queue.suspended;
}


//取消所有任务：如果点击取消，停止打印。然后再重新点击打印次数是10次，证明取消任务成功
//会立刻停止任务
- (IBAction)cancel:(id)sender {
    [self.queue cancelAllOperations];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
