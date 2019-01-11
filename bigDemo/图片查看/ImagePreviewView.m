//
//  ImagePreviewView.m
//  bigDemo
//
//  Created by nd on 2019/1/10.
//  Copyright © 2019 ND. All rights reserved.
//

#import "ImagePreviewView.h"

@interface ImagePreviewView()<UIScrollViewDelegate>{
    
}

@property (copy, nonatomic) NSArray *images;
@property (copy, nonatomic) NSArray *imageViews;
@property (assign, nonatomic) NSInteger index;

@property (assign, nonatomic) CGRect convertRect;

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *indexView;
@property (strong, nonatomic) UIPageControl *pageControl;

//@property (strong, nonatomic) UIImageView *scrollviewSelectView;

@end

@implementation ImagePreviewView

- (BOOL)isUrlAddress:(NSString*)url{
    NSString*reg =@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSPredicate*urlPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", reg];
    return [urlPredicate evaluateWithObject:url];
}


+(instancetype)showImagePreviewView:(UIView *)clickView images:(NSArray *)images imageViews:(NSArray *)imageViews index:(NSInteger)index{
    ImagePreviewView *imagePreviewView = [[ImagePreviewView alloc] initWithFrame:_App.window.frame];
    
    imagePreviewView.index = index;
    imagePreviewView.images = images;
    imagePreviewView.imageViews = imageViews;
    imagePreviewView.indexView = clickView;
    
    [imagePreviewView show];
    
    
    return imagePreviewView;
}

-(void)show{
    
    [_App.window.rootViewController.childViewControllers.lastObject performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    
    //坐标转换，记录选中的view在window上的坐标跟大小
    self.convertRect = [_App.window convertRect:self.indexView.frame toView:_App.window];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:_App.window.frame];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.backgroundColor = [UIColor blackColor];
    self.scrollView.delegate = self;
    self.scrollView.bouncesZoom = YES;
    [self addSubview:self.scrollView];
//    self.scrollView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
    self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    //页码控制器
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 40, [UIScreen mainScreen].bounds.size.width, 40)];
    self.pageControl.numberOfPages = self.images.count;
    self.pageControl.currentPage = self.index;
    self.pageControl.hidesForSinglePage = YES;
    self.pageControl.userInteractionEnabled = NO;
    [self addSubview:self.pageControl];
    //创建imageview
    for (NSInteger i=0; i<self.images.count; i++) {
        
        UIScrollView *contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(_SCREENWIDTH*i, 0, _SCREENWIDTH, _SCREENHEIGHT)];
        contentScrollView.tag = 1000+i;
        contentScrollView.delegate = self;
        //设置最大伸缩比例
        contentScrollView.maximumZoomScale=2.0;
        //设置最小伸缩比例
        contentScrollView.minimumZoomScale=1;
        contentScrollView.backgroundColor = [UIColor blackColor];
        [self.scrollView addSubview:contentScrollView];
        
        
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _SCREENWIDTH, _SCREENHEIGHT)];
        if ([self.images[i] isKindOfClass:[UIImage class]]) {
            imageView.image = self.images[i];
        }
        else if ([self.images[i] isKindOfClass:[NSString class]]){
            if ([self isUrlAddress:self.images[i]]) {
                //网络图片
            }
            else{
                imageView.image = [UIImage imageNamed:self.images[i]];
            }
        }
        imageView.backgroundColor = [UIColor yellowColor];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.tag = 100;
        
        UIImage *image = imageView.image;
        CGSize picSize = image.size;
        
        CGRect originRect;
        
        if (picSize.width != 0 && picSize.height != 0) {
            float scaleX = contentScrollView.frame.size.width/picSize.width;
            float scaleY = contentScrollView.frame.size.height/picSize.height;
            if (scaleX > scaleY) {
                float imgViewWidth = picSize.width*scaleY;
                contentScrollView.maximumZoomScale = self.frame.size.width/imgViewWidth;
                originRect = (CGRect){self.frame.size.width/2-imgViewWidth/2,0,imgViewWidth,self.frame.size.height};
            } else  {
                float imgViewHeight = picSize.height*scaleX;
                contentScrollView.maximumZoomScale = self.frame.size.height/imgViewHeight;
                originRect = (CGRect){0,self.frame.size.height/2-imgViewHeight/2,self.frame.size.width,imgViewHeight};
                contentScrollView.zoomScale = 1.0;
            }
            [UIView animateWithDuration:0.4 animations:^{
                imageView.frame = originRect;
            }];
        }
        
        imageView.userInteractionEnabled = YES;
        //双击手势
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureCallback:)];
        doubleTap.numberOfTapsRequired = 2;
        [imageView addGestureRecognizer:doubleTap];
        [contentScrollView addGestureRecognizer:doubleTap];
        [contentScrollView addSubview:imageView];
        //单击手势
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [imageView addGestureRecognizer:singleTap];
        [contentScrollView addGestureRecognizer:singleTap];
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
        contentScrollView.bouncesZoom=YES;
        [contentScrollView setContentSize:imageView.frame.size];
    }
    
    [self.scrollView setContentOffset:CGPointMake(_SCREENWIDTH*self.index, 0) animated:NO];
    [self.scrollView setContentSize:CGSizeMake(_SCREENWIDTH*self.images.count, 0)];
    
    if ([self.indexView isKindOfClass:[UIImageView class]]) {
        self.indexView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    self.indexView.backgroundColor = [UIColor blackColor];
    [self.indexView.superview bringSubviewToFront:self.indexView];
    [UIView animateWithDuration:.3 animations:^{
        self.indexView.frame = _App.window.frame;
    } completion:^(BOOL finished) {
//        [self.indexView setHidden:YES];
        [_App.window addSubview:self];
        self.indexView.frame = self.convertRect;
        if ([self.indexView isKindOfClass:[UIImageView class]]) {
            self.indexView.contentMode = UIViewContentModeScaleAspectFill;
        }
    }];
    
}


/** 计算点击点所在区域frame */
- (CGRect)getRectWithScale:(CGFloat)scale andCenter:(CGPoint)center{
    CGRect newRect = CGRectZero;
    newRect.size.width =  self.frame.size.width/scale;
    newRect.size.height = self.frame.size.height/scale;
    newRect.origin.x = center.x - newRect.size.width * 0.5;
    newRect.origin.y = center.y - newRect.size.height * 0.5;
    
    return newRect;
}
//双击手势
-(void)doubleTapGestureCallback:(UIGestureRecognizer *)gestureRecognizer{

    [_App.window.rootViewController.childViewControllers.lastObject performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    
    UIScrollView *scrollView ;
    
    if ([gestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
        scrollView = (UIScrollView *)gestureRecognizer.view;
    }
    
    scrollView = (UIScrollView *)[self viewWithTag:1000+self.index];
    
    CGFloat zoomScale = scrollView.zoomScale;
    if (zoomScale == scrollView.maximumZoomScale) {
        zoomScale = 0;
        [UIView animateWithDuration:0.35
                         animations:^{
                             scrollView.zoomScale = zoomScale;
                         }];
    } else {
        
        zoomScale = scrollView.maximumZoomScale;
        CGPoint touchPoint = [gestureRecognizer locationInView:[scrollView viewWithTag:100]];
        CGRect newRect = [self getRectWithScale:zoomScale andCenter:touchPoint];
        [scrollView zoomToRect:newRect animated:YES];
        
    }
}
//单击手势
- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer{
    
    self.indexView = self.imageViews[self.index];
    self.convertRect = [_App.window convertRect:self.indexView.frame toView:_App.window];
    
    self.indexView.frame = _App.window.frame;
    [self setHidden:YES];
    if ([self.indexView isKindOfClass:[UIImageView class]]) {
        self.indexView.contentMode = UIViewContentModeScaleAspectFit;
    }
    [self.indexView.superview bringSubviewToFront:self.indexView];
    [UIView animateWithDuration:.3 animations:^{
        self.indexView.frame = self.convertRect;
    } completion:^(BOOL finished) {
        
        if ([self.indexView isKindOfClass:[UIImageView class]]) {
            self.indexView.contentMode = UIViewContentModeScaleAspectFill;
        }
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self removeFromSuperview];
    }];
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView==self.scrollView) {
         self.index = (int)scrollView.contentOffset.x / _SCREENWIDTH;
    }
}
// 滚动停止时，触发该函数
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.scrollView==scrollView) {
        self.pageControl.currentPage = self.index;
    }
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if (self.scrollView==scrollView) {
        return;
    }
    //控制imagview位置
    UIImageView *imageView = (UIImageView *)[scrollView viewWithTag:100];
    
    CGSize boundsSize = scrollView.bounds.size;
    CGRect imgFrame = imageView.frame;
    CGSize contentSize = scrollView.contentSize;
    CGPoint centerPoint = CGPointMake(contentSize.width/2, contentSize.height/2);

    if (imgFrame.size.width <= boundsSize.width) {
        centerPoint.x = boundsSize.width/2;
    }
    if (imgFrame.size.height <= boundsSize.height) {
        centerPoint.y = boundsSize.height/2;
    }
    imageView.center = centerPoint;
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [scrollView viewWithTag:100];
}
@end
