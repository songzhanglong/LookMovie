//
//  DragViewController.m
//  DesignByKid
//
//  Created by szl on 16/12/29.
//  Copyright © 2016年 江苏迪杰特教育科技股份有限公司. All rights reserved.
//

#import "DragViewController.h"
#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "ResultViewController.h"

@interface DragViewController ()

@property (nonatomic,strong)UIImageView *imageView;
@property (nonatomic,strong)UIImageView *frontImageView;
@property (nonatomic,strong)UIImageView *bottomImageView;
@property (nonatomic,strong)UIImageView *rubbishImageView;
@property (nonatomic,strong)UIButton *backBtn;
@property (nonatomic,strong)UIButton *saveBtn;
@property (nonatomic,strong)UIButton *leftBtn;
@property (nonatomic,strong)UIButton *rightBtn;
@property (nonatomic,strong)NSArray *images;
@property (nonatomic,assign)NSUInteger curIdx;
@property (nonatomic,assign)SystemSoundID rubbishSoundID;
@property (nonatomic,assign)SystemSoundID touchUpSoundID;
@property (nonatomic,assign)SystemSoundID touchDownSoundID;
@property (nonatomic,strong)AVAudioPlayer *player;
@property (nonatomic,strong)UIView *areaView;
@property (nonatomic,strong)UIView *tipView;

@property (nonatomic,assign)SystemSoundID thirdDownSoundID;
@property (nonatomic,assign)SystemSoundID fourDownSoundID;
@property (nonatomic,assign)SystemSoundID fiveDownSoundID;

@property (nonatomic,strong)NSMutableArray *delImgNames;;
@property (nonatomic,strong)NSMutableArray *useImgs;
@property (nonatomic,strong)NSMutableArray *useImgNames;

@end

@implementation DragViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _useImgs = [NSMutableArray array];
    _useImgNames = [NSMutableArray array];
    _delImgNames = [NSMutableArray array];
    
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.frontImageView];
    [self.frontImageView addSubview:self.areaView];
    [self.view addSubview:self.backBtn];
    [self.view addSubview:self.saveBtn];
    [self.view addSubview:self.bottomImageView];
    [self.view addSubview:self.leftBtn];
    [self.view addSubview:self.rightBtn];
    [self.view addSubview:self.rubbishImageView];

    [self initialConstraintsOfSubviews];
    [self initSignalSupports];
    [self initialAllSounds];
    [self prepAudio];
}

#pragma mark - appear
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self checkNewTemplate];
    if (self.player) {
        [self.player play];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.player) {
        [self.player stop];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

#pragma mark - Private methods
- (void)initialConstraintsOfSubviews{
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@40);
        make.top.equalTo(@50);
        make.height.equalTo(@(self.backBtn.imageView.image.size.height));
    }];
    
    [self.saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).with.offset(-40);
        make.centerY.equalTo(self.backBtn.mas_centerY);
    }];
    
    [self.frontImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@10);
        make.top.equalTo(@20);
        make.right.equalTo(self.view.mas_right).with.offset(-10);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-155);
    }];
    [self.areaView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.frontImageView).with.insets(UIEdgeInsetsMake(23, 25, 25, 23));
    }];
    [self.rubbishImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.frontImageView.mas_right).with.offset(-10);
        make.bottom.equalTo(self.frontImageView.mas_bottom).with.offset(-20);
    }];
    [self.bottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-15);
        make.height.equalTo(@125);
        make.width.equalTo(self.view.mas_width).with.offset(-146);
    }];
    [self.leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.centerY.equalTo(self.bottomImageView.mas_centerY);
    }];
    [self.rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).with.offset(-20);
        make.centerY.equalTo(self.bottomImageView.mas_centerY);
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
    [[self.saveBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        AudioServicesPlayAlertSound(self.fiveDownSoundID);
        
        NSMutableArray *tmpArr = [NSMutableArray arrayWithArray:self.useImgNames];
        for (NSString *subStr in self.useImgNames) {
            if ([subStr hasPrefix:@"flowerpot"]) {
                [tmpArr removeObject:subStr];
            }
        }
        
        if ([tmpArr count] > 0) {
            [self popTipView];
        } else{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"您还未添加素材哦！" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        
        /*
        UIView *fullView = [[UIView alloc] init];
        [self.view addSubview:fullView];
        [fullView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view).with.insets(UIEdgeInsetsZero);
        }];
        
        UIImage *backImg = CREATE_IMG(@"poprect@2x");
        CGFloat wei = self.view.bounds.size.width - 500,hei = backImg.size.height * wei / backImg.size.width;
        UIImageView *imgback = [[UIImageView alloc] initWithImage:backImg];
        imgback.userInteractionEnabled = YES;
        [fullView addSubview:imgback];
        CGFloat yOri = self.frontImageView.frame.origin.y + self.frontImageView.frame.size.height / 2;
        [imgback mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(fullView.mas_top).with.offset(yOri);
            make.centerX.equalTo(fullView.mas_centerX);
            make.width.equalTo(@(wei));
            make.height.equalTo(@(hei));
        }];
        
        UIImage *shineImg = CREATE_IMG(@"popshine@2x");
        CGFloat shineHei = shineImg.size.height * wei / shineImg.size.width;
        UIImageView *shineImgView = [[UIImageView alloc] initWithImage:shineImg];
        [fullView addSubview:shineImgView];
        [shineImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(imgback.mas_centerY).with.offset(30);
            make.centerX.equalTo(imgback.mas_centerX).with.offset(80);
            make.width.equalTo(@(wei));
            make.height.equalTo(@(shineHei));
        }];
        [fullView sendSubviewToBack:shineImgView];
        
        //
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeBtn setImage:CREATE_IMG(@"popclose@2x") forState:UIControlStateNormal];
        [fullView addSubview:closeBtn];
        [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(imgback.mas_right).with.offset(-10);
            make.width.and.height.equalTo(@(80));
            make.centerY.equalTo(imgback.mas_bottom).with.offset(-(205 * hei / 980));
        }];
        [[closeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            [fullView removeFromSuperview];
        }];
        
        UIButton *homeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [homeBtn setImage:CREATE_IMG(@"popsave@2x") forState:UIControlStateNormal];
        [fullView addSubview:homeBtn];
        [homeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(closeBtn.mas_left).with.offset(-10);
            make.width.and.height.equalTo(@(80));
            make.centerY.equalTo(closeBtn.mas_centerY);
        }];
        [[homeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            [fullView removeFromSuperview];
        }];
        
        UIImage *norImg = CREATE_IMG(@"popstarn@2x"),*hliImg = CREATE_IMG(@"popstar@2x");
        CGFloat sixMargin = wei * 1200 / 1630,btnWei = sixMargin / 7,btnMar = btnWei / 3;
        __block UIView *lastView = nil;
        for (NSInteger i = 4; i >= 0; i--) {
            UIButton *tmpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [tmpBtn setImage:norImg forState:UIControlStateNormal];
            [tmpBtn setImage:hliImg forState:UIControlStateSelected];
            [tmpBtn setTag:i + 1];
            [imgback addSubview:tmpBtn];
            [[tmpBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *x) {
                NSInteger lastIdx = [x tag];
                for (UIButton *subView in imgback.subviews) {
                    if (subView.tag == lastIdx) {
                        subView.selected = !subView.selected;
                    }
                    else{
                        subView.selected = NO;
                    }
                }
            }];
            if (i == 4) {
                [[tmpBtn rac_signalForControlEvents:UIControlEventTouchDown] subscribeNext:^(id x) {
                    AudioServicesPlayAlertSound(self.fiveDownSoundID);
                }];
            }
            else if (i == 3){
                [[tmpBtn rac_signalForControlEvents:UIControlEventTouchDown] subscribeNext:^(id x) {
                    AudioServicesPlayAlertSound(self.fourDownSoundID);
                }];
            }
            else if (i == 2)
            {
                [[tmpBtn rac_signalForControlEvents:UIControlEventTouchDown] subscribeNext:^(id x) {
                    AudioServicesPlayAlertSound(self.thirdDownSoundID);
                }];
            }
            
            [tmpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(imgback.mas_bottom).with.multipliedBy(600.0 / 980);
                make.width.and.height.equalTo(@(btnWei));
                if (lastView) {
                    make.right.equalTo(lastView.mas_left).with.offset(-btnMar);
                }
                else{
                    make.right.equalTo(imgback.mas_right).with.offset(-btnMar - 6);
                }
                lastView = tmpBtn;
            }];
        }*/
    }];
    
    [[self.leftBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        AudioServicesPlayAlertSound(self.touchUpSoundID);
        if (self.curIdx < 1) {
            self.curIdx = [self.images count] - 1;
        }
        else{
            self.curIdx--;
        }
        [self checkNewTemplate];
    }];
    [[self.rightBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        AudioServicesPlayAlertSound(self.touchUpSoundID);
        if (self.curIdx >= [self.images count] - 1) {
            self.curIdx = 0;
        }
        else{
            self.curIdx++;
        }
        [self checkNewTemplate];
    }];
    
    //按下
    [[self.backBtn rac_signalForControlEvents:UIControlEventTouchDown] subscribeNext:^(id x) {
        @strongify(self);
        AudioServicesPlayAlertSound(self.touchDownSoundID);
    }];
    [[self.saveBtn rac_signalForControlEvents:UIControlEventTouchDown] subscribeNext:^(id x) {
        @strongify(self);
        AudioServicesPlayAlertSound(self.touchDownSoundID);
    }];
    [[self.leftBtn rac_signalForControlEvents:UIControlEventTouchDown] subscribeNext:^(id x) {
        @strongify(self);
        AudioServicesPlayAlertSound(self.touchDownSoundID);
    }];
    [[self.rightBtn rac_signalForControlEvents:UIControlEventTouchDown] subscribeNext:^(id x) {
        @strongify(self);
        AudioServicesPlayAlertSound(self.touchDownSoundID);
    }];
}

- (void)initialAllSounds
{
    // 加载文件
    NSURL *fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"rubbishAudio" ofType:@"mp3"]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileURL), &_rubbishSoundID);
    
    NSURL *upFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"upAudio" ofType:@"mp3"]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(upFileURL), &_touchUpSoundID);
    
    NSURL *downFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"downAudio" ofType:@"mp3"]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(downFileURL), &_touchDownSoundID);
    
    NSURL *thirdFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"thirdstar" ofType:@"m4a"]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(thirdFileURL), &_thirdDownSoundID);
    
    NSURL *fourFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"fourstar" ofType:@"m4a"]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fourFileURL), &_fourDownSoundID);
    
    NSURL *fiveFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"fivestar" ofType:@"m4a"]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fiveFileURL), &_fiveDownSoundID);
}

- (void)checkNewTemplate
{
    [self.bottomImageView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSArray *array = [self.images objectAtIndex:self.curIdx];
    NSInteger count = array.count;
    for (NSInteger i = 0; i < count; i++) {
        NSString *str = array[i];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:CREATE_IMG(str) forState:UIControlStateNormal];
        [btn setTag:i + 1];
        [btn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomImageView addSubview:btn];
    }
    
    CGFloat margin = (self.bottomImageView.bounds.size.width - 80 * 6) / 7;
    UIView __block *lastView = nil;
    [self.bottomImageView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj mas_makeConstraints:^(MASConstraintMaker *make) {
            if (lastView) {
                make.left.equalTo(lastView.mas_right).with.offset(margin);
            }
            else{
                make.left.equalTo(@(margin));
            }
            make.centerY.equalTo(self.bottomImageView.mas_centerY);
            make.height.and.width.equalTo(@80);
            lastView = obj;
        }];
    }];
}

- (void)prepAudio

{
    NSError *error;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"mainAudio" ofType:@"mp3"];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]error:&error];
    
    if (!self.player)
    {
        NSLog(@"Error: %@", [error localizedDescription]);
        return;
    }
    
    [self.player prepareToPlay];
    
    //就是这行代码啦
    [self.player setNumberOfLoops:1000000];
}

- (UIImage *)convertSelfToImage:(UIView *)view
{
    CGSize s = view.bounds.size;
    UIGraphicsBeginImageContextWithOptions(s, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* tImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tImage;
}

- (void)popTipView
{
    [self.view addSubview:self.tipView];
    [self.tipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    //透明button
    UIButton *tipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.tipView addSubview:tipBtn];
    [tipBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.tipView).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    @weakify(self)
    [[tipBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self dismissPopView];
    }];
    
    //提示窗口
    NSString *imgname = @"quesDialog@2x";
    UIImage *img = CREATE_IMG(imgname);
    UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPopView)];
    [imgView addGestureRecognizer:tapGestureRecognizer];
    [imgView setUserInteractionEnabled:YES];
    [self.tipView addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.tipView.mas_centerX);
        make.centerY.equalTo(self.tipView.mas_centerY).with.offset(-66);
    }];
    
    //按钮
    NSArray *tips = @[@"A:圆形",@"B:方形",@"C:椭圆形",@"D:不规则形"];
    UIImage *norImg = CREATE_IMG(@"quesBtnN@2x"),*hliImg = CREATE_IMG(@"quesBtnH@2x");
    for (NSInteger i = 0; i < tips.count; i++) {
        UIButton *tmpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [tmpBtn setTitle:tips[i] forState:UIControlStateNormal];
        [tmpBtn setTitleColor:rgba(248, 219, 164, 1) forState:UIControlStateHighlighted];
        [tmpBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [tmpBtn.titleLabel setFont:[UIFont systemFontOfSize:20]];
        [tmpBtn setBackgroundImage:hliImg forState:UIControlStateHighlighted];
        [tmpBtn setBackgroundImage:norImg forState:UIControlStateNormal];
        [imgView addSubview:tmpBtn];
        
        [[tmpBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            [self dismissPopView];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                UIImage *img = [self convertSelfToImage:self.frontImageView];
                UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);
            });
            
            ResultViewController *resCon = [[ResultViewController alloc] init];
            resCon.checkIdx = i;
            resCon.delImgNames = self.delImgNames;
            resCon.useImgNames = self.useImgNames;
            [self.navigationController pushViewController:resCon animated:YES];
        }];
        
        if (i % 2 == 0) {
            if (i == 0) {
                [tmpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(imgView.mas_centerX).with.offset(-30);
                    make.centerY.equalTo(imgView.mas_centerY);
                }];
            }
            else{
                [tmpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(imgView.mas_centerX).with.offset(-30);
                    make.centerY.equalTo(imgView.mas_centerY).with.offset(norImg.size.height + 20);
                }];
                
            }
        }
        else{
            if (i == 1) {
                [tmpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(imgView.mas_centerX).with.offset(30);
                    make.centerY.equalTo(imgView.mas_centerY);
                }];
            }
            else{
                [tmpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(imgView.mas_centerX).with.offset(30);
                    make.centerY.equalTo(imgView.mas_centerY).with.offset(norImg.size.height + 20);
                }];
            }
        }
    }
}

- (void)dismissPopView
{
    [self.tipView removeFromSuperview];
    self.tipView = nil;
}

#pragma mark - actions
- (void)buttonPressed:(id)sender
{
    NSInteger index = [sender tag] - 1;
    NSArray *array = self.images[self.curIdx];
    NSString *imgname = array[index];
    UIImage *img = CREATE_IMG(imgname);
    UIImageView *imgView = [[UIImageView alloc] initWithImage:img];

    [imgView setBounds:CGRectMake(0, 0, img.size.width / 2, img.size.height / 2)];
    [imgView setUserInteractionEnabled:YES];
    if (self.curIdx == 0) {
        [imgView setCenter:CGPointMake(self.areaView.bounds.size.width / 2, self.areaView.bounds.size.height - imgView.bounds.size.height / 2)];
    }
    else{
        [imgView setCenter:CGPointMake(self.areaView.bounds.size.width / 2, self.areaView.bounds.size.height / 2)];
    }
    
    [self.areaView addSubview:imgView];
    
    if ([imgname hasPrefix:@"flowerpot"]) {
        [self.areaView sendSubviewToBack:imgView];
    }
    
    [_useImgNames addObject:imgname];
    [_useImgs addObject:imgView];
    
    // 移动手势
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [imgView addGestureRecognizer:panGestureRecognizer];
}

// 处理拖拉手势
- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if (panGestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        UIView *view = [panGestureRecognizer view];
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        CGPoint point = CGPointMake(view.center.x + translation.x, view.center.y + translation.y);
        [view setCenter:point];
        
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    }
    else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        //检查是否拖拽到垃圾箱位置
        CGSize size = self.rubbishImageView.bounds.size;
        CGRect rubbishFrame = CGRectMake(self.frontImageView.bounds.size.width - 10 - size.width - self.areaView.frame.origin.x, self.frontImageView.bounds.size.height - 20 - size.height - self.areaView.frame.origin.y, size.width, size.height);
        UIView *view = [panGestureRecognizer view];
        CGPoint locationPoint = [panGestureRecognizer locationInView:view];
        if (CGRectContainsPoint(rubbishFrame, CGPointMake(view.frame.origin.x + locationPoint.x, view.frame.origin.y + locationPoint.y))) {
            //删除,此处应播放音乐
            self.view.userInteractionEnabled = NO;
            
            // 播放短频音效
            AudioServicesPlayAlertSound(_rubbishSoundID);
            
            [UIView animateWithDuration:0.5 animations:^{
                [view setFrame:CGRectMake(rubbishFrame.origin.x + rubbishFrame.size.width / 2, rubbishFrame.origin.y + rubbishFrame.size.height / 2, 0, 0)];
            } completion:^(BOOL finished) {
                [view removeFromSuperview];
                NSInteger index = [self.useImgs indexOfObject:view];
                if (index != NSNotFound) {
                    [self.useImgs removeObjectAtIndex:index];
                    NSString *imgName = [self.useImgNames objectAtIndex:index];
                    [self.delImgNames addObject:imgName];
                    [self.useImgNames removeObjectAtIndex:index];
                }
                self.view.userInteractionEnabled = YES;
            }];
        }
    }
}

#pragma mark - lazy load
- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        [_imageView setImage:CREATE_IMG(@"dragback@2x")];
    }
    return _imageView;
}

- (UIImageView *)frontImageView
{
    if (!_frontImageView) {
        _frontImageView = [[UIImageView alloc] init];
        UIImage *frontImg = CREATE_IMG(@"frontback@2x");
        frontImg = [frontImg stretchableImageWithLeftCapWidth:frontImg.size.width * 0.5 topCapHeight:frontImg.size.height * 0.5];
        [_frontImageView setImage:frontImg];
        _frontImageView.userInteractionEnabled = YES;
    }
    return _frontImageView;
}

- (UIView *)areaView
{
    if (!_areaView) {
        _areaView = [[UIView alloc] init];
        _areaView.clipsToBounds = YES;
    }
    return _areaView;
}

- (UIImageView *)bottomImageView
{
    if (!_bottomImageView) {
        _bottomImageView = [[UIImageView alloc] init];
        UIImage *frontImg = CREATE_IMG(@"bottomback@2x");
        frontImg = [frontImg stretchableImageWithLeftCapWidth:frontImg.size.width * 0.5 topCapHeight:frontImg.size.height * 0.5];
        [_bottomImageView setImage:frontImg];
        _bottomImageView.userInteractionEnabled = YES;
    }
    return _bottomImageView;
}

- (UIImageView *)rubbishImageView
{
    if (!_rubbishImageView) {
        _rubbishImageView = [[UIImageView alloc] init];
        [_rubbishImageView setImage:[UIImage imageNamed:@"rubbish.png"]];
    }
    return _rubbishImageView;
}

- (UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[UIImage imageNamed:@"navback"] forState:UIControlStateNormal];
    }
    return _backBtn;
}

- (UIButton *)saveBtn
{
    if (!_saveBtn) {
        _saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_saveBtn setImage:[UIImage imageNamed:@"navsave"] forState:UIControlStateNormal];
    }
    return _saveBtn;
}

- (UIButton *)leftBtn
{
    if (!_leftBtn) {
        _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_leftBtn setImage:[UIImage imageNamed:@"arrowLeft"] forState:UIControlStateNormal];
    }
    return _leftBtn;
}

- (UIButton *)rightBtn
{
    if (!_rightBtn) {
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightBtn setImage:[UIImage imageNamed:@"arrowRight"] forState:UIControlStateNormal];
    }
    return _rightBtn;
}

- (NSArray *)images
{
    if (!_images) {
        NSArray *flowerpots = @[@"flowerpotN1",@"flowerpotN2",@"flowerpotN3",@"flowerpotN4"];   //花盆
        NSArray *houses = @[@"houseN1",@"houseN2",@"houseN3",@"houseN4"]; //房子
        NSArray *waters = @[@"waterN1",@"waterN3",@"waterN4"];
        NSArray *trees = @[@"treeN1",@"treeN2",@"treeN3",@"treeN4"];   //树
        NSArray *streetlamps = @[@"streetlampN1",@"streetlampN2",@"streetlampN3"];    //路灯
        NSArray *bridges = @[@"bridgeN1",@"bridgeN2",@"bridgeN3",@"bridgeN4"];    //桥
        //NSArray *cobblestones = @[@"cobblestone1",@"cobblestone2",@"cobblestone3",@"cobblestone4"]; //鹅卵石
        //NSArray *mosses = @[@"moss1",@"moss2"]; //苔藓
        //NSArray *mushrooms = @[@"mushroom1",@"mushroom2",@"mushroom3"]; //蘑菇
        //NSArray *grasses = @[@"grass1",@"grass2"];  //草
        NSArray *plants = @[@"plantN1",@"plantN3",@"plantN4"];
        NSArray *persons = @[@"personN1",@"personN3",@"personN4"];   //人
        NSArray *animals = @[@"animalN1",@"animalN2",@"animalN3",@"animalN4"];    //动物
        //NSArray *stumps = @[@"stump1",@"stump2"];   // 树桩
        NSArray *fences = @[@"fenceN1",@"fenceN2",@"fenceN3",@"fenceN4"]; //栅栏
        NSArray *others = @[@"carN1",@"flowerN2",@"mushroomN4",@"mushroomN5",@"wellN3"];

        _images = @[flowerpots,houses,waters,trees,streetlamps,bridges,plants,persons,animals,fences,others];
    }
    return _images;
}

- (UIView *)tipView
{
    if (!_tipView) {
        _tipView = [[UIView alloc] init];
    }
    return _tipView;
}

@end
