//
//  ResultViewController.m
//  DesignByKid
//
//  Created by szl on 2017/2/20.
//  Copyright © 2017年 江苏迪杰特教育科技股份有限公司. All rights reserved.
//

#import "ResultViewController.h"
#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "NestFatherTableView.h"
#import "NestSubTableView.h"

@interface ResultViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UIButton *backBtn;
@property (nonatomic,strong)UIImageView *backImg;
@property (nonatomic,strong)NestFatherTableView *tableView;

@property (nonatomic,assign)SystemSoundID touchUpSoundID;
@property (nonatomic,assign)SystemSoundID touchDownSoundID;

@property (nonatomic, assign)BOOL isTopIsCanNotMoveTabView;
@property (nonatomic, assign)BOOL isTopIsCanNotMoveTabViewPre;
@property (nonatomic, assign)BOOL canScroll;

@property (nonatomic,strong)NSArray *citys;
@property (nonatomic,strong)NSArray *gardens;
@property (nonatomic,strong)NSArray *farms;
@property (nonatomic,strong)NSArray *forests;

@end

@implementation ResultViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _delCount = [_delImgNames count];
    _curCount = [_useImgNames count];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.backImg];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.backBtn];
    
    [self initTableHeaderViews];
    [self initialConstraintsOfSubviews];
    [self initSignalSupports];
    [self initialAllSounds];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:kLeaveTopNotificationName object:nil];
}

#pragma mark - appear
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

#pragma mark - Private methods
- (void)initTableHeaderViews
{
    UIView *tableHeaderView = self.tableView.tableHeaderView;
    
    UILabel *oneLab = [[UILabel alloc] init];
    [oneLab setText:@"一、发展测评说明"];
    [oneLab setTextColor:rgba(10, 66, 125, 1)];
    [oneLab setFont:[GlobalManager customFontWithName:@"myfont.TTF" size:20]];
    [tableHeaderView addSubview:oneLab];
    [oneLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@70);
        make.top.equalTo(@110);
    }];
    
    __block UIView *lastView = nil;
    NSArray *tipsArr = @[@"试用年龄：5-6岁",@"测评点：能用多种工具、材料或不同的表现手法表达自己的感受和想象。",@"对应图谱：YS-A1-B01-C02-L"];
    for (NSInteger i = 0; i < tipsArr.count; i++) {
        UILabel *tmpLab = [[UILabel alloc] init];
        [tmpLab setText:tipsArr[i]];
        [tmpLab setTextColor:oneLab.textColor];
        [tmpLab setFont:[GlobalManager customFontWithName:@"myfont.TTF" size:17]];
        [tableHeaderView addSubview:tmpLab];
        
        [tmpLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(oneLab.mas_left).with.offset(55);
            if (lastView) {
                make.top.equalTo(lastView.mas_bottom);
            }
            else{
                make.top.equalTo(oneLab.mas_bottom).with.offset(5);
            }
            lastView = tmpLab;
        }];
    }
    
    //left
    UILabel *twoLab = [[UILabel alloc] init];
    [twoLab setText:@"二、测评数据分析"];
    [twoLab setTextColor:oneLab.textColor];
    [twoLab setFont:[GlobalManager customFontWithName:@"myfont.TTF" size:20]];
    [tableHeaderView addSubview:twoLab];
    [twoLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(oneLab.mas_left);
        make.top.equalTo(lastView.mas_bottom).with.offset(10);
    }];
    
    UILabel *oneOfTwoLab = [[UILabel alloc] init];
    [oneOfTwoLab setText:@"1. 观察力分析"];
    [oneOfTwoLab setTextColor:oneLab.textColor];
    [oneOfTwoLab setFont:[GlobalManager customFontWithName:@"myfont.TTF" size:20]];
    [tableHeaderView addSubview:oneOfTwoLab];
    [oneOfTwoLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(oneLab.mas_left);
        make.top.equalTo(twoLab.mas_bottom).with.offset(5);
    }];
    
    UIImageView *chartImg = [[UIImageView alloc] initWithImage:CREATE_IMG(@"quesChart@2x")];
    [tableHeaderView addSubview:chartImg];
    [chartImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(tableHeaderView.mas_centerX).with.multipliedBy(0.5);
        make.top.equalTo(oneOfTwoLab.mas_bottom).with.offset(5);
    }];

    NSArray *answers = @[@"A：任务开始时，选择数字盆器形状与实物盆器形状相同，细节观察能力较强。",@"B：任务过程中，通过同伴学习，调整数字盆器形状，与实物盆器形状相同，有一定的细节观察能力。",@"C：完成任务过程中，选择的数字盆器形状与实物盆器形状不同，细节观察能力需要加强。"];
    NSString *imgName = [@"flowerpotN" stringByAppendingString:[NSNumber numberWithInteger:_checkIdx + 1].stringValue];
    BOOL isCur = [_useImgNames containsObject:imgName];
    NSString *resImgNM = nil;
    if (isCur) {
        BOOL isDelpot = NO;
        for (NSString *subStr in _delImgNames) {
            if ([subStr hasPrefix:@"flowerpotN"]) {
                isDelpot = YES;
                break;
            }
        }
        resImgNM = isDelpot ? answers[1] : answers[0];
    }
    else{
        resImgNM = answers[2];
    }
    UILabel *answerLab = [[UILabel alloc] init];
    [answerLab setText:resImgNM];
    [answerLab setTextColor:oneLab.textColor];
    answerLab.numberOfLines = 0;
    [answerLab setFont:[GlobalManager customFontWithName:@"myfont.TTF" size:17]];
    [tableHeaderView addSubview:answerLab];
    
    [answerLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(chartImg.mas_centerX);
        make.top.equalTo(chartImg.mas_bottom).with.offset(40);
        make.width.equalTo(@(chartImg.image.size.width + 30));
    }];
    
    //right
    UILabel *twoOfTwoLab = [[UILabel alloc] init];
    [twoOfTwoLab setText:@"2. 素材应用分析"];
    [twoOfTwoLab setTextColor:oneLab.textColor];
    [twoOfTwoLab setFont:oneOfTwoLab.font];
    [tableHeaderView addSubview:twoOfTwoLab];
    [twoOfTwoLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(tableHeaderView.mas_centerX).with.offset(20);
        make.centerY.equalTo(oneOfTwoLab.mas_centerY);
    }];
    
    UIImageView *arrowRight = [[UIImageView alloc] initWithImage:CREATE_IMG(@"quesArrowR@2x")];
    [tableHeaderView addSubview:arrowRight];
    [arrowRight mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(chartImg.mas_bottom).with.offset(-15);
        make.centerX.equalTo(tableHeaderView.mas_centerX).with.multipliedBy(1.5);
    }];
    
    UIImageView *arrowUp = [[UIImageView alloc] initWithImage:CREATE_IMG(@"quesArrowU@2x")];
    [tableHeaderView addSubview:arrowUp];
    [arrowUp mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(chartImg.mas_centerY);
        make.left.equalTo(arrowRight.mas_left).with.offset(15);
    }];
    
    NSArray *materialNames = @[@"删除素材",@"成品素材",@"历史素材"];
    NSArray *colors = @[rgba(165, 57, 223, 1),rgba(66, 84, 206, 1),rgba(15, 111, 198, 1)];
    CGRect rightArrowRect = arrowRight.frame;
    CGFloat margin = rightArrowRect.size.height + 15 * 2,width = (rightArrowRect.size.width - margin - rightArrowRect.size.height) / 7,maxHei = CGRectGetHeight(arrowUp.frame) - margin - CGRectGetWidth(arrowUp.frame);
    for (NSInteger i = 0; i < materialNames.count; i++) {
        CGFloat curRate = (i == 0) ? (((CGFloat)_delCount) / (_delCount + _curCount)) : ((i == 1) ? (((CGFloat)_curCount) / (_delCount + _curCount)) : 1);
        CGFloat tmpX = margin + width + (width + width) * i,tmpHei = curRate * maxHei;
        
        //view
        UIView *bargraph = [[UIView alloc] init];
        [bargraph setBackgroundColor:colors[i]];
        [tableHeaderView addSubview:bargraph];
        [bargraph mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(arrowRight.mas_left).with.offset(tmpX);
            make.bottom.equalTo(arrowRight.mas_centerY);
            make.width.equalTo(@(width));
            make.height.equalTo(@(tmpHei));
        }];
        
        //down
        UILabel *tmpLab = [[UILabel alloc] init];
        [tmpLab setText:materialNames[i]];
        [tmpLab setTextColor:rgba(10, 66, 125, 1)];
        [tmpLab setFont:[GlobalManager customFontWithName:@"myfont.TTF" size:14]];
        [tableHeaderView addSubview:tmpLab];
        [tmpLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(bargraph.mas_centerX);
            make.top.equalTo(bargraph.mas_bottom).with.offset(2);
        }];
        
        //up
        NSString *tmpStr = (i == 0) ? @(_delCount).stringValue : ((i == 1) ? @(_curCount).stringValue : @(_delCount + _curCount).stringValue);
        UILabel *tmpUpLab = [[UILabel alloc] init];
        [tmpUpLab setText:[tmpStr stringByAppendingString:@"个"]];
        [tmpUpLab setTextColor:rgba(10, 66, 125, 1)];
        [tmpUpLab setFont:tmpLab.font];
        [tableHeaderView addSubview:tmpUpLab];
        [tmpUpLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(bargraph.mas_centerX);
            make.bottom.equalTo(bargraph.mas_top).with.offset(-2);
        }];
    }
    
    UILabel *rConLab = [[UILabel alloc] init];
    [rConLab setText:@"         通过对幼儿使用过的素材数量、作品定型后的素材数量、删除素材数量三个数据的两次操作情况进行对比，分析幼儿在微景观设计过程中对素材进行规划、比较和选择的调整过程，判断幼儿在自由设计和通过欣赏图片、观看视频以后，在表达能力上的变化。"];
    [rConLab setTextColor:oneLab.textColor];
    rConLab.numberOfLines = 0;
    [rConLab setFont:answerLab.font];
    [tableHeaderView addSubview:rConLab];
    
    [rConLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(answerLab.mas_centerY);
        make.centerX.equalTo(tableHeaderView.mas_centerX).with.multipliedBy(1.5);
        make.width.equalTo(tableHeaderView.mas_width).with.multipliedBy(0.5).with.offset(-40);
    }];
}

- (void)initialConstraintsOfSubviews{

    [self.backImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY);
    }];
    
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@40);
        make.top.equalTo(@50);
        //make.height.equalTo(@(self.backBtn.imageView.image.size.height));
    }];
}

- (void)initSignalSupports{
    //抬起
    @weakify(self)
    [[self.backBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        AudioServicesPlayAlertSound(self.touchUpSoundID);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    //按下
    [[self.backBtn rac_signalForControlEvents:UIControlEventTouchDown] subscribeNext:^(id x) {
        @strongify(self);
        AudioServicesPlayAlertSound(self.touchDownSoundID);
    }];
}

- (void)initialAllSounds
{
    // 加载文件

    NSURL *upFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"upAudio" ofType:@"mp3"]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(upFileURL), &_touchUpSoundID);
    
    NSURL *downFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"downAudio" ofType:@"mp3"]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(downFileURL), &_touchDownSoundID);
    
}

- (void)acceptMsg : (NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    NSString *canScroll = userInfo[@"canScroll"];
    if ([canScroll isEqualToString:@"1"]) {
        _canScroll = YES;
    }
}

- (NSArray *)calculateRateBy:(NSArray *)source from:(NSArray *)useNames
{
    NSMutableSet *srcSet = [NSMutableSet setWithArray:source],*useSet = [NSMutableSet setWithArray:useNames];
    [srcSet intersectSet:useSet];   //交集
    [useSet minusSet:srcSet];       //差集
    
    return @[srcSet,useSet];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CGRectGetHeight(self.view.frame);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellId = @"identifierCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"identifierCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSMutableArray *tmpArr = [NSMutableArray arrayWithArray:self.useImgNames];
        for (NSString *subStr in self.useImgNames) {
            if ([subStr hasPrefix:@"flowerpot"]) {
                [tmpArr removeObject:subStr];
            }
        }
        
        //城市
        NSArray *arrayCity = [self calculateRateBy:self.citys from:tmpArr];
        NSArray *rateCityUse = [[arrayCity firstObject] allObjects];
        CGFloat rateCity = ((CGFloat)[rateCityUse count]) / [self.citys count];
        NSDictionary *dicCity = @{@"title":[NSString stringWithFormat:@"城 市(%.0f%%)",rateCity * 100],@"source":@[self.citys,tmpArr],@"rate":@(rateCity)};
        //花园
        NSArray *arrayGarden = [self calculateRateBy:self.gardens from:tmpArr];
        NSArray *rateGardenUse = [[arrayGarden firstObject] allObjects];
        CGFloat rateGarden = ((CGFloat)[rateGardenUse count]) / [self.gardens count];
        NSDictionary *dicGarden = @{@"title":[NSString stringWithFormat:@"花 园(%.0f%%)",rateGarden * 100],@"source":@[self.gardens,tmpArr],@"rate":@(rateGarden)};
        //农场
        NSArray *arrayFarm = [self calculateRateBy:self.farms from:tmpArr];
        NSArray *rateFarmUse = [[arrayFarm firstObject] allObjects];
        CGFloat rateFarm = ((CGFloat)[rateFarmUse count]) / [self.farms count];
        NSDictionary *dicFarm = @{@"title":[NSString stringWithFormat:@"农 场(%.0f%%)",rateFarm * 100],@"source":@[self.farms,tmpArr],@"rate":@(rateFarm)};
        //森林
        NSArray *arrayForest = [self calculateRateBy:self.forests from:tmpArr];
        NSArray *rateForestUse = [[arrayForest firstObject] allObjects];
        CGFloat rateForest = ((CGFloat)[rateForestUse count]) / [self.forests count];
        NSDictionary *dicForest = @{@"title":[NSString stringWithFormat:@"森 林(%.0f%%)",rateForest * 100],@"source":@[self.forests,tmpArr],@"rate":@(rateForest)};
        
        NSArray *sortArr = @[dicForest,dicFarm,dicGarden,dicCity];
        NSArray *sortedMaxima = [sortArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSDictionary *dic1 = (NSDictionary *)obj1;
            NSDictionary *dic2 = (NSDictionary *)obj2;
            return ([dic1[@"rate"] floatValue] > [dic2[@"rate"] floatValue]) ? NSOrderedAscending : NSOrderedDescending;
        }];
        
        //    NSArray *tabConfigArray = @[@{
        //                                    @"title":@"农场(70%)",
        //                                    @"source":@[@[@1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@11,@12],@[@1,@2,@3],@[@4,@5,@6,@7,@8,@9,@10,@11,@12]],
        //                                    @"position":@0
        //                                    },@{
        //                                    @"title":@"花园(50%)",
        //                                    @"source":@[@[@1,@2,@3],@[@4,@5,@6,@7,@8,@9,@10,@11,@12],@[@1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@11,@12]],
        //                                    @"position":@1
        //                                    },@{
        //                                    @"title":@"森林(30%)",
        //                                    @"source":@[@[@4,@5,@6,@7,@8,@9,@10,@11,@12],@[@1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@11,@12],@[@1,@2,@3]],
        //                                    @"position":@2
        //                                    }];
        NestSubTableView *tabView = [[NestSubTableView alloc] initWithTabConfigArray:sortedMaxima];
        [cell.contentView addSubview:tabView];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

    CGFloat tabOffsetY = SCREEN_HEIGHT;
    CGFloat offsetY = scrollView.contentOffset.y;
    _isTopIsCanNotMoveTabViewPre = _isTopIsCanNotMoveTabView;
    if (offsetY >= tabOffsetY) {
        scrollView.contentOffset = CGPointMake(0, tabOffsetY);
        _isTopIsCanNotMoveTabView = YES;
    }else{
        _isTopIsCanNotMoveTabView = NO;
    }
    if (_isTopIsCanNotMoveTabView != _isTopIsCanNotMoveTabViewPre) {
        if (!_isTopIsCanNotMoveTabViewPre && _isTopIsCanNotMoveTabView) {
            //NSLog(@"滑动到顶端");
            [[NSNotificationCenter defaultCenter] postNotificationName:kGoTopNotificationName object:nil userInfo:@{@"canScroll":@"1"}];
            _canScroll = NO;
        }
        if(_isTopIsCanNotMoveTabViewPre && !_isTopIsCanNotMoveTabView){
            NSLog(@"离开顶端");
            if (!_canScroll) {
                //避免通过父tableview滑动离开顶端
                scrollView.contentOffset = CGPointMake(0, tabOffsetY);
            }
        }
    }
}

#pragma mark - lazy load
- (UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[UIImage imageNamed:@"navback"] forState:UIControlStateNormal];
    }
    return _backBtn;
}

- (UIImageView *)backImg
{
    if (!_backImg) {
        _backImg = [[UIImageView alloc] initWithImage:CREATE_IMG(@"resultBack@2x")];
        _backImg.alpha = 0.3;
    }
    return _backImg;
}

- (NestFatherTableView *)tableView
{
    if (!_tableView) {
        _tableView = [[NestFatherTableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame),CGRectGetHeight(self.view.frame) - 1)];
        headView.backgroundColor = [UIColor clearColor];
        _tableView.tableHeaderView = headView;
    }
    return _tableView;
}

- (NSArray *)citys
{
    if (!_citys) {
        _citys = @[@"carN1",@"animalN1",@"houseN1",@"streetlampN1",@"streetlampN2",@"bridgeN1",@"personN1",@"treeN1",@"treeN2",@"treeN3",@"treeN4",@"waterN1",@"fenceN1",@"fenceN2",@"plantN1"];
    }
    return _citys;
}

- (NSArray *)gardens
{
    if (!_gardens) {
        _gardens = @[@"animalN2",@"houseN2",@"flowerN2",@"streetlampN1",@"streetlampN2",@"bridgeN2",@"personN1",@"treeN1",@"treeN2",@"treeN3",@"treeN4",@"waterN1",@"fenceN1",@"fenceN2",@"plantN1"];
    }
    return _gardens;
}

- (NSArray *)farms
{
    if (!_farms) {
        _farms = @[@"animalN3",@"houseN3",@"wellN3",@"bridgeN3",@"personN3",@"treeN1",@"treeN2",@"treeN3",@"treeN4",@"waterN3",@"fenceN3",@"plantN1",@"plantN3"];
    }
    return _farms;
}

- (NSArray *)forests
{
    if (!_forests) {
        _forests = @[@"animalN4",@"houseN4",@"streetlampN3",@"mushroomN4",@"mushroomN5",@"bridgeN4",@"personN4",@"treeN1",@"treeN2",@"treeN3",@"treeN4",@"waterN4",@"fenceN4",@"plantN1",@"plantN4"];
    }
    return _forests;
}

@end
