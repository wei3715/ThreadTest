//
//  ZWWSuspendCell.m
//  ThreadTest
//
//  Created by mac on 2018/5/12.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ZWWSuspendCell.h"

@implementation ZWWSuspendCell

- (IBAction)pause:(id)sender {
    
    self.opQueue.suspended = !self.opQueue.suspended;
    
}
- (IBAction)cancel:(id)sender {
    [self.opQueue cancelAllOperations];
}


@end
