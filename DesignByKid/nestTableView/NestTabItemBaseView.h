//
//  NestTabItemBaseView.h
//  DesignByKid
//
//  Created by szl on 2017/2/21.
//  Copyright © 2017年 江苏迪杰特教育科技股份有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NestTabItemBaseView : UIView

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) BOOL canScroll;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSString *footerStr;

@end
