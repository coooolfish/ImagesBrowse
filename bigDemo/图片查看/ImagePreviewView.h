//
//  ImagePreviewView.h
//  bigDemo
//
//  Created by nd on 2019/1/10.
//  Copyright © 2019 ND. All rights reserved.
//

#import <UIKit/UIKit.h>

#define _SCREENHEIGHT [UIScreen mainScreen].bounds.size.height//获取设备屏幕的长
#define _SCREENWIDTH [UIScreen mainScreen].bounds.size.width//获取设备屏幕的宽

#import "AppDelegate.h"
#define _App ((AppDelegate *) [[UIApplication sharedApplication] delegate])

NS_ASSUME_NONNULL_BEGIN

@interface ImagePreviewView : UIView

+(instancetype)showImagePreviewView:(UIView *)clickView images:(NSArray *)images imageViews:(NSArray *)imageViews index:(NSInteger)index;


@end

NS_ASSUME_NONNULL_END
