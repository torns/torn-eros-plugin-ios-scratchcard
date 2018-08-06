//
//  TRScratchcardComponent.m
//  WeexEros
//
//  Created by torn on 2018/7/30.
//  Copyright © 2018年 torn. All rights reserved.
//

#import "TRScratchcardComponent.h"
#import <WeexPluginLoader/WeexPluginLoader/WeexPluginLoader.h>

WX_PlUGIN_EXPORT_COMPONENT(tr-scratchcard, TRScratchcardComponent)

@interface TRScratchcardComponent ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation TRScratchcardComponent
- (instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance
{
    self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance];
    return self;
}
- (UIView *) loadView
{
    return self.imageView;
}
@end
