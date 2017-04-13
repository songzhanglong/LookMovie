//
//  ResultViewController.h
//  DesignByKid
//
//  Created by szl on 2017/2/20.
//  Copyright © 2017年 江苏迪杰特教育科技股份有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultViewController : UIViewController

@property (nonatomic,assign)NSInteger delCount;
@property (nonatomic,assign)NSInteger curCount;
@property (nonatomic,assign)NSInteger checkIdx;
@property (nonatomic,strong)NSMutableArray *delImgNames;
@property (nonatomic,strong)NSMutableArray *useImgNames;

@end
