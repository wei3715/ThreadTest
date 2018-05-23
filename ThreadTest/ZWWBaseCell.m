//
//  ZWWBaseCell.m
//  ThreadTest
//
//  Created by mac on 2018/5/12.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ZWWBaseCell.h"

@implementation ZWWBaseCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
       
        
        [self setup];
    }
    return self;
}

//加载UI
- (void)setup{
    
}


@end
