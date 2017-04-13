//
//  NestTabItemBaseView.m
//  DesignByKid
//
//  Created by szl on 2017/2/21.
//  Copyright © 2017年 江苏迪杰特教育科技股份有限公司. All rights reserved.
//

#import "NestTabItemBaseView.h"
#import <Masonry/Masonry.h>

@interface NestTabItemBaseView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@end

@implementation NestTabItemBaseView

#define MatterCellId    @"MatterCellId"
#define MatterHeaderId  @"MatterHeaderId"

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(100, 100);
        layout.minimumLineSpacing = 20;
        layout.minimumInteritemSpacing = 20;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        [_collectionView setContentInset:UIEdgeInsetsMake(0, 200, 0, 200)];
        _collectionView.showsHorizontalScrollIndicator = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView setBackgroundColor:[UIColor clearColor]];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.alwaysBounceHorizontal = NO;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:MatterCellId];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:MatterHeaderId];
        [self addSubview:_collectionView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:kGoTopNotificationName object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:kLeaveTopNotificationName object:nil];//其中一个TAB离开顶部的时候，如果其他几个偏移量不为0的时候，要把他们都置为0
    }
    return self;
}

- (void)acceptMsg:(NSNotification *)notification{
    NSString *notificationName = notification.name;
    if ([notificationName isEqualToString:kGoTopNotificationName]) {
        NSDictionary *userInfo = notification.userInfo;
        NSString *canScroll = userInfo[@"canScroll"];
        if ([canScroll isEqualToString:@"1"]) {
            self.canScroll = YES;
            self.collectionView.showsVerticalScrollIndicator = YES;
        }
    }else if([notificationName isEqualToString:kLeaveTopNotificationName]){
        CGFloat offsetX = self.collectionView.contentOffset.x;
        self.collectionView.contentOffset = CGPointMake(offsetX, 0);
        self.canScroll = NO;
        self.collectionView.showsVerticalScrollIndicator = NO;
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [_dataSource count] + 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == [_dataSource count]) {
        return 0;
    }
    
    NSArray *array = _dataSource[section];
    return [array count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MatterCellId forIndexPath:indexPath];
    
    UIImageView *curImg = (UIImageView *)[cell.contentView viewWithTag:1];
    if (!curImg) {
        curImg = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
        [curImg setContentMode:UIViewContentModeScaleAspectFit];
        [curImg setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [curImg setTag:1];
        [cell.contentView addSubview:curImg];
    }
    
    NSString *name = _dataSource[indexPath.section][indexPath.item];
//    NSNumber *number = _dataSource[indexPath.section][indexPath.item];
//    NSInteger index = number.integerValue % 3;
//    NSString *name = (index == 0) ? @"bear" : ((index == 1) ? @"person3" : @"duck");
    [curImg setImage:CREATE_IMG(name)];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section == [_dataSource count]) {
        UIFont *font = [GlobalManager customFontWithName:@"myfont.TTF" size:17];
        NSDictionary *attribute = @{NSFontAttributeName: font};
        CGSize lastSize = [_footerStr boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 400, 1000) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
        return CGSizeMake(SCREEN_WIDTH, lastSize.height + 30);
    }
    return CGSizeMake(SCREEN_WIDTH, 55);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *view =
        [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:MatterHeaderId forIndexPath:indexPath];
        
        UILabel *label = (UILabel *)[view viewWithTag:1];
        if (!label) {
            label = [[UILabel alloc] init];
            [label setTag:1];
            [label setTextColor:rgba(10, 66, 116, 1)];
            [label setFont:[GlobalManager customFontWithName:@"myfont.TTF" size:17]];
            [label setNumberOfLines:0];
            [view addSubview:label];
            
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(view.mas_bottom).with.offset(-10);
                make.left.equalTo(@0);
                make.width.lessThanOrEqualTo(@(SCREEN_WIDTH - 400));
            }];
        }
        if (indexPath.section == [_dataSource count]) {
            [label setText:_footerStr];
        }
        else{
            [label setText:(indexPath.section == 0) ? @"主题素材：" : @"我的素材："];
        }
        
        return view;
    }
    
    return nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.canScroll) {
        CGFloat offsetX = scrollView.contentOffset.x;
        scrollView.contentOffset = CGPointMake(offsetX, 0);
    }
    
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY < 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kLeaveTopNotificationName object:nil userInfo:@{@"canScroll":@"1"}];
    }
}

@end
