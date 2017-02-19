//
//  ZFHomeViewController.m
//  ZFLocation
//
//  Created by 曾凡怡 on 2017/2/19.
//  Copyright © 2017年 13072785111. All rights reserved.
//

#import "ZFHomeViewController.h"
#import "ZFAddressSelectorController.h"
#import "ZFMapManager.h"

@interface ZFHomeViewController ()


@end

@implementation ZFHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    #pragma mark - 初始化
    _MapMgr;
    
    /// 界面显示需要等待 链接上百度SDK 才能刷新位置成功
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self currentLocAction:nil];
    });
    
    #pragma mark - 监听通知
    /// 监听通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapManagerCityDidChangeNotification:) name:KZFMapManagerCityDidChangeNotification object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapManagerLocationDidSelectedNotification:) name:KZFMapManagerLocationDidSelectedNotification object:nil];
}


#pragma mark - 接收选中的地点,并进行地区更新
- (void)mapManagerLocationDidSelectedNotification:(NSNotification *)noti{
    
    /// 设置当前位置信息
    self.currentLocLabel.text = noti.object[ZFMapNameKEY];
    
    /// 选中热点信息后,搜索当前热点位置,用于更改城市信息
    CGPoint pt = [noti.object[ZFMapPointKEY] CGPointValue];
    NSLog(@"X:%f  Y:%f",pt.x,pt.y);
    CLLocationCoordinate2D point = {pt.y,pt.x};
    [_MapMgr searchCityNameWithCoordinate2D:point];
    
}


#pragma mark - 接收城市和地区更新的消息
- (void)mapManagerCityDidChangeNotification:(NSNotification *)noti
{
    /// 接收城市位置信息
    if (noti.object[ZFMapCityKEY]) {
        self.currentCityLabel.text = noti.object[ZFMapCityKEY];
    }
    
    if (noti.object[ZFMapDistrictKEY]) {
        self.currentDistrict.text = noti.object[ZFMapDistrictKEY];
    }
}

#pragma mark - 获取当前定位信息
- (IBAction)currentLocAction:(id)sender {
    
    //制作弱引用替身
    __weak typeof(self) weakSelf = self;
    [[ZFMapManager sharedInstance] nearByPoi:^(NSArray *poi) {
        /// 获取当前位置信息
        weakSelf.currentLocLabel.text = poi.firstObject[ZFMapNameKEY];
    }];
    
    /// 设置城市位置信息,如果为nil 或通过通知更新
    self.currentCityLabel.text = [ZFMapManager sharedInstance].city;
}


#pragma mark - 进入地图选择器
- (IBAction)pushAction:(id)sender {
    /// 获取地图选择器
    ZFAddressSelectorController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"ZFAddressSelectorController"];
    
    [self.navigationController pushViewController:vc animated:YES];
}



@end
