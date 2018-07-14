//
//  ViewController.m
//  APTabSegmenteDemo
//
//  Created by YangWeiChang on 2018/7/14.
//  Copyright © 2018年 www.aipai.com. All rights reserved.
//

#import "ViewController.h"
#import "APSegmentedView.h"

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *contentView;



@property (nonatomic, strong) APSegmentedView *segmentedView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<UIViewController *> *tabViewControllerArray;
@end

@implementation ViewController

- (void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

- (void)setupView {
    _segmentedView = ({
        APSegmentedViewConfig *config = [APSegmentedViewConfig defaultConfig];
        APSegmentedView *segmentedView = [[APSegmentedView alloc] initWithTabs:@[@"内容1",@"内容2",@"内容3",@"内容4",@"内容5"] config:config];
        segmentedView;
    });
    
    _collectionView = ({
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.sectionInset = UIEdgeInsetsZero;
        flowLayout.minimumLineSpacing = CGFLOAT_MIN;
        flowLayout.minimumInteritemSpacing = CGFLOAT_MIN;
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        collectionView.dataSource = self;
        collectionView.delegate = self;
        collectionView.pagingEnabled = YES;
        collectionView.bounces = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
        collectionView;
    });
    
    [self.contentView addSubview:self.segmentedView];
    [self.contentView addSubview:self.collectionView];
    
    UIViewController *tab1VC = [UIViewController new];
    UIViewController *tab2VC = [UIViewController new];
    UIViewController *tab3VC = [UIViewController new];
    UIViewController *tab4VC = [UIViewController new];
    UIViewController *tab5VC = [UIViewController new];
    
    self.tabViewControllerArray = @[tab1VC,tab2VC,tab3VC,tab4VC,tab5VC];
    
    [self.segmentedView autoSegmenteWitScrollView:self.collectionView];
    __weak typeof(self) wself = self;
    self.segmentedView.onSelectedIndexChanged = ^(NSInteger index) {
        __strong typeof(wself) self = wself;
        [self scrollToItem:index];
    };
}

- (void)viewDidLayoutSubviews {
    
    _segmentedView.frame = CGRectMake(0, 0, self.view.frame.size.width, 40);
    _collectionView.frame = CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height - 40);
    
    [super viewDidLayoutSubviews];
}

#pragma makr - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.tabViewControllerArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIViewController *vc = self.tabViewControllerArray[indexPath.item];
    [cell.contentView addSubview:vc.view];
    vc.view.frame = cell.contentView.bounds;
    
    switch (indexPath.item) {
        case 0:
            vc.view.backgroundColor = [UIColor yellowColor];
            break;
        case 1:
            vc.view.backgroundColor = [UIColor orangeColor];
            break;
        case 2:
            vc.view.backgroundColor = [UIColor blueColor];
            break;
        case 3:
            vc.view.backgroundColor = [UIColor cyanColor];
            break;
        case 4:
            vc.view.backgroundColor = [UIColor magentaColor];
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.frame.size;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_segmentedView setScrollViewWillBeginDragging];
}

#pragma mark - private

- (void)scrollToItem:(NSInteger)item {
    [self.segmentedView setSelectedIndexChange:item];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
    if (!CGSizeEqualToSize(_collectionView.contentSize,CGSizeZero)) {
        [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    }
}

@end
