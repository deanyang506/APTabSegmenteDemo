//
//  APSegmentedView.h
//  Aipai
//
//  Created by YangWeiChang on 2018/7/2.
//  Copyright © 2018年 www.aipai.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, APSegmentedViewLineAnimationType) {
    APSegmentedViewLineAnimationTypeFlexible = 0,       ///<伸缩方式
    APSegmentedViewLineAnimationTypeSlide = 1,          ///<滑动方式
};

@interface APSegmentedViewConfig : NSObject
+ (instancetype)defaultConfig;
@property UIFont *normalFont;               ///<正常状态字体
@property UIFont *selectedFont;             ///<选中状态字体
@property UIColor *normalColor;             ///<正常状态字体颜色
@property UIColor *selectedColor;           ///<选中状态字体颜色
@property CGFloat btnWidth;                 ///<按钮宽度（0是自动，默认）
@property CGFloat btnHeight;                ///<按钮高度
@property CGFloat btnInterSpace;            ///<按钮间距
@property CGFloat lineWidth;                ///<线条宽度（跟随按钮大小0，具体宽度值）
@property CGFloat lineHeight;               ///<线条高度
@property UIColor *lineColor;               ///<线条颜色
@property BOOL lineAnimationEnable;         ///<线条动画（默认是YES）
///线条动画类型 默认：APSegmentedViewLineAnimationTypeFlexible
@property APSegmentedViewLineAnimationType lineAnimationType;
@end

@interface APSegmentedView : UIView

@property (nonatomic, assign, readonly) NSInteger selectedIndex;

- (instancetype)init DEPRECATED_ATTRIBUTE;
- (instancetype)initWithTabs:(NSArray<NSString *> *)tabs;
- (instancetype)initWithTabs:(NSArray<NSString *> *)tabs config:(APSegmentedViewConfig *)config;

- (void)autoSegmenteWitScrollView:(UIScrollView *)scrollView;
- (void)setScrollViewWillBeginDragging;

/**
 即将要选中的按钮索引，选中进度0~1
 */
- (void)buttonWillSelectedIndex:(NSInteger)index percent:(float)percent;
- (void)setSelectedIndexChange:(NSInteger)selectedIndex;

@property (nonatomic, copy) void (^onSelectedIndexChanged)(NSInteger index);

@end
