/**
 * PrivacyScreenPlugin.m
 * Created by Tommy-Carlos Williams on 18/07/2014
 * Copyright (c) 2014 Tommy-Carlos Williams. All rights reserved.
 * MIT Licensed
 */
#import "PrivacyScreenPlugin.h"
#import <sys/utsname.h>

static UIImageView *imageView;

@implementation PrivacyScreenPlugin

- (void)pluginInitialize {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification object:nil];
}
- (void)onAppDidBecomeActive:(UIApplication *)application {
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for (int i = 0; i < windows.count; i++) {
        CDVViewController *vc = (CDVViewController*)[[[UIApplication sharedApplication] windows][i] rootViewController];
        if (imageView == NULL) {
            vc.view.window.hidden = NO;
        } else {
            [imageView removeFromSuperview];
        }
    }
}

- (void)onAppWillResignActive:(UIApplication *)application {
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for (int i = 0; i < windows.count; i++) {
        CDVViewController *vc = (CDVViewController*)[[[UIApplication sharedApplication] windows][i] rootViewController];
        NSString *imgName = [self getImageName:[[UIApplication sharedApplication] statusBarOrientation]
                                      delegate:(id<CDVScreenOrientationDelegate>)vc device:[self getCurrentDevice]];
        UIImage *splash = [UIImage imageNamed:imgName];
        if (splash == NULL) {
            imageView = NULL;
            vc.view.window.hidden = YES;
        } else {
            imageView = [[UIImageView alloc]initWithFrame:[self.viewController.view bounds]];
            [imageView setImage:splash];
            [vc.view addSubview:imageView];
        }
    }
}
- (CDV_iOSDevice) getCurrentDevice {
    CDV_iOSDevice device;
    UIScreen* mainScreen = [UIScreen mainScreen];
    CGFloat mainScreenHeight = mainScreen.bounds.size.height;
    CGFloat mainScreenWidth = mainScreen.bounds.size.width;
    int limit = MAX(mainScreenHeight,mainScreenWidth);
    device.iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    device.iPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    device.retina = ([mainScreen scale] == 2.0);
    device.iPhone4 = (device.iPhone && limit == 480.0);
    device.iPhone5 = (device.iPhone && limit == 568.0);
    device.iPhone6 = (device.iPhone && limit == 667.0);
    device.iPhone6Plus = (device.iPhone && limit == 736.0);
    device.iPhoneX  = (device.iPhone && limit == 812.0);
    device.iPhoneXSMAX  = (device.iPhone && limit == 896.0);
    return device;
}

- (NSString*)getImageName:(UIInterfaceOrientation)currentOrientation delegate:(id<CDVScreenOrientationDelegate>)orientationDelegate device:(CDV_iOSDevice)device {
    NSString* imageName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UILaunchImageFile"];
    NSUInteger supportedOrientations = [orientationDelegate supportedInterfaceOrientations];
    BOOL supportsLandscape = (supportedOrientations & UIInterfaceOrientationMaskLandscape);
    if (imageName) {
        imageName = [imageName stringByDeletingPathExtension];
    } else {
        imageName = @"Default";
    }
    if (device.iPhone) {
        if (!supportsLandscape) {
            if (device.iPhone4) {
                imageName = [imageName stringByAppendingString:@"-700"];
            } else if (device.iPhone5) {
                imageName = [imageName stringByAppendingString:@"-700-568h"];
            } else if (device.iPhone6) {
                imageName = [imageName stringByAppendingString:@"-800-667h"];
            } else if (device.iPhone6Plus) {
                imageName = [imageName stringByAppendingString:@"-800-Portrait-736h"];
            } else if (device.iPhoneX) {
                imageName = [imageName stringByAppendingString:@"-1100-Portrait-2436h"];
            } else if (device.iPhoneXSMAX) {
                imageName = [imageName stringByAppendingString:@"-1200-Portrait-2688h"];
            }
        } else {
            if (device.iPhone4) {
                imageName = [imageName stringByAppendingString:@"-960x640"];
            } else if (device.iPhone5) {
                imageName = [imageName stringByAppendingString:@"-1136x640"];
            } else if (device.iPhone6) {
                imageName = [imageName stringByAppendingString:@"-1334x750"];
            } else if (device.iPhone6Plus) {
                imageName = [imageName stringByAppendingString:@"-800-Landscape-736h"];
            } else if (device.iPhoneX) {
                imageName = [imageName stringByAppendingString:@"-1100-Landscape-2436h"];
            } else if (device.iPhoneXSMAX) {
                imageName = [imageName stringByAppendingString:@"-1200-Landscape-2688h"];
            }
        }
    } else if (device.iPad) {
        imageName = [imageName stringByAppendingString:(supportsLandscape ? @"-Landscape" : @"-Portrait")];
    }
    return imageName;
}

@end
