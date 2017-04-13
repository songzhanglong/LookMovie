//
//  GlobalManager.m
//  print
//
//  Created by szl on 2017/3/1.
//  Copyright © 2017年 江苏迪杰特教育科技股份有限公司. All rights reserved.
//

#import "GlobalManager.h"
#import <CoreText/CoreText.h>

@implementation GlobalManager

+ (UIFont *)customFontWithName:(NSString *)name size:(CGFloat)size
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    if (![fileManager fileExistsAtPath:path]) {
        return [UIFont systemFontOfSize:size];
    }
    
    NSURL *fontUrl = [NSURL fileURLWithPath:path];
    CGDataProviderRef fontDataProvider = CGDataProviderCreateWithURL((__bridge CFURLRef)fontUrl);
    CGFontRef fontRef = CGFontCreateWithDataProvider(fontDataProvider);
    CGDataProviderRelease(fontDataProvider);
    CTFontManagerRegisterGraphicsFont(fontRef, NULL);
    NSString *fontName = CFBridgingRelease(CGFontCopyPostScriptName(fontRef));
    UIFont *font = [UIFont fontWithName:fontName size:size];
    CGFontRelease(fontRef);
    return font;
}

@end
