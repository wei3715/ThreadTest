//
//  ViewController.m
//  ThreadTest
//
//  Created by mac on 2018/4/8.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "FirstViewController.h"
@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

//1.测试耗时操作阻塞主线程：打印数字期间，UI主线程中的switch button和UITextView都无法点击
- (IBAction)testBlockThread:(id)sender {
     [self testThread];
}

//7.测试线程间通信
- (IBAction)downloadImag:(id)sender {
    //加载图片是耗时操作会阻塞主线程（UI线程），导致加载图片时UISwitch和UITextView无法点击滑动
   
    //方法1
//    [self performSelector:@selector(loadImag) withObject:nil afterDelay:0];    //在主线程执行， UISwitch和UITextView无法点击滑动
//    [self performSelectorInBackground:@selector(loadImag) withObject:nil];   //放到子线程中去加载图片
    
    //方法2
    [self testDownImg];

}

//加载图片-耗时操作
- (void)loadImag{
    ZWWLog(@"当前线程==%@",[NSThread currentThread]);
    
    NSURL *imagURL1 = [NSURL URLWithString:@"https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=2753165990,2892529492&fm=200&gp=0.jpg"];
    NSData *imgData1 = [NSData dataWithContentsOfURL:imagURL1];
    UIImage *image1 = [UIImage imageWithData:imgData1];
    //UI更新下载子线程中会提示：-[UIImageView setImage:] must be used from main thread only
//    [_showIV setImage:image1];
    
    NSURL *imagURL2 = [NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1523511772126&di=10a69a6a130ddc5e9265b72510aa16bb&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimage%2Fc0%253Dpixel_huitu%252C0%252C0%252C294%252C40%2Fsign%3D1c7d31d2b73eb13550cabffbcf66cdbf%2Ffd039245d688d43f1be38cc8761ed21b0ef43b45.jpg"];
    NSData *imgData2 = [NSData dataWithContentsOfURL:imagURL2];
    UIImage *image2 = [UIImage imageWithData:imgData2];
    
    //图片加载完回到主线程去更新UI
    [self performSelectorOnMainThread:@selector(updataUI:) withObject:@{@"img1":image1,@"img2":image2} waitUntilDone:YES];
    
}

- (void)updataUI:(NSDictionary *)paramDic{
    [_showIV setImage:paramDic[@"img1"]];
    [_showIV2 setImage:paramDic[@"img2"]];
    
}



#pragma 方法实现
//1.测试耗时操作阻塞主线程
- (void)testThread{
    int sum = 0;
    for (int i = 0; i<50000; i++) {
        sum+=i;
        ZWWLog(@"sum==%d",i);
    }
}

//7.测试线程间通信
- (void)testDownImg{
    ZWWLog(@"当前线程==%@",[NSThread currentThread]);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{//在一个新的并发队列中异步下载图片
        ZWWLog(@"开始下载图片，所在线程==%@",[NSThread currentThread]);
        NSURL *imagURL1 = [NSURL URLWithString:@"https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=2753165990,2892529492&fm=200&gp=0.jpg"];
        NSData *imgData1 = [NSData dataWithContentsOfURL:imagURL1];
        UIImage *image1 = [UIImage imageWithData:imgData1];


        NSURL *imagURL2 = [NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1523511772126&di=10a69a6a130ddc5e9265b72510aa16bb&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimage%2Fc0%253Dpixel_huitu%252C0%252C0%252C294%252C40%2Fsign%3D1c7d31d2b73eb13550cabffbcf66cdbf%2Ffd039245d688d43f1be38cc8761ed21b0ef43b45.jpg"];
        NSData *imgData2 = [NSData dataWithContentsOfURL:imagURL2];
        UIImage *image2 = [UIImage imageWithData:imgData2];
        
        [NSThread sleepForTimeInterval:10];

        dispatch_async(dispatch_get_main_queue(), ^{//
            ZWWLog(@"回到主线程,所在线程==%@",[NSThread currentThread]);
            [self.showIV setImage:image1];
            [self.showIV2 setImage:image2];
        });
    });
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
