//
//  ViewController.m
//  WeChatTagViewDemo
//
//  Created by kuailegongchang on 17/3/14.
//  Copyright © 2017年 kuailegongchang. All rights reserved.
//

#import "ViewController.h"
#import "BLFWeChatTagView.h"

@interface ViewController ()<BLFWeChatTagViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor cyanColor];
    
    BLFWeChatTagView *tagView = [[BLFWeChatTagView alloc] initWithFrame:CGRectMake(10, 140, 300, 40)];
    tagView.backgroundColor = [UIColor whiteColor];
    tagView.delegate = self;
    [self.view addSubview:tagView];
}

#pragma mark ----BLFWeChatTagViewDelegate
- (void)tagView:(BLFWeChatTagView *)tagView currentHeight:(CGFloat)height {
    CGRect rect = tagView.frame;
    rect.size.height = height + 20;
    tagView.frame = rect;
    NSLog(@"%@",tagView.tagStringArr);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
