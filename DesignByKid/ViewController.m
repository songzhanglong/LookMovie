//
//  ViewController.m
//  DesignByKid
//
//  Created by szl on 16/12/26.
//  Copyright © 2016年 江苏迪杰特教育科技股份有限公司. All rights reserved.
//

#import "ViewController.h"
#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "DragViewController.h"
#import <MWPhotoBrowser/MWPhotoBrowser.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController ()<MWPhotoBrowserDelegate>

@property (nonatomic,strong)UIImageView *imageView;
@property (nonatomic,strong)UIImageView *personLeftImg;
@property (nonatomic,strong)UIImageView *personRightImg;
@property (nonatomic,strong)UIButton *leftBtn;
@property (nonatomic,strong)UIButton *middleBtn;
@property (nonatomic,strong)UIButton *rightBtn;
@property (nonatomic,strong)UIButton *leftBackBtn;
@property (nonatomic,strong)UIButton *middleBackBtn;
@property (nonatomic,strong)UIButton *rightBackBtn;
@property (nonatomic,assign)SystemSoundID btnSoundID;
//@property (nonatomic,assign)SystemSoundID beautifulSoundID;
@property (nonatomic,assign)SystemSoundID welcomeSoundID;
@property (nonatomic,strong)MPMoviePlayerController *movieController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.personLeftImg];
    [self.view addSubview:self.personRightImg];
    [self.view addSubview:self.rightBtn];
    [self.view addSubview:self.leftBtn];
    [self.view addSubview:self.middleBtn];
    [self.view addSubview:self.rightBackBtn];
    [self.view addSubview:self.leftBackBtn];
    [self.view addSubview:self.middleBackBtn];
    for (NSInteger i = 0; i < 6; i++) {
        UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"texttip%ld",(long)i + 1]];
        UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
        [self.imageView addSubview:imgView];
    }
    
    [self initialConstraintsOfSubviews];
    [self initSignalSupports];
    [self initialAllSounds];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //默认情况下扬声器播放
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    
    [self performSelector:@selector(beginAnimations) withObject:nil afterDelay:0.1];
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
    [self buttonsAnimations];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

#pragma mark - Private methods
- (void)initialConstraintsOfSubviews
{
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    [self.personLeftImg setFrame:CGRectMake(-self.personLeftImg.image.size.width, [UIScreen mainScreen].bounds.size.height - 45 - self.personLeftImg.image.size.height, self.personLeftImg.image.size.width, self.personLeftImg.image.size.height)];
    [self.personRightImg setFrame:CGRectMake(-self.personRightImg.image.size.width, self.personLeftImg.frame.origin.y, self.personRightImg.image.size.width, self.personRightImg.image.size.height)];
    
    [self.middleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.rightBtn.mas_left).with.offset(-25);
        make.centerY.equalTo(self.rightBtn.mas_centerY).with.offset(10);
    }];
    [self.middleBackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.and.bottom.equalTo(self.middleBtn);
    }];
    
    [self.leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.middleBtn.mas_left).with.offset(-25);
        make.centerY.equalTo(self.middleBtn.mas_centerY);
    }];
    [self.leftBackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.and.bottom.equalTo(self.leftBtn);
    }];
    
    [self.rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).with.offset(-50);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-25);
    }];
    [self.rightBackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.and.bottom.equalTo(self.rightBtn);
    }];
    
    UIView __block *lastView = nil;
    [self.imageView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj mas_makeConstraints:^(MASConstraintMaker *make) {
            if (lastView) {
                make.left.equalTo(lastView.mas_right).with.offset(20);
                make.centerY.equalTo(lastView.mas_centerY);
            }
            else{
                make.left.equalTo(@110);
                make.top.equalTo(@50);
            }
            lastView = obj;
        }];
    }];
}

- (void)initSignalSupports{
    @weakify(self)
    [[self.leftBackBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        // 播放短频音效
        AudioServicesPlayAlertSound(self.btnSoundID);
        
        DragViewController *drag = [[DragViewController alloc] init];
        [self.navigationController pushViewController:drag animated:YES];
    }];
    
    [[self.rightBackBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        // 播放短频音效
        AudioServicesPlayAlertSound(self.btnSoundID);
        
        NSURL *movieURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"IMG_2176" ofType:@"mp4"]];
        self.movieController = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
        self.movieController.scalingMode = MPMovieScalingModeAspectFill;
        [self.movieController prepareToPlay];
        [self.view addSubview:self.movieController.view];//设置写在添加之后   // 这里是addSubView
        self.movieController.shouldAutoplay=YES;
        [self.movieController setControlStyle:MPMovieControlStyleDefault];
        [self.movieController setFullscreen:YES];
        [self.movieController.view setFrame:self.view.bounds];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:) name:MPMoviePlayerDidExitFullscreenNotification object:nil];
    }];
    
    [[self.middleBackBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        // 播放短频音效
        AudioServicesPlayAlertSound(self.btnSoundID);

        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        browser.displayNavArrows = YES;
        browser.displayActionButton = NO;
        [self.navigationController pushViewController:browser animated:YES];
    }];
}

- (void)initialAllSounds
{
    // 加载文件
    NSURL *fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"mainTouchAudio" ofType:@"mp3"]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileURL), &_btnSoundID);
    
//    NSURL *fileBeautifulURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"beautiful" ofType:@"mp3"]];
//    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileBeautifulURL), &_beautifulSoundID);
    
    NSURL *fileWelcomeURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"welcome" ofType:@"mp3"]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileWelcomeURL), &_welcomeSoundID);
    
    AudioServicesPlayAlertSound(self.welcomeSoundID);
}

- (void)beginAnimations
{
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect rightRect = weakSelf.personRightImg.frame;
        [UIView animateWithDuration:1 animations:^{
            [weakSelf.personRightImg setFrame:CGRectMake(110 + weakSelf.personLeftImg.image.size.width, rightRect.origin.y,rightRect.size.width, rightRect.size.height)];
        } completion:^(BOOL finished) {
            
            CGRect leftRect = weakSelf.personLeftImg.frame;
            [UIView animateKeyframesWithDuration:1 delay:3 options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
                [weakSelf.personLeftImg setFrame:CGRectMake(110, leftRect.origin.y,leftRect.size.width, leftRect.size.height)];
            } completion:^(BOOL finished) {
                
            }];
            
        }];
    });
}

- (void)buttonsAnimations
{
    CGFloat alpha = (self.rightBtn.alpha == 1) ? 0.5 : 1;
    [UIView animateWithDuration:1 animations:^{
        [self.leftBtn setAlpha:alpha];
        [self.rightBtn setAlpha:alpha];
        [self.middleBtn setAlpha:alpha];
    } completion:^(BOOL finished) {
        if (finished) {
            [self buttonsAnimations];
        }
    }];
}

#pragma mark - NSNotification
- (void)movieFinishedCallback:(NSNotification*)notify {
    
    MPMoviePlayerController* theMovie = [notify object];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerDidExitFullscreenNotification object:nil];
    
    [theMovie.view removeFromSuperview];
    
    self.movieController = nil;
}

#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return 8;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < 8)
    {
        NSString *name = [NSString stringWithFormat:@"enjoy%ld@2x",(long)index + 1];
        UIImage *img = CREATE_IMG(name);
        return [MWPhoto photoWithImage:img];
    }
    return nil;
}

#pragma mark - lazy load
- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        [_imageView setImage:CREATE_IMG(@"homeback@2x")];
    }
    return _imageView;
}

- (UIImageView *)personLeftImg
{
    if (!_personLeftImg) {
        _personLeftImg = [[UIImageView alloc] init];
        [_personLeftImg setImage:[UIImage imageNamed:@"personLeft.png"]];
    }
    return _personLeftImg;
}

- (UIImageView *)personRightImg
{
    if (!_personRightImg) {
        _personRightImg = [[UIImageView alloc] init];
        [_personRightImg setImage:[UIImage imageNamed:@"personRight.png"]];
    }
    return _personRightImg;
}

- (UIButton *)leftBtn
{
    if (!_leftBtn) {
        _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_leftBtn setImage:[UIImage imageNamed:@"hand"] forState:UIControlStateNormal];
        _leftBtn.userInteractionEnabled = NO;
    }
    return _leftBtn;
}

- (UIButton *)leftBackBtn
{
    if (!_leftBackBtn) {
        _leftBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_leftBackBtn setImage:[UIImage imageNamed:@"hand"] forState:UIControlStateHighlighted];
    }
    return _leftBackBtn;
}

- (UIButton *)middleBackBtn
{
    if (!_middleBackBtn) {
        _middleBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_middleBackBtn setImage:[UIImage imageNamed:@"sapling"] forState:UIControlStateHighlighted];
    }
    return _middleBackBtn;
}

- (UIButton *)rightBackBtn
{
    if (!_rightBackBtn) {
        _rightBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightBackBtn setImage:[UIImage imageNamed:@"television"] forState:UIControlStateHighlighted];
    }
    return _rightBackBtn;
}

- (UIButton *)middleBtn
{
    if (!_middleBtn) {
        _middleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_middleBtn setImage:[UIImage imageNamed:@"sapling"] forState:UIControlStateNormal];
        _middleBtn.userInteractionEnabled = NO;
    }
    return _middleBtn;
}

- (UIButton *)rightBtn
{
    if (!_rightBtn) {
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightBtn setImage:[UIImage imageNamed:@"television"] forState:UIControlStateNormal];
        _rightBtn.userInteractionEnabled = NO;
    }
    return _rightBtn;
}

@end
