//
//  UtilsMacros.h
//  MediaTest
//
//  Created by mac on 2018/5/23.
//  Copyright © 2018年 mac. All rights reserved.
//

#ifndef UtilsMacros_h
#define UtilsMacros_h

#ifdef DEBUG
#define ZWWLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define ZWWLog(...)
#endif


#define kWeakSelf(type)     __weak typeof(type) weak##type = type;
#define KScreenWidth        [[UIScreen mainScreen] bounds].size.width
#define KScreenHeight       [[UIScreen mainScreen] bounds].size.height


#endif /* UtilsMacros_h */
