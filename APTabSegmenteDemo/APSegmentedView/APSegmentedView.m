//
//  APSegmentedView.m
//  Aipai
//
//  Created by YangWeiChang on 2018/7/2.
//  Copyright © 2018年 www.aipai.com. All rights reserved.
//

#import "APSegmentedView.h"
#import "NSObject+FBKVOController.h"

#define scrollPadding       0       ///<scrollView的左右补边

@implementation APSegmentedViewConfig

+ (instancetype)defaultConfig {
    APSegmentedViewConfig *config = [APSegmentedViewConfig new];
    config.normalFont = [UIFont boldSystemFontOfSize:17.0];
    config.selectedFont = [UIFont boldSystemFontOfSize:17.0];
    config.normalColor = [UIColor grayColor];
    config.selectedColor = [UIColor blackColor];
    config.btnWidth = 0;
    config.btnHeight = 37.0f;
    config.btnInterSpace = 34.0f;
    config.lineWidth = 0;
    config.lineHeight = 2.0f;
    config.lineColor = [UIColor redColor];
    config.lineAnimationEnable = YES;
    config.lineAnimationType = APSegmentedViewLineAnimationTypeFlexible;
    return config;
}

@end

@interface APSegmentedView()

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray<UIButton *> *buttons;
@property (nonatomic, strong) UIView *selectedLineView;
@property (nonatomic, strong) UIButton *selectedButton;

@property (nonatomic, strong) APSegmentedViewConfig *config;
@property (nonatomic, weak) UIScrollView *obsScrollView;

@end

@implementation APSegmentedView {
    BOOL _obsScrollViewDragging;
}

- (instancetype)init { return nil; }
- (instancetype)initWithTabs:(NSArray<NSString *> *)tabs config:(APSegmentedViewConfig *)config {
    if (self = [super init]) {
        self.config = config;
        NSMutableArray *btnArray = [NSMutableArray arrayWithCapacity:tabs.count];
        int i = 0;
        for (NSString *title in tabs) {
            UIButton *button = [[UIButton alloc] init];
            [button setTitleColor:config.normalColor forState:UIControlStateNormal];
            [button setTitleColor:config.selectedColor forState:UIControlStateSelected | UIControlStateDisabled];
            if (i == 0) {
                button.titleLabel.font = config.selectedFont;
            } else {
                button.titleLabel.font = config.normalFont;
            }
            [button setTitle:title forState:UIControlStateNormal];
            [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [button sizeToFit];
            [btnArray addObject:button];
            i++;
        }
        _buttons = [btnArray copy];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self layout];
        });
        
    }
    return self;
}

- (instancetype)initWithTabs:(NSArray<NSString *> *)tabs {
    return [self initWithTabs:tabs config:[APSegmentedViewConfig defaultConfig]];
}

- (CGSize)intrinsicContentSize {
    return self.bounds.size;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return self.bounds.size;
}

- (void)layout {
    if (self.buttons.count == 0) {
        return;
    }
    
    [self addSubview:self.scrollView];
    
    for (UIButton *button in self.buttons) {
        [_scrollView addSubview:button];
    }
    
    [_scrollView addSubview:self.selectedLineView];
    
    self.selectedButton = self.buttons[0];
}

- (void)layoutSubviews {
    
    if (_buttons.count > 0) {
        CGFloat totalWidth = 0;
        for (UIButton *button in _buttons) {
            CGRect frame = button.frame;
            
            if (self.config.btnWidth > 0) {
                frame.size.width = self.config.btnWidth;
            }
            
            totalWidth += frame.size.width;
            frame.origin.x = 0;
            frame.origin.y = 0;
            frame.size.height = self.config.btnHeight; // 设置按钮的高度
            button.frame = frame;
        }
        
        // 俩边间距最小为scrollPadding， 俩个按钮之间的间距最小为buttonMinSpace，最大为buttonMaxSpace
        // 计算方式为：得出按钮的总宽度，按最小的间距buttonMinSpace加上，如果俩边剩余大于scrollPadding * 2
        
        NSInteger totoalSpaceCount = _buttons.count - 1; // 俩俩按钮之间，总间距数
        CGFloat needWidth = totalWidth + totoalSpaceCount * self.config.btnInterSpace;
        
        if(self.frame.size.width - needWidth > (scrollPadding * 2)) {
            CGFloat totalSpace = self.frame.size.width - needWidth - (scrollPadding * 2);
            CGFloat space = totalSpace / totoalSpaceCount; // 得出间距
            space  = MIN(space + self.config.btnInterSpace, self.config.btnInterSpace);
            CGFloat x = _buttons[0].frame.size.width;
            for (int i = 1; i < _buttons.count; i++) {
                UIButton *button = _buttons[i];
                CGRect frame = button.frame;
                frame.origin.x = space + x;
                button.frame = frame;
                x += space + frame.size.width;
            }
            
            // 按钮高度 + 线条高度
            _scrollView.contentSize = CGSizeMake(x, self.config.btnHeight + self.config.lineHeight);
            _scrollView.frame = CGRectMake((self.frame.size.width - _scrollView.contentSize.width) * 0.5, 0,
                                           _scrollView.contentSize.width,
                                           _scrollView.contentSize.height);
            
        } else {
            // 如果左右边距不足(scrollPadding * 2)则按最小方式排列
            CGFloat x = scrollPadding;
            for (UIButton *button in _buttons) {
                CGRect frame = button.frame;
                frame.origin.x = x;
                button.frame = frame;
                x += frame.size.width + self.config.btnInterSpace; // 俩个button之间的最小距离为30
            }
            
            // 按钮高度 + 线条高度
            _scrollView.contentSize = CGSizeMake(x, self.config.btnHeight + self.config.lineHeight);
            _scrollView.frame = self.bounds;
        }
    }
    
    [super layoutSubviews];
}

- (void)buttonClicked:(UIButton *)sender {
    if (sender == _selectedButton) {
        return;
    }
    
    // 将选中线条移动到该按钮下面
    [UIView animateWithDuration:self.config.lineAnimationEnable?0.2:0 animations:^{
        CGRect frame = self.selectedLineView.frame;
        frame.origin.x = sender.frame.origin.x;
        if (self.config.lineWidth > 0) {
            frame.size.width = self.config.lineWidth;
        } else {
            frame.size.width = sender.frame.size.width;
        }
        self.selectedLineView.frame = frame;
    } completion:^(BOOL finished) {
        self.selectedButton = sender;
    }];
    
    self.selectedIndex = [self.buttons indexOfObject:sender];
}

#pragma mark - public

- (void)autoSegmenteWitScrollView:(UIScrollView *)scrollView {
    if (self.obsScrollView == scrollView || ![scrollView isKindOfClass:[UIScrollView class]]) {
        return;
    }
    
    self.obsScrollView = scrollView;
    __weak typeof(self) wself = self;
    [self.KVOController observe:self.obsScrollView keyPath:@"contentOffset" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionPrior block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
        __strong typeof(wself) self = wself;
        if (!_obsScrollViewDragging) { // 不是手势拖拽的情况下contentOffset变化不予以处理
            return;
        }
        
        CGPoint contentOffset = self.obsScrollView.contentOffset;
        CGFloat cellWidth = CGRectGetWidth(self.obsScrollView.frame);
        CGFloat crrIndexOffsetX = self.selectedIndex * cellWidth;
        // 判断滑动方向
        if(contentOffset.x > crrIndexOffsetX) { // 往左滑
            float percent = (contentOffset.x - cellWidth * self.selectedIndex) * 1.0 / cellWidth;
            [self buttonWillSelectedIndex:self.selectedIndex + 1 percent:percent];
        } else if(contentOffset.x < crrIndexOffsetX) { // 往右滑
            float percent = (crrIndexOffsetX - contentOffset.x) * 1.0 / cellWidth;
            [self buttonWillSelectedIndex:self.selectedIndex - 1 percent:percent];
        } else {
            [self buttonWillSelectedIndex:self.selectedIndex percent:0];
        }
    }];
}

- (void)setScrollViewWillBeginDragging {
    _obsScrollViewDragging = YES;
}

- (void)buttonWillSelectedIndex:(NSInteger)index percent:(float)percent {
    
    if (index < 0 || index >= self.buttons.count || index == self.selectedIndex) {
        return;
    }
    
    UIButton *wsbtn = [self.buttons objectAtIndex:index];
    if (wsbtn == nil) {
        return;
    }
    
    CGRect frame = self.selectedLineView.frame;
    
    CGFloat targetX,targetRight,targetWidth,orignX,orignRight,orignWidth;
    
    if (self.config.lineWidth > 0) {
        targetX = wsbtn.center.x - self.config.lineWidth * 0.5;
        targetRight = wsbtn.center.x + self.config.lineWidth * 0.5;
        targetWidth = self.config.lineWidth;
        orignX = _selectedButton.center.x - self.config.lineWidth * 0.5;
        orignRight = _selectedButton.center.x + self.config.lineWidth * 0.5;
        orignWidth = self.config.lineWidth;
    } else {
        targetX = wsbtn.frame.origin.x;
        targetRight = wsbtn.frame.origin.x + wsbtn.frame.size.width;
        targetWidth = wsbtn.frame.size.width;
        orignX = _selectedButton.frame.origin.x;
        orignRight = _selectedButton.frame.origin.x + _selectedButton.frame.size.width;
        orignWidth = _selectedButton.frame.size.width;
    }
    
    if (self.config.lineAnimationEnable) {
        switch (self.config.lineAnimationType) {
            case APSegmentedViewLineAnimationTypeFlexible:{
                if (index > self.selectedIndex) { // 往右偏移
                    if (percent <= 0.5) {
                        // 此时x值不变，相应增大width，直到目标右边距
                        CGFloat needChangeWidth = targetRight - orignRight;
                        CGFloat addW = needChangeWidth * (percent / 0.5);
                        frame.size.width = orignWidth + addW;
                        frame.origin.x = orignX;
                    } else {
                        // 往右则加大x,并减小width
                        CGFloat p = (percent - 0.5) / 0.5;
                        CGFloat currentX = orignX + ((targetX - orignX) * p);
                        frame.origin.x = currentX;
                        frame.size.width = targetRight - currentX;
                    }
                } else { // 往左偏移
                    if (percent <= 0.5) {
                        // x值不断减小，width不断变大
                        CGFloat currentX = orignX - (orignX - targetX) * (percent / 0.5);
                        frame.origin.x = MAX(currentX, targetX);
                        frame.size.width = orignRight - frame.origin.x;
                    } else {
                        if (frame.origin.x > targetX) {
                            frame.origin.x = targetX;
                        }
                        // x值不变，width不断减小
                        CGFloat p = (percent - 0.5) / 0.5;
                        CGFloat needChangeWidth = orignRight - targetRight;
                        frame.size.width = (orignRight - targetX) - needChangeWidth * p;
                        frame.origin.x = targetX;
                    }
                }
            }
                break;
            case APSegmentedViewLineAnimationTypeSlide:{
                frame.origin.x = orignX + ((targetX - orignX) * percent);
                frame.size.width = orignWidth + ((targetWidth - orignWidth) * percent);
            }
                break;
            default:
                break;
        }
    }
    
    self.selectedLineView.frame = frame;
    
    if (percent >= 1.0) {
        _selectedIndex = index;
        self.selectedButton = wsbtn;
    }
}

#pragma mark - getter & setter

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    if (selectedIndex == _selectedIndex) {
        return;
    }
    
    if (selectedIndex >= self.buttons.count) {
        return;
    }
    
    [self setSelectedIndexChange:selectedIndex];
    _obsScrollViewDragging = NO;
    self.onSelectedIndexChanged ? self.onSelectedIndexChanged(selectedIndex) : NULL;
}

- (void)setSelectedIndexChange:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    [self buttonClicked:[self.buttons objectAtIndex:selectedIndex]];
}

- (void)setSelectedButton:(UIButton *)selectedButton {
    if (_selectedButton == selectedButton) {
        return;
    }
    
    // 上一个按钮恢复
    {
        _selectedButton.titleLabel.font = self.config.normalFont;
        _selectedButton.enabled = YES;
        _selectedButton.selected = NO;
        [_selectedButton sizeToFit];
        CGRect frame = _selectedButton.frame;
        frame.size.height = self.config.btnHeight;
        _selectedButton.frame = frame;
    }
    
    
    // 赋值新的选中按钮
    {
        _selectedButton = selectedButton;
        _selectedButton.titleLabel.font = self.config.selectedFont ? : self.config.normalFont;
        _selectedButton.enabled = NO;
        _selectedButton.selected = YES;
        
        ///如果按钮宽度自动缩放，因字体改变需要重新设置按钮的frame
        if (self.config.btnWidth == 0) {
            CGSize lSize = _selectedButton.frame.size;
            [_selectedButton sizeToFit];
            CGSize nSize = _selectedButton.frame.size;
            if (lSize.width != nSize.width) {
                [self setNeedsLayout];
                [self layoutIfNeeded];
            } else {
                CGRect frame = _selectedButton.frame;
                frame.size.height = self.config.btnHeight;
                _selectedButton.frame = frame;
            }
        }
    }
    
    ///设置线条的位置
    CGFloat lineWidth = self.config.lineWidth > 0 ? self.config.lineWidth : _selectedButton.frame.size.width;
    CGFloat lineX = _selectedButton.center.x - lineWidth * 0.5;
    CGFloat lineY = CGRectGetMaxY(_selectedButton.frame);
    self.selectedLineView.frame = CGRectMake(lineX, lineY, lineWidth, self.config.lineHeight);
    
    CGFloat scrollWidth = _scrollView.frame.size.width;
    if (scrollWidth > 0) {
        CGFloat offsetX = _selectedButton.center.x - scrollWidth * 0.5;
        CGFloat maxOffsetX = _scrollView.contentSize.width - scrollWidth;
        [UIView animateWithDuration:0.2 animations:^{
            self.scrollView.contentOffset = CGPointMake(MIN(maxOffsetX,MAX(offsetX, 0)), 0);
        }];
    }
    
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.bounces = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.scrollsToTop = NO;
    }
    return _scrollView;
}

- (UIView *)selectedLineView {
    if (!_selectedLineView) {
        _selectedLineView = [[UIView alloc] init];
        _selectedLineView.clipsToBounds = YES;
        _selectedLineView.layer.cornerRadius = self.config.lineHeight * 0.5;
        _selectedLineView.backgroundColor = self.config.lineColor;
    }
    return _selectedLineView;
}

@end
