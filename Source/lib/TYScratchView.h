//
//  TYScratchView.h
//  图片擦除
//
//  Created by 田宇 on 2018/7/7.
//  Copyright © 2018年 田宇. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TYScratchView;
@protocol TYScratchViewDelegate <NSObject>

@optional
-(void)TYScratchViewIsCleanAll:(TYScratchView *)scratchView;
@end

@interface TYScratchView : UIView

@property(nonatomic,strong) UIImage *coverImage;
@property(nonatomic,strong) UIImage *rewardImage;
@property(nonatomic,strong) UIColor *coverColor;

-(instancetype)initWithCoverImage:(UIImage *)coverImage andRewardImage:(UIImage *)rewardImage;
+(instancetype)scratchViewWithCoverImage:(UIImage *)coverImage andRewardImage:(UIImage *)rewardImage;

-(instancetype)initWithCoverColor:(UIColor *)coverColor andRewardImage:(UIImage *)rewardImage;
+(instancetype)scratchViewWithCoverColor:(UIColor *)coverColor andRewardImage:(UIImage *)rewardImage;

@property(nonatomic,assign) CGFloat scratchWidth;
@property(nonatomic,assign) BOOL isAutoCleanAll;
@property(nonatomic,assign) CGFloat autoCleanAllScale;

@property(nonatomic,weak) id<TYScratchViewDelegate> delegate;

-(UIImageView *)getCoverImageView;
-(UIImageView *)getRewardImageView;

-(void)cleanAll;


@end