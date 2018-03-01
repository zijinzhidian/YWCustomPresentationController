//
//  CustomPresentationController.m
//  YWCustomPresentationController
//
//  Created by apple on 2018/2/28.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "CustomPresentationController.h"

@interface CustomPresentationController ()
@property(nonatomic,strong)UIView *dimmingView;
@property(nonatomic,strong)UIView *presentationWrappingView;
@end

@implementation CustomPresentationController

#pragma mark - Init
- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController {
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if (self) {
        
        presentedViewController.modalPresentationStyle = UIModalPresentationCustom;
        [self defaultInitail];
        
    }
    return self;
}

- (void)defaultInitail {
    self.direction = PresentationDirectionBottom;
    self.animationDuration = 0.35;
    self.shadowOffset = CGSizeMake(0, -3);
    self.shadowColor = [UIColor blackColor];
    self.dimmingAlpha = 0.5;
}

#pragma mark - Private Actions
- (void)dimmingViewTapped:(UITapGestureRecognizer *)tap {
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
}

- (UIEdgeInsets)edgeInsetsForView:(BOOL)isPresentationRoundedCornerView {
    
    CGFloat direction = isPresentationRoundedCornerView ? -1 : 1;
    
    switch (self.direction) {
        case PresentationDirectionTop:
            return UIEdgeInsetsMake(direction * self.radius, 0, 0, 0);
            break;
            
        case PresentationDirectionLeft:
            return UIEdgeInsetsMake(0, direction * self.radius, 0, 0);
            break;
            
        case PresentationDirectionBottom:
            return UIEdgeInsetsMake(0, 0, direction * self.radius, 0);
            break;
            
        case PresentationDirectionRight:
            return UIEdgeInsetsMake(0, 0, 0, direction * self.radius);
            break;
            
    }
}

#pragma mark - UIPresentationController Actions
//返回需要展示的视图(默认为presentedViewController.view)
- (UIView *)presentedView {
    
    //Return the wrapping view created in -presentationTransitionWillBegin.
    return self.presentationWrappingView;
    
}

//跳转将要开始
- (void)presentationTransitionWillBegin {
    
    //需要展示的控制器视图,即self.presentedViewController.view
    UIView *presentedViewControllerView = [super presentedView];
    
    // presentationWrapperView                      <- shadow
    //   |- presentationRoundedCornerView           <- rounded corners
    //      |- presentedViewControllerWrapperView
    //          |- presentedViewControllerView      <- presentedViewController.view
    {
        //阴影视图
        UIView *presentationWrapperView = [[UIView alloc] initWithFrame:self.frameOfPresentedViewInContainerView];
        presentationWrapperView.layer.shadowOpacity = self.shadowOpacity;
        presentationWrapperView.layer.shadowColor = self.shadowColor.CGColor;
        presentationWrapperView.layer.shadowOffset = self.shadowOffset;
        self.presentationWrappingView = presentationWrapperView;
        
        //圆角视图
        UIView *presentationRoundedCornerView = [[UIView alloc] initWithFrame:UIEdgeInsetsInsetRect(presentationWrapperView.bounds, [self edgeInsetsForView:YES])];
        presentationRoundedCornerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        presentationRoundedCornerView.layer.cornerRadius = self.radius;
        presentationRoundedCornerView.layer.masksToBounds = YES;
        
        //适应用于圆角多出部分的视图
        UIView *presentedViewControllerWrapperView = [[UIView alloc] initWithFrame:UIEdgeInsetsInsetRect(presentationRoundedCornerView.bounds, [self edgeInsetsForView:NO])];
        presentedViewControllerWrapperView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        // Add presentedViewControllerView -> presentedViewControllerWrapperView.
        presentedViewControllerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        presentedViewControllerView.frame = presentedViewControllerWrapperView.bounds;
        [presentedViewControllerWrapperView addSubview:presentedViewControllerView];
        
        // Add presentedViewControllerWrapperView -> presentationRoundedCornerView.
        [presentationRoundedCornerView addSubview:presentedViewControllerWrapperView];
        
        // Add presentationRoundedCornerView -> presentationWrapperView.
        [presentationWrapperView addSubview:presentationRoundedCornerView];
        
    }
    
    //添加蒙版视图
    {
        UIView *dimmingView = [[UIView alloc] initWithFrame:self.containerView.bounds];
        dimmingView.backgroundColor = [UIColor blackColor];
        dimmingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [dimmingView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dimmingViewTapped:)]];
        self.dimmingView = dimmingView;
        [self.containerView addSubview:dimmingView];
    }
    
    //同步动画
    {
        self.dimmingView.alpha = 0;
        
        //self.presentingViewController.transitionCoordinator和self.presentedViewController.transitionCoordinator为同一对象
        [self.presentingViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            self.dimmingView.alpha = self.dimmingAlpha;
        } completion:NULL];
    }
}

//跳转完成
- (void)presentationTransitionDidEnd:(BOOL)completed {
    
    //判断跳转动画是否完成,因为动画可能会被取消
    if (!completed) {
        self.presentationWrappingView = nil;
        self.dimmingView = nil;
    }
    
}

//dismiss将要开始
- (void)dismissalTransitionWillBegin {
    
    [self.presentingViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.dimmingView.alpha = 0;
    } completion:NULL];
    
}

//dismiss完成
- (void)dismissalTransitionDidEnd:(BOOL)completed {
    if (completed) {
        self.presentationWrappingView = nil;
        self.dimmingView = nil;
    }
}



//被呈现的view的过渡动画之后的最终位置,是由UIPresentationViewController来负责定义的。我们重载frameOfPresentedViewInContainerView方法来定义这个最终位置
- (CGRect)frameOfPresentedViewInContainerView {
    
    CGRect containerViewBounds = self.containerView.bounds;
    CGSize presentedViewContentSize = [self sizeForChildContentContainer:self.presentedViewController withParentContainerSize:containerViewBounds.size];
    
    CGRect presentedViewControllerFrame = containerViewBounds;
    switch (self.direction) {
        case PresentationDirectionBottom:
            presentedViewControllerFrame.size.height = presentedViewContentSize.height;
            presentedViewControllerFrame.origin.y = CGRectGetMaxY(containerViewBounds) - presentedViewContentSize.height;
            break;
            
        case PresentationDirectionLeft:
            presentedViewControllerFrame.size.width = presentedViewContentSize.width;
            break;
            
        case PresentationDirectionTop:
            presentedViewControllerFrame.size.height = presentedViewContentSize.height;
            break;
            
        case PresentationDirectionRight:
            presentedViewControllerFrame.size.width = presentedViewContentSize.width;
            presentedViewControllerFrame.origin.x = CGRectGetMaxX(containerViewBounds) - presentedViewContentSize.width;
            break;
    }
    return presentedViewControllerFrame;
    
}

//自动布局子视图时调用,屏幕旋转时重新布局
- (void)containerViewWillLayoutSubviews {
    [super containerViewWillLayoutSubviews];
    
    self.dimmingView.frame = self.containerView.bounds;
    self.presentationWrappingView.frame = self.frameOfPresentedViewInContainerView;
    
}

#pragma mark - UIContentContainer
//当preferredContentSize的值改变时调用,并会在presentationTransitionWillBegin之前调用
- (void)preferredContentSizeDidChangeForChildContentContainer:(id<UIContentContainer>)container {
    [super preferredContentSizeDidChangeForChildContentContainer:container];
    
    if (container == self.presentedViewController) {
        [self.containerView setNeedsLayout];
    }
    
}

//设置childrenViewController.view的size(默认返回ParentViewController.view的size)
- (CGSize)sizeForChildContentContainer:(id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
    
    //判断是否为目标控制器,若是则返回自定义的size,否则返回默认的parentSize
    if (container == self.presentedViewController) {
        return container.preferredContentSize;
    } else {
        return [super sizeForChildContentContainer:container withParentContainerSize:parentSize];
    }
    
}

#pragma mark - UIViewControllerTransitioningDelegate
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    
    return self;
    
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    
    return self;
    
}

- (nullable UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(nullable UIViewController *)presenting sourceViewController:(UIViewController *)source {
    
    return self;
    
}

#pragma mark - UIViewControllerAnimatedTransitioning
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return [transitionContext isAnimated] ? self.animationDuration : 0;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = transitionContext.containerView;
    
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    
    //判断是presentation还是dismissal
    BOOL isPresentation = (toViewController.presentingViewController == fromViewController);
    
    //This will be the current frame of fromViewController.view
    CGRect __unused fromViewInitialFrame = [transitionContext initialFrameForViewController:fromViewController];
    //For a presentation which removes the presenter's view, this will be CGRectZero
    //Otherwise, the current frame of fromViewController.view
    CGRect fromViewFinalFrame = [transitionContext finalFrameForViewController:fromViewController];
    //Thie will be CGRectZero
    CGRect toViewInitialFrame = [transitionContext initialFrameForViewController:toViewController];
    // For a presentation, this will be the value returned from the
    // presentation controller's -frameOfPresentedViewInContainerView method.
    CGRect toViewFinalFrame = [transitionContext finalFrameForViewController:toViewController];
    
    [transitionContext.containerView addSubview:toView];
  
    if (isPresentation) {
        
        switch (self.direction) {
            case PresentationDirectionBottom:
                toViewInitialFrame.origin = CGPointMake(CGRectGetMinX(containerView.bounds), CGRectGetMaxY(containerView.bounds));
                break;
                
            case PresentationDirectionTop:
                toViewInitialFrame.origin = CGPointMake(CGRectGetMinX(containerView.bounds), -CGRectGetMaxY(containerView.bounds));
                break;
                
            case PresentationDirectionLeft:
                toViewInitialFrame.origin = CGPointMake(-CGRectGetMaxX(containerView.bounds), CGRectGetMinX(containerView.bounds));
                break;
                
            case PresentationDirectionRight:
                toViewInitialFrame.origin = CGPointMake(CGRectGetMaxX(containerView.bounds), CGRectGetMinX(containerView.bounds));
                break;
        }
        toViewInitialFrame.size = toViewFinalFrame.size;
        toView.frame = toViewInitialFrame;
        
    } else {
        
        switch (self.direction) {
            case PresentationDirectionBottom:
                fromViewFinalFrame = CGRectOffset(fromView.frame, 0, CGRectGetHeight(fromView.frame));
                break;
                
            case PresentationDirectionTop:
                fromViewFinalFrame = CGRectOffset(fromView.frame, 0, -CGRectGetHeight(fromView.frame));
                break;
                
            case PresentationDirectionLeft:
                fromViewFinalFrame = CGRectOffset(fromView.frame, -CGRectGetWidth(fromView.frame), 0);
                break;
                
            case PresentationDirectionRight:
                fromViewFinalFrame = CGRectOffset(fromView.frame, CGRectGetWidth(fromView.frame), 0);
                break;
        }
        
    }
    
    //获取动画时长
    NSTimeInterval transitionDuration = [self transitionDuration:transitionContext];
    
    //动画逻辑
    [UIView animateWithDuration:transitionDuration animations:^{
        
        if (isPresentation) {
            toView.frame = toViewFinalFrame;
        } else {
            fromView.frame = fromViewFinalFrame;
        }
        
    } completion:^(BOOL finished) {
        
        BOOL wasCancelled = [transitionContext transitionWasCancelled];
        [transitionContext completeTransition:!wasCancelled];
        
    }];
    
}

@end
