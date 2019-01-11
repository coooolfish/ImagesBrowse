//
//  ViewController.m
//  bigDemo
//
//  Created by nd on 2019/1/9.
//  Copyright © 2019 ND. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"
#import "ImagePreviewView.h"

@interface ViewController (){
//    UIImageView *imageView ;
    
    UIView *contentView;
    
    NSArray *imageNames;
    
    NSMutableArray *imageViewList;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CGFloat itemWidth = ([UIScreen mainScreen].bounds.size.width - 50)/3.0;
    
    imageNames = @[@"testtest.jpg",@"timg2.jpg",@"timg3.jpg",@"timg4.jpg",@"timg5.jpg",@"timg6.jpg",@"timg7.jpg",@"timg8.jpg",@"timg9.jpg"];
//     imageNames = @[@"timg1.jpg"];
    imageViewList = [NSMutableArray array];
    for (NSInteger i = 0; i<imageNames.count; i++) {
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15+(i%3)*itemWidth+10*((i%3)), 100+10+(i/3)+((i/3)*itemWidth), itemWidth , itemWidth)];
        imageView.userInteractionEnabled = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.backgroundColor = [UIColor clearColor];
        imageView.image = [UIImage imageNamed:imageNames[i]];
        [self.view addSubview:imageView];
        imageView.tag = 100+i;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [imageView addGestureRecognizer:singleTap];
        
        [imageViewList addObject:imageView];
    }
    
    
   
}

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
    
    [ImagePreviewView showImagePreviewView:gestureRecognizer.view images:imageNames imageViews:imageViewList index:gestureRecognizer.view.tag-100];
    
}

@end
