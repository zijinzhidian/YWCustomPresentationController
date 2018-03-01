//
//  CustomPresentationController.h
//  YWCustomPresentationController
//
//  Created by apple on 2018/2/28.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import <UIKit/UIKit.h>

//呈现方向
typedef NS_ENUM(NSUInteger, PresentationDirection) {
    
    PresentationDirectionBottom = 0,
    PresentationDirectionTop,
    PresentationDirectionLeft,
    PresentationDirectionRight
    
};

@interface CustomPresentationController : UIPresentationController<UIViewControllerTransitioningDelegate,UIViewControllerAnimatedTransitioning>

//呈现方向,默认为下
@property(nonatomic,assign)PresentationDirection direction;
//动画时长,默认为0.35
@property(nonatomic,assign)NSTimeInterval animationDuration;
//阴影透明度,默认为0
@property(nonatomic,assign)CGFloat shadowOpacity;
//阴影偏移量,默认为(0, -3)
@property(nonatomic,assign)CGSize shadowOffset;
//阴影颜色,默认为黑色
@property(nonatomic,strong)UIColor *shadowColor;
//蒙版透明度,默认为0.5
@property(nonatomic,assign)CGFloat dimmingAlpha;
//圆角大小,默认为0
@property(nonatomic,assign)CGFloat radius;

@end
