//
//  BLFWeChatTagView.m
//  WeChatTagViewDemo
//
//  Created by kuailegongchang on 17/3/14.
//  Copyright © 2017年 kuailegongchang. All rights reserved.
//

#import "BLFWeChatTagView.h"

static const CGFloat kBLFWeChatTagViewLabelTFSpacing = 10;
static const NSInteger kBLFWeChatTagViewMaxLength = 5;

//-***************************************************************************************

@interface NovelTagLabel : UILabel

+ (instancetype)labelWithFrame:(CGRect)frame content:(NSString *)content;

@property (nonatomic,assign) BOOL isSelected;

@end

//------------------------

@implementation NovelTagLabel

+ (instancetype)labelWithFrame:(CGRect)frame content:(NSString *)content {
    NovelTagLabel *label = [[NovelTagLabel alloc] initWithFrame:frame];
    label.layer.cornerRadius = 5;
    label.layer.masksToBounds = YES;
    label.layer.borderColor = [UIColor orangeColor].CGColor;
    label.layer.borderWidth = 1;
    label.text = [NSString stringWithFormat:@"  %@  ",content];
    label.textColor = [UIColor orangeColor];
    [label sizeToFit];
    return label;
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    if (isSelected) {
        self.textColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor orangeColor];
    }else {
        self.textColor = [UIColor orangeColor];
        self.backgroundColor = [UIColor clearColor];
    }
}

@end


//-***************************************************************************************

@class DeletableTextField;
@protocol DeletableTextFieldDelegate <NSObject>

@optional
- (void)didClickDeleteBtnForTextField:(DeletableTextField *)textField;

@end

@interface DeletableTextField : UITextField

@property (nonatomic,weak) id<DeletableTextFieldDelegate> deleteDelegate;

@end

//------------------------

@implementation DeletableTextField

- (void)deleteBackward {
    if (_deleteDelegate && [_deleteDelegate respondsToSelector:@selector(didClickDeleteBtnForTextField:)]) {
        [_deleteDelegate didClickDeleteBtnForTextField:self];
    }
    [super deleteBackward];
}

@end

//-***************************************************************************************

@interface BLFWeChatTagView ()<UITextFieldDelegate,DeletableTextFieldDelegate>

@property (nonatomic,strong) DeletableTextField *mainTF;
@property (nonatomic,strong) NSMutableArray<NovelTagLabel *> *tagLabelArr;

@end

//------------------------

@implementation BLFWeChatTagView

#pragma mark ---- lazy load
- (UITextField *)mainTF {
    if (nil == _mainTF) {
        _mainTF = [[DeletableTextField alloc] initWithFrame:CGRectMake(10, 10, 120, 20)];
        _mainTF.placeholder = @"五个汉字以内";
        _mainTF.delegate = self;
        _mainTF.deleteDelegate = self;
    }
    return _mainTF;
}

- (NSMutableArray *)tagLabelArr {
    if (nil == _tagLabelArr) {
        _tagLabelArr = [NSMutableArray array];
    }
    return _tagLabelArr;
}

- (NSMutableArray *)tagStringArr {
    if (nil == _tagStringArr) {
        _tagStringArr = [NSMutableArray array];
    }
    for (NovelTagLabel *tagLab in self.tagLabelArr) {
        [_tagStringArr addObject:tagLab.text];
    }
    return _tagStringArr;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createView];
    }
    return self;
}

#pragma mark ---- local method
- (void)createView {
    [self addSubview:self.mainTF];
}

- (void)createLabelWithString:(NSString *)labelContent {
    NovelTagLabel *lab = [NovelTagLabel labelWithFrame:_mainTF.frame content:labelContent];
    [self addSubview:lab];
    
    [self.tagLabelArr addObject:lab];
}

- (void)refreshTF {
    _mainTF.text = @"";
    CGFloat lastX = 0;
    CGFloat lastY = 0;
    if (self.tagLabelArr.count > 0) {
        lastX = CGRectGetMaxX([self.tagLabelArr lastObject].frame);
        lastY = CGRectGetMinY([self.tagLabelArr lastObject].frame) - 10;
    }
    if (CGRectGetWidth(self.frame) - lastX < 130) {
        lastX = 0;
        lastY += 30;
        if (_delegate && [_delegate respondsToSelector:@selector(tagView:currentHeight:)]) {
            [_delegate tagView:self currentHeight:lastY + 30];
        }
    }
    
    _mainTF.frame = CGRectMake(lastX + kBLFWeChatTagViewLabelTFSpacing, lastY + kBLFWeChatTagViewLabelTFSpacing, 120, 20);
}

#pragma mark ---- UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField.text.length > kBLFWeChatTagViewMaxLength) {
        NSLog(@"buneng chaoguo 5 ge zi");
        return NO;
    }
    if (textField.text.length == 0) {
        NSLog(@"buneng 为空");
        return NO;
    }
    
    [self createLabelWithString:textField.text];
    [self refreshTF];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (self.tagLabelArr.count > 0) {
        NovelTagLabel *lab = [self.tagLabelArr lastObject];
        if (lab.isSelected) {
            lab.isSelected = NO;
        }
    }

    if (textField.text.length > kBLFWeChatTagViewMaxLength) {
        textField.text = [textField.text substringToIndex:kBLFWeChatTagViewMaxLength];
        NSLog(@"chaoguo 5 ge zi");
    }
    return YES;
}

- (void)didClickDeleteBtnForTextField:(DeletableTextField *)textField {
    if ([textField.text isEqualToString:@""]) {
        if (self.tagLabelArr.count > 0) {
            NovelTagLabel *lab = [self.tagLabelArr lastObject];
            if (lab.isSelected) {
                [lab removeFromSuperview];
                [self.tagLabelArr removeObject:lab];
                [self refreshTF];
            }else {
                lab.isSelected = YES;
            }
        }
    }
}

@end
