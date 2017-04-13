//
//  NestTitleView.h
//  DesignByKid
//
//  Created by szl on 2017/2/21.
//  Copyright © 2017年 江苏迪杰特教育科技股份有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NestTitleView : UIView

- (instancetype)initWithTitleArray:(NSArray *)titleArray;

- (void)setItemSelected: (NSInteger)column;

typedef void (^NestTitleClickBlock)(NSInteger);

@property (nonatomic,strong)NestTitleClickBlock titleClickBlock;

@end
