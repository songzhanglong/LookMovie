//
//  NestSubTableView.m
//  DesignByKid
//
//  Created by szl on 2017/2/21.
//  Copyright © 2017年 江苏迪杰特教育科技股份有限公司. All rights reserved.
//

#import "NestSubTableView.h"
#import "NestTitleView.h"
#import "NestTabItemBaseView.h"
#import <Masonry/Masonry.h>

@interface NestSubTableView()<UIScrollViewDelegate>

@property (nonatomic, strong) NestTitleView *tabTitleView;
@property (nonatomic, strong) UIScrollView *tabContentView;

@end

@implementation NestSubTableView

- (instancetype)initWithTabConfigArray:(NSArray *)tabConfigArray
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        
        NSMutableArray *titleArray = [NSMutableArray array];
        for (int i = 0; i < tabConfigArray.count; i++) {
            NSDictionary *itemDic = tabConfigArray[i];
            [titleArray addObject:itemDic[@"title"]];
        }
        
        //title
        _tabTitleView = [[NestTitleView alloc] initWithTitleArray:titleArray];
        __weak typeof(self)weakSelf = self;
        _tabTitleView.titleClickBlock = ^(NSInteger index){
            if (weakSelf.tabContentView) {
                [weakSelf.tabContentView setContentOffset:CGPointMake(index * SCREEN_WIDTH, 0)];
            }
        };
        [self addSubview:_tabTitleView];
        
//        //footer
//        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 60, SCREEN_WIDTH, 60)];
//        [self addSubview:footerView];
//        
//        CGFloat labWei = SCREEN_WIDTH - 200;
//        UIFont *font = [UIFont boldSystemFontOfSize:17];
//        NSDictionary *attribute = @{NSFontAttributeName: font};
//        NSString *str = @"      根据幼儿园作品中素材使用情况与不同主题微景观的最佳素材惊醒匹配度分析，判断幼儿的主题设计趋向。根据此主题的素材类别，提供幼儿可以进行调整的参考意见。";
//        CGSize lastSize = [str boundingRectWithSize:CGSizeMake(labWei, 1000) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
//        UILabel *footerLab = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(footerView.frame) - labWei) / 2, (CGRectGetHeight(footerView.frame) - lastSize.height) / 2, labWei, lastSize.height)];
//        [footerLab setNumberOfLines:0];
//        [footerLab setText:str];
//        [footerLab setFont:font];
//        [footerLab setTextColor:rgba(10, 66, 116, 1)];
//        [footerView addSubview:footerLab];
//        
//        
        //scrollview
        _tabContentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_tabTitleView.frame), SCREEN_WIDTH, SCREEN_HEIGHT - CGRectGetHeight(_tabTitleView.frame)/* - CGRectGetHeight(footerView.frame)*/)];
        _tabContentView.contentSize = CGSizeMake(CGRectGetWidth(_tabContentView.frame) * titleArray.count, CGRectGetHeight(_tabContentView.frame));
        _tabContentView.pagingEnabled = YES;
        _tabContentView.bounces = NO;
        _tabContentView.showsHorizontalScrollIndicator = NO;
        _tabContentView.delegate = self;
        [self addSubview:_tabContentView];
        
        //subviews
        NSString *str = @"      根据幼儿作品素材使用情况与不同主题微景观的最佳素材进行匹配度分析，通过典型性素材的应用比例，判断幼儿的规划设计与主题素材的契合度。";
        for (NSInteger i = 0; i < tabConfigArray.count; i++) {
            NestTabItemBaseView *itemView = [[NestTabItemBaseView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_tabContentView.frame) * i, 0, CGRectGetWidth(_tabContentView.frame), CGRectGetHeight(_tabContentView.frame))];
            NSDictionary *itemDic = tabConfigArray[i];
            itemView.dataSource = itemDic[@"source"];
            itemView.footerStr = str;
            [_tabContentView addSubview:itemView];
        }
    }
    
    return self;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat offsetX = scrollView.contentOffset.x;
    NSInteger pageNum = offsetX / SCREEN_WIDTH;
    
    [_tabTitleView setItemSelected:pageNum];
}

@end
