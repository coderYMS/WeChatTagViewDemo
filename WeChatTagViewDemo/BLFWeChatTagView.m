//
//  BLFWeChatTagView.m
//  WeChatTagViewDemo
//
//  Created by kuailegongchang on 17/3/14.
//  Copyright © 2017年 kuailegongchang. All rights reserved.
//

#import "BLFWeChatTagView.h"
#import "UIView+Extension.h"

static const CGFloat kBLFWeChatTagViewLabelTFSpacing = 10;
static const CGFloat kBLFWeChatTagViewLabelTFMargin = 15;
static const CGFloat kBLFWeChatTagViewTFHeight = 30;

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
    label.layer.borderWidth = 0.5;
    label.text = [NSString stringWithFormat:@"  %@  ",content];
    label.textColor = [UIColor orangeColor];
    label.font = [UIFont systemFontOfSize:14];
    [label sizeToFit];
    label.height = CGRectGetHeight(frame);
    return label;
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    if (isSelected) {
        self.textColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor orangeColor];
    }else {
        self.textColor = [UIColor orangeColor];
        self.backgroundColor = [UIColor whiteColor];
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
@property (nonatomic,strong) UIView *tfBGView;
@property (nonatomic,strong) NSMutableArray<NovelTagLabel *> *tagLabelArr;

@end

//------------------------

@implementation BLFWeChatTagView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createView];
        [self addClickEvent];
    }
    return self;
}

#pragma mark ---- public method
- (void)createInitialTags:(NSArray<NSString *> *)tagStrings {
    for (NSString *tagStr in tagStrings) {
        [self createLabelWithString:tagStr];
        [self refreshTF];
    }
}

- (void)dismissTFKeyboard {
    [_mainTF resignFirstResponder];
}

#pragma mark ---- local method
- (void)createView {
    [self addSubview:self.tfBGView];
    [self addSubview:self.mainTF];
}
- (void)addClickEvent {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickEvent)];
    [self addGestureRecognizer:tap];
}

- (void)createLabelWithString:(NSString *)labelContent {
    NovelTagLabel *lab = [NovelTagLabel labelWithFrame:_mainTF.frame content:labelContent];
    [self addSubview:lab];
    
    [self.tagLabelArr addObject:lab];
    
    if (_delegate && [_delegate respondsToSelector:@selector(tagView:willChangeTagCount:)]) {
        [_delegate tagView:self willChangeTagCount:self.tagLabelArr.count];
    }
}
- (void)deleteLabel {
    if (self.tagLabelArr.count > 0) {
        NovelTagLabel *lab = [self.tagLabelArr lastObject];
        if (lab.isSelected) {
            [lab removeFromSuperview];
            [self.tagLabelArr removeObject:lab];
            
            if (_delegate && [_delegate respondsToSelector:@selector(tagView:willChangeTagCount:)]) {
                [_delegate tagView:self willChangeTagCount:self.tagLabelArr.count];
            }
            
            [self refreshTF];
        }else {
            lab.isSelected = YES;
        }
    }
}

- (BOOL)checkTFStateOK {
    NovelTagLabel *lab = [self.tagLabelArr lastObject];
    if (lab && lab.isSelected) {
        lab.isSelected = NO;
    }
    
    if (self.tagLabelArr.count >= self.maxCount) {
        NSLog(@"最多添加%lu个标签",(unsigned long)_maxCount);
        [self resetTFContent];
        return NO;
    }
    return YES;
}

- (void)refreshTF {
    [self resetTFContent];
    [self resetTextFieldFrame];
}

- (void)resetTFContent {
    _mainTF.text = @"";
    _mainTF.width = 120;
    
    _tfBGView.backgroundColor = [UIColor clearColor];
    _tfBGView.width = 120;
}

- (void)resetTextFieldFrame {
    CGFloat lastX = kBLFWeChatTagViewLabelTFMargin - kBLFWeChatTagViewLabelTFSpacing;
    CGFloat lastY = 0;
    CGFloat width = _mainTF.width;
    if (self.tagLabelArr.count > 0) {
        lastX = CGRectGetMaxX([self.tagLabelArr lastObject].frame);
        lastY = CGRectGetMinY([self.tagLabelArr lastObject].frame) - kBLFWeChatTagViewLabelTFSpacing;
        //如果没标签 就不换行了
        if (CGRectGetWidth(self.frame) - lastX - kBLFWeChatTagViewLabelTFSpacing - kBLFWeChatTagViewLabelTFMargin < width) {
            lastX = kBLFWeChatTagViewLabelTFMargin - kBLFWeChatTagViewLabelTFSpacing;
            lastY += kBLFWeChatTagViewTFHeight + kBLFWeChatTagViewLabelTFSpacing;
            if (_delegate && [_delegate respondsToSelector:@selector(tagView:currentHeight:)]) {
                [_delegate tagView:self currentHeight:lastY + kBLFWeChatTagViewTFHeight + kBLFWeChatTagViewLabelTFSpacing];
            }
        }
    }
    
    _mainTF.frame = CGRectMake(lastX + kBLFWeChatTagViewLabelTFSpacing, lastY + kBLFWeChatTagViewLabelTFSpacing, width, kBLFWeChatTagViewTFHeight);
    _tfBGView.frame = CGRectMake(lastX + kBLFWeChatTagViewLabelTFSpacing, lastY + kBLFWeChatTagViewLabelTFSpacing, width, kBLFWeChatTagViewTFHeight);
}

- (CGFloat)caculateStringLength:(NSString *)str {
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1000, 30)];
    lab.font = [UIFont systemFontOfSize:14];
    lab.text = str;
    [lab  sizeToFit];
    CGFloat resultWidth = lab.width + 20 + 10;//20是给光标留的空白，10是前面的leftview
    lab = nil;
    return resultWidth;
}

#pragma mark ---- btn click
- (void)clickEvent {
    if (![self.mainTF isFirstResponder]) {
        [self.mainTF becomeFirstResponder];
    }
}

#pragma mark ---- UITextFieldDelegate
//这个代理用于处理输入拼音的时候
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    //为了适配sb的搜狗输入法
    if ([textField.text isEqualToString:@""] && [string isEqualToString:@""]) {
        return YES;
    }
    
    if (![self checkTFStateOK]) {
        return NO;
    }
    
    _tfBGView.backgroundColor = [UIColor lightGrayColor];
    
    textField.width = [self caculateStringLength:textField.text];
    [self resetTextFieldFrame];
    
    return YES;
}
//这个事件用于处理形成文字的时候，包括点击键盘推荐字的时候
- (void)textFieldDidChange:(UITextField *)textField {
    
    if (![self checkTFStateOK]) {
        return ;
    }
    
    NSUInteger maxLength = 8;
    NSString *toBeString = textField.text;
    
    //获取高亮部分
    UITextRange *selectedRange = [textField markedTextRange];
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    if (!position) {
        if (toBeString.length > maxLength) {
            NSLog(@"最多输入%ld个字符！",(unsigned long)maxLength);
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:maxLength];
            if (rangeIndex.length == 1) {
                textField.text = [toBeString substringToIndex:maxLength];
            }else {
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, maxLength)];
                textField.text = [toBeString substringWithRange:rangeRange];
            }
            textField.width = [self caculateStringLength:textField.text];
            [self resetTextFieldFrame];
            
        }else if (toBeString.length > 0) {
            _tfBGView.backgroundColor = [UIColor lightGrayColor];
            textField.width = [self caculateStringLength:textField.text];
            [self resetTextFieldFrame];
            
        }else if (toBeString.length == 0) {
            [self refreshTF];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField.text.length == 0) {
        NSLog(@"buneng 为空");
        return NO;
    }
    if (textField.text.length > 8) {
        NSLog(@"最多输入%lu个字符！",(unsigned long)_maxCount);
        return NO;
    }
    if (self.tagLabelArr.count >= self.maxCount) {
        NSLog(@"最多添加%lu个标签",(unsigned long)_maxCount);
        return NO;
    }
    
    [self createLabelWithString:textField.text];
    [self refreshTF];
    return YES;
}

- (void)didClickDeleteBtnForTextField:(DeletableTextField *)textField {
    if ([textField.text isEqualToString:@""]) {
        [self deleteLabel];
        [self resetTFContent];
    }
}

#pragma mark ---- lazy load
- (DeletableTextField *)mainTF {
    if (nil == _mainTF) {
        _mainTF = [[DeletableTextField alloc] initWithFrame:CGRectMake(kBLFWeChatTagViewLabelTFMargin, kBLFWeChatTagViewLabelTFSpacing, 120, kBLFWeChatTagViewTFHeight)];
        _mainTF.placeholder = @"八个汉字以内";
        _mainTF.delegate = self;
        _mainTF.deleteDelegate = self;
        _mainTF.font = [UIFont systemFontOfSize:14];
        _mainTF.textColor = [UIColor blackColor];
        _mainTF.returnKeyType = UIReturnKeyDone;
        [_mainTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        _mainTF.adjustsFontSizeToFitWidth = YES;

        //textfield不顶到左边
        UIView *marginView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, kBLFWeChatTagViewTFHeight)];
        marginView.backgroundColor = [UIColor clearColor];
        _mainTF.leftView = marginView;
        _mainTF.leftViewMode = UITextFieldViewModeAlways;
        
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
    _tagStringArr = [NSMutableArray array];
    for (NovelTagLabel *tagLab in self.tagLabelArr) {
        [_tagStringArr addObject:[tagLab.text substringWithRange:NSMakeRange(2, tagLab.text.length - 4)]];//显示的时候拼了4个空格，要去掉
    }
    return _tagStringArr;
}

- (NSUInteger)maxCount {
    if (_maxCount == 0) {
        _maxCount = INT_MAX;
    }
    return _maxCount;
}

- (UIView *)tfBGView {
    if (nil == _tfBGView) {
        _tfBGView = [[UIView alloc] initWithFrame:self.mainTF.frame];
    }
    return _tfBGView;
}
@end
