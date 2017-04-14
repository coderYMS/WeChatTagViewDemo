//
//  UIView+Extension.h
//  Boluofan
//
//  Created by guojie on 15/8/3.
//  Copyright (c) 2015年 joyworks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extension)
/**
 *  获取origin-x
 */
@property (nonatomic, assign) CGFloat x;
/**
 *  获取origin-y
 */
@property (nonatomic, assign) CGFloat y;
/**
 *  获取size-Width
 */
@property (nonatomic, assign) CGFloat width;
/**
 *  获取size-Height
 */
@property (nonatomic, assign) CGFloat height;
/**
 *  获取size
 */
@property (nonatomic, assign) CGSize size;
/**
 *  获取origin
 */
@property (nonatomic, assign) CGPoint origin;
/**
 *  获取center-X
 */
@property (nonatomic, assign) CGFloat centerX;
/**
 *  获取center-Y
 */
@property (nonatomic, assign) CGFloat centerY;
@end
