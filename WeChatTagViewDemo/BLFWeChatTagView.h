//
//  BLFWeChatTagView.h
//  WeChatTagViewDemo
//
//  Created by kuailegongchang on 17/3/14.
//  Copyright © 2017年 kuailegongchang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLFWeChatTagView;

@protocol BLFWeChatTagViewDelegate <NSObject>

@optional
- (void)tagView:(BLFWeChatTagView *)tagView currentHeight:(CGFloat)height;

@end

@interface BLFWeChatTagView : UIView

@property (nonatomic,weak) id<BLFWeChatTagViewDelegate> delegate;
@property (nonatomic,strong) NSMutableArray *tagStringArr;

@end
