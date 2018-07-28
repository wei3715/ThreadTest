//
//  ZWWUseNSOperationViewController.m
//  ThreadTest
//
//  Created by mac on 2018/5/24.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ZWWUseNSOperationViewController.h"

@interface ZWWUseNSOperationViewController ()
@property (nonatomic, strong) NSOperationQueue   *queue;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation ZWWUseNSOperationViewController

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

//操作：1：下载图片1； 2：下载图片2   3：合并两张图片   4：回到主队列更新UI
- (IBAction)createOperation:(id)sender {
    
   // 1：下载图片1
    __block UIImage *image1;
    NSBlockOperation *blockOP1 = [NSBlockOperation blockOperationWithBlock:^{
        NSURL *imagURL1 = [NSURL URLWithString:@"https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=2753165990,2892529492&fm=200&gp=0.jpg"];
        NSData *imageData1 = [NSData dataWithContentsOfURL:imagURL1];
        image1 = [UIImage imageWithData:imageData1];
        ZWWLog(@"下载图片1");
    }];
    
    //2：下载图片2
    __block UIImage *image2;
    NSBlockOperation *blockOP2 = [NSBlockOperation blockOperationWithBlock:^{
        NSURL *imagURL2 = [NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1523511772126&di=10a69a6a130ddc5e9265b72510aa16bb&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimage%2Fc0%253Dpixel_huitu%252C0%252C0%252C294%252C40%2Fsign%3D1c7d31d2b73eb13550cabffbcf66cdbf%2Ffd039245d688d43f1be38cc8761ed21b0ef43b45.jpg"];
        NSData *imageData2 = [NSData dataWithContentsOfURL:imagURL2];
        image2 = [UIImage imageWithData:imageData2];
         ZWWLog(@"下载图片2");
    }];
    
     //3：合并两张图片
    NSBlockOperation *blockOP3 = [NSBlockOperation blockOperationWithBlock:^{
        
        //绘制图片
        CGSize imageSize = CGSizeMake(300, 300);
        UIGraphicsBeginImageContextWithOptions(imageSize, YES, 0);
        
        //将下载好的图片绘制到画布上
        [image1 drawInRect:CGRectMake(0, 0, 300, 150)];
        [image2 drawInRect:CGRectMake(0, 150, 300, 150)];
        
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        ZWWLog(@"绘制新图片");
        
        // 4：回到主队列更新UI
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            self.imageView.image = newImage;
            ZWWLog(@"刷新UI");
        }];
        
    }];
    
    //添加依赖关系
    [blockOP3 addDependency:blockOP1];
    [blockOP3 addDependency:blockOP2];
    
    //实现下载图片异步执行
    [self.queue addOperations:@[blockOP1,blockOP2,blockOP3] waitUntilFinished:NO];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
