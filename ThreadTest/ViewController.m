//
//  ViewController.m
//  ThreadTest
//
//  Created by mac on 2018/4/8.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ViewController.h"
#import "ViewController+Method.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *showIV;
@property (weak, nonatomic) IBOutlet UIImageView *showIV2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //1.测试多线程
//    [self testMoreThreads];
    
    //2.测试创建多线程的多种方法
//    [self testCreateThreadMethod];
    
    //3.测试同步锁问题
//    [self testSellTicket];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //测试耗时操作阻塞主线程
//    [self testThread];
    
   
}

//测试线程间通信
- (IBAction)downloadImag:(id)sender {
    //加载图片是耗时操作会阻塞主线程（UI线程），导致加载图片时textView不能滑动
    //放到子线程中去加载图片
    
    [self performSelectorInBackground:@selector(loadImag) withObject:nil];

}

//加载图片-耗时操作
- (void)loadImag{
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
