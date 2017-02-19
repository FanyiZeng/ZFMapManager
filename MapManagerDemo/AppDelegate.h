//
//  ZFAppDelegate.h
//  ZFLocation
//
//  Created by 13072785111 on 02/18/2017.
//  Copyright (c) 2017 13072785111. All rights reserved.
//

@import UIKit;
# warning 1. 在您的AppDelegate.h文件中添加BMKMapManager的定义
/*
 1.
 您需要在您的Xcode工程中引入CoreLocation.framework,
                        QuartzCore.framework、
                        OpenGLES.framework、
                        SystemConfiguration.framework、
                        CoreGraphics.framework、 
                        Security.framework、
                        libsqlite3.0.tbd（xcode7以前为 libsqlite3.0.dylib）、
                        CoreTelephony.framework 、
                        libstdc++.6.0.9.tbd
                        以及Framework文件夹中的所有文件
 
 2.
 添加支持HTTPS所需的penssl静态库：libssl.a和libcrypto.a（SDK打好的包存放于Framework目录下）
 添加方法： 在 TARGETS->Build Phases-> Link Binary With Libaries中点击“+”按钮，在弹出的窗口中点击“Add Other”按钮，选择libssl.a和libcrypto.a添加到工程中
 
 
 3.
 从BaiduMapAPI_Map.framework||Resources文件中选择mapapi.bundle文件，并勾选“Copy items if needed”复选框，单击“Add”按钮，将资源文件添加到工程中。
 
 
 
 4. 在TARGETS->Build Settings->Other Linker Flags 中添加-ObjC。
 
 
 
 5. 添加定位允许 NSLocationWhenInUseUsageDescription
 */


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
