//
//  ZWWBaseCell.h
//  ThreadTest
//
//  Created by mac on 2018/5/12.
//  Copyright © 2018年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^BtnClickBlock)(id);

@interface ZWWBaseCell : UITableViewCell

@property (nonatomic, copy) BtnClickBlock  btnClickBlock;
//加载cell  控件
- (void)setup;

//更新cell内容
- (void)updateCellWithParamDic:(NSDictionary *)dic;

@end
