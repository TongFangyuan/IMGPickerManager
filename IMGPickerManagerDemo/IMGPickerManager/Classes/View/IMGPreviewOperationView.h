//
//  OperationView.h
//  FYImageManagerDemo
//
//  Created by tongfy on 2017/11/16.
//  Copyright © 2017年 tongfy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMGPreviewOperationView : UIView

@property (nonatomic,strong) UIButton *closedButton;
@property (nonatomic,strong) UIButton *doneButton;
@property (nonatomic,strong) UIButton *numberButton;
@property (nonatomic,strong) UIButton *selectedButton;
@property (nonatomic,strong) UIImageView *topMask;
@property (nonatomic,strong) UIImageView *bottomMask;

- (void)setButtonSelected:(BOOL)selected;

@end
