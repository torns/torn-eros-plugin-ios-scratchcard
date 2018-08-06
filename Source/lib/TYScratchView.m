//
//  TYScratchView.m
//  图片擦除
//
//  Created by 田宇 on 2018/7/7.
//  Copyright © 2018年 田宇. All rights reserved.
//

#import "TYScratchView.h"

@interface TYScratchView()

@property (nonatomic,strong) UIImageView *rewardImageView;
@property (nonatomic,strong) UIImageView *coverImageView;

@property(nonatomic,assign) CGFloat allAreaSize;
@property(nonatomic,assign) CGFloat cleanAreaSize;

@property(nonatomic,assign) BOOL CleanedAll;

@end

#define DEFAULT_COLOR [UIColor blackColor]
#define DEFAULT_SCRATCH_WIDTH 30
#define DEFAULT_AUTO_CLEAN_ALL_SCALE 0.7

@implementation TYScratchView

-(instancetype)initWithCoverImage:(UIImage *)coverImage andRewardImage:(UIImage *)rewardImage{
    if(self = [super init]){
        self.coverImage = coverImage;
        self.rewardImage = rewardImage;
        
    }
    return self;
}

+(instancetype)scratchViewWithCoverImage:(UIImage *)coverImage andRewardImage:(UIImage *)rewardImage{
    return [[self alloc]initWithCoverImage:coverImage andRewardImage:rewardImage];
}

-(instancetype)initWithCoverColor:(UIColor *)coverColor andRewardImage:(UIImage *)rewardImage{
    if(self = [super init]){
        self.coverColor = coverColor;
        self.rewardImage = rewardImage;
    }
    return self;
}

+(instancetype)scratchViewWithCoverColor:(UIColor *)coverColor andRewardImage:(UIImage *)rewardImage{
    return [[self alloc]initWithCoverColor:coverColor andRewardImage:rewardImage];
}

- (void)drawRect:(CGRect)rect {
    if(self.rewardImage != nil){
        _rewardImageView = [[UIImageView alloc]initWithFrame:rect];
        _rewardImageView.image = self.rewardImage;
        [self addSubview:_rewardImageView];
        
        _allAreaSize = rect.size.width * rect.size.height;
        
        if(self.coverImage != nil){
            
        }else if(self.coverColor != nil){
            self.coverImage = [self getImageFromColor:self.coverColor];
        }else{
            self.coverImage = [self getImageFromColor:DEFAULT_COLOR];
        }
        
        _coverImageView = [[UIImageView alloc]initWithFrame:rect];
        _coverImageView.image = self.coverImage;
        [self addSubview:_coverImageView];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:pan];
    }
}

- (UIImage *)getImageFromColor:(UIColor *)color{
    CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

-(void)pan:(UIPanGestureRecognizer *)pan{
    CGPoint curP = [pan locationInView:self];

    CGFloat scratchHW = self.scratchWidth == 0 ? DEFAULT_SCRATCH_WIDTH : self.scratchWidth;
    CGFloat x = curP.x - scratchHW * 0.5;
    CGFloat y = curP.y - scratchHW * 0.5;
    CGRect rect = CGRectMake(x, y, scratchHW, scratchHW);
    
    [self cleanWith:rect];
}

-(void)cleanWith:(CGRect)rect{
    UIGraphicsBeginImageContextWithOptions(_coverImageView.bounds.size, NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [_coverImageView.layer renderInContext:ctx];
    CGContextClearRect(ctx, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    _coverImageView.image = newImage;
    
    _cleanAreaSize += rect.size.width * rect.size.height;
    
    if(self.isAutoCleanAll && !_CleanedAll){
        CGFloat autoCleanAllScale = self.autoCleanAllScale == 0 ? DEFAULT_AUTO_CLEAN_ALL_SCALE : self.autoCleanAllScale;
        
        if([self getDifferentScaleWith:self.coverImage andNewImage:newImage] < autoCleanAllScale){
            [self cleanAll];
        }
    }
}

-(CGFloat)getDifferentScaleWith:(UIImage *)oldImage andNewImage:(UIImage *)newImage{
    NSInteger cursize = 8;
    NSInteger ArrSize = cursize * cursize + 1,a[ArrSize],b[ArrSize],i,j,grey,sum = 0;
    CGSize size = {cursize,cursize};
    
    UIImage * imga = [self reSizeImage:oldImage toSize:size];
    UIImage * imgb = [self reSizeImage:newImage toSize:size];//缩小图片尺寸
    
    a[ArrSize] = 0;
    b[ArrSize] = 0;
    CGPoint point;
    
    for (i = 0 ; i < cursize; i++) {//计算a的灰度
        for (j = 0; j < cursize; j++) {
            point.x = i;
            point.y = j;
            grey = ToGrey([self UIcolorToRGB:[self colorAtPixel:point img:imga]]);
            a[cursize * i + j] = grey;
            a[ArrSize] += grey;
        }
    }
    a[ArrSize] /= (ArrSize - 1);//灰度平均值
    for (i = 0 ; i < cursize; i++) {//计算b的灰度
        for (j = 0; j < cursize; j++) {
            point.x = i;
            point.y = j;
            grey = ToGrey([self UIcolorToRGB:[self colorAtPixel:point img:imgb]]);
            b[cursize * i + j] = grey;
            b[ArrSize] += grey;
        }
    }
    b[ArrSize] /= (ArrSize - 1);//灰度平均值
    for (i = 0 ; i < ArrSize ; i++){
            a[i] = (a[i] < a[ArrSize] ? 0 : 1);
            b[i] = (b[i] < b[ArrSize] ? 0 : 1);
    }
    ArrSize -= 1;
    for (i = 0 ; i < ArrSize ; i++){
        sum += (a[i] == b[i] ? 1 : 0);
    }
    
    NSLog(@"%f",sum * 1.0 / ArrSize);
    return sum * 1.0 / ArrSize;
}

unsigned int ToGrey(unsigned int rgb)//RGB计算灰度
{
    unsigned int blue   = (rgb & 0x000000FF) >> 0;
    unsigned int green  = (rgb & 0x0000FF00) >> 8;
    unsigned int red    = (rgb & 0x00FF0000) >> 16;
    return ( red*38 +  green * 75 +  blue * 15 )>>7;
}

- (unsigned int)UIcolorToRGB:(UIColor*)color//UIColor转16进制RGB
{
    unsigned int RGB,R,G,B;
    RGB = R = G = B = 0x00000000;
    CGFloat r,g,b,a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    R = r * 256 ;
    G = g * 256 ;
    B = b * 256 ;
    RGB = (R << 16) | (G << 8) | B ;
    return RGB;
}

- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize//重新设定图片尺寸
{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return reSizeImage;
}

- (UIColor *)colorAtPixel:(CGPoint)point img:(UIImage*)img{//获取指定point位置的RGB
    // Cancel if point is outside image coordinates
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, img.size.width, img.size.height), point)) { return nil; }
    
    NSInteger   pointX  = trunc(point.x);
    NSInteger   pointY  = trunc(point.y);
    CGImageRef  cgImage = img.CGImage;
    NSUInteger  width   = img.size.width;
    NSUInteger  height  = img.size.height;
    int bytesPerPixel   = 4;
    int bytesPerRow     = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixelData, 1, 1, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    // Draw the pixel we are interested in onto the bitmap context
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    // Convert color values [0..255] to floats [0.0..1.0]
    
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}






-(UIImageView *)getCoverImageView{
    return self.coverImageView;
}
-(UIImageView *)getRewardImageView{
    return self.rewardImageView;
}
-(void)cleanAll{
    _CleanedAll = true;
    CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self cleanWith:rect];
    
    if([self.delegate respondsToSelector:@selector(TYScratchViewIsCleanAll:)]){
        [self.delegate TYScratchViewIsCleanAll:self];
    }
}


@end