//
//  NestTitleView.m
//  DesignByKid
//
//  Created by szl on 2017/2/21.
//  Copyright © 2017年 江苏迪杰特教育科技股份有限公司. All rights reserved.
//

#import "NestTitleView.h"
#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface NestTitleView()

@property (nonatomic,strong)NSArray *titleArray;
@property (nonatomic, strong) NSMutableArray *titleBtnArray;

@end

@implementation NestTitleView

- (instancetype)initWithTitleArray:(NSArray *)titleArray
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _titleArray = titleArray;
        _titleBtnArray = [NSMutableArray array];
        
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, kTabTitleViewHeight);
        
        UILabel *titleLab = [[UILabel alloc] init];
        [titleLab setText:@"3. 作品智能分析"];
        [titleLab setTextColor:rgba(10, 66, 125, 1)];
        [titleLab setFont:[GlobalManager customFontWithName:@"myfont.TTF" size:20]];
        [self addSubview:titleLab];
        [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@70);
            make.top.equalTo(@20);
        }];
        
        UIView *bottomView = [[UIView alloc] init];
        [self addSubview:bottomView];
        [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mas_bottom).with.offset(-10);
            make.centerX.equalTo(self.mas_centerX);
        }];
    
        @weakify(self)
        UIView __block *lastView = nil;
        for (NSInteger i = 0; i < titleArray.count; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitle:_titleArray[i] forState:UIControlStateNormal];
            btn.titleLabel.lineBreakMode = 0;
            [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
            [btn.titleLabel setTextAlignment:NSTextAlignmentCenter];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setBackgroundImage:CREATE_IMG(@"buttonH@2x") forState:UIControlStateSelected];
            [btn setBackgroundImage:CREATE_IMG(@"buttonN@2x") forState:UIControlStateNormal];
            btn.tag = i;
            btn.selected = (i == 0);
            [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
                @strongify(self);
                [self setItemSelected:i];
                if (self.titleClickBlock) {
                    self.titleClickBlock(i);
                }
            }];
            
            [bottomView addSubview:btn];
            
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                if (lastView) {
                    make.left.equalTo(lastView.mas_right).with.offset(20);
                }
                else{
                    make.left.equalTo(@0);
                }
                make.centerY.equalTo(bottomView.mas_centerY);
                make.height.and.width.equalTo(@70);
                
                if (i == titleArray.count - 1) {
                    make.right.equalTo(bottomView.mas_right);
                    make.height.equalTo(bottomView.mas_height);
                }
            }];
            lastView = btn;
            
            [_titleBtnArray addObject:btn];
        }
    }
    
    return self;
}

- (void)setItemSelected:(NSInteger)column
{
    for (NSInteger i = 0; i < _titleBtnArray.count; i++) {
        UIButton *btn = _titleBtnArray[i];
        btn.selected = (i == column);
    }
}

@end
