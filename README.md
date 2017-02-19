# ZFMapManager

![选择地点](http://ogrzc8ghg.bkt.clouddn.com/mapManager.gif)
![搜索地点](http://ogrzc8ghg.bkt.clouddn.com/sousuo.gif)

管理定位模块
使用说明:    
-  您需要在您的Xcode工程中引入
                        CoreLocation.framework,   
                        QuartzCore.framework、   
                        OpenGLES.framework、   
                        SystemConfiguration.framework、   
                        CoreGraphics.framework、     
                        Security.framework、   
                        libsqlite3.0.tbd（xcode7以前为 libsqlite3.0.dylib）、   
                        CoreTelephony.framework 、   
                        libstdc++.6.0.9.tbd   
                        下图所示所有百度SDK     
                        mapapi.bundle 路径:BaiduMapAPI_Map.framework/Resources
 
![mapapi.bundle 路径:BaiduMapAPI_Map.framework/Resources](http://ogrzc8ghg.bkt.clouddn.com/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202017-02-19%20%E4%B8%8B%E5%8D%886.05.21.png)



-  添加支持HTTPS所需的penssl静态库：libssl.a和libcrypto.a（SDK打好的包存放于Framework目录下）
 添加方法： 在 TARGETS->Build Phases-> Link Binary With Libaries中点击“+”按钮，在弹出的窗口中点击“Add Other”按钮，选择libssl.a和libcrypto.a添加到工程中
 
 
- 从BaiduMapAPI_Map.framework||Resources文件中选择mapapi.bundle文件，并勾选“Copy items if needed”复选框，单击“Add”按钮，将资源文件添加到工程中。
 
 
 
-  在TARGETS->Build Settings->Other Linker Flags 中添加-ObjC。
 
 
 
- 添加定位允许 NSLocationWhenInUseUsageDescription


-  [百度SDK需要自己下载](http://mapopen-pub-iossdk.bj.bcebos.com/map/v3_2_1/all/BaiduMap_IOSSDK_v3.2.1_All.zip)


- 构造函数 使用前还需要先配置自己的AK 在构造函数内. `ZFMapManager.m`  L : 76

```
- (instancetype)init
{
    self = [super init];
    if (self) {
        // 要使用百度地图，请先启动BaiduMapManager
        _mapManager = [[BMKMapManager alloc]init];
        // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
        // BundleID 为 net.yeah.fanyizeng.---- 如果无法使用请更换为自己注册的BundleID
        BOOL ret = [_mapManager start:@"tUWhg88bXiiBnR39fri78LBhTEc0bN95"  generalDelegate:nil];
        if (!ret) {
            NSLog(@"manager start failed!");
        }
        ...
```


## 使用接口
使用`ZFMapManager`提供的方法进行地图操作


- 初始化
```
// 第一次调用_MapMgr 会对百度SDK进行初始化,可以参见 init 函数 SDK所有的数据访问功能依赖于初始化,所以请在使用前提前构造Manager
#define _MapMgr ([ZFMapManager sharedInstance])
// 使用宏定义调用Manager 用于向百度注册你的AK 这一步可以在程序启动时操作.
_MapMgr;
/// 界面显示需要等待 链接上百度SDK 才能刷新位置成功 可以使用延迟,来保证成功获取定位
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //Demo中获取定位的方法  
        [self currentLocAction:nil];
    });
```

- 获取当前城市

```
/// 当前城市 可能为nil 获取一次后如果为nil会自动刷新当前城市位置,并抛出通知. 
/// 设置城市位置信息,如果为nil 会自动通过通知中心来更新
    self.currentCityLabel.text = _MapMgr.city;

 /// 注册通知 可以对通知进行监听,获取最新的所在城市信息 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapManagerCityDidChangeNotification:) name:KZFMapManagerCityDidChangeNotification object:nil];

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

```


- 获取当前定位信息,可以帮助用户确定一个大致准确的当前地址.

```
    //制作弱引用替身
    __weak typeof(self) weakSelf = self;
    [_MapMgr nearByPoi:^(NSArray *poi) {
        /// 获取当前位置信息
        weakSelf.currentLocLabel.text = poi.firstObject[ZFMapNameKEY];
    }];
    

```


- 进入地图选择器 直接初始化 `ZFAddressSelectorController` 
```
/// 获取地图选择器
    ZFAddressSelectorController *vc = [ZFAddressSelectorController new];//[[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"ZFAddressSelectorController"];
    
    [self.navigationController pushViewController:vc animated:YES];
```

- 获取选择器选择的地址

```
/// 选择的地点. 这个通知如果不使用 ZFAddressSelectorController类 需要自己手动实现POST部分 他响应了Demo中的cell点击
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapManagerLocationDidSelectedNotification:) name:KZFMapManagerLocationDidSelectedNotification object:nil];

#pragma mark - 接收选中的地点,并进行地区更新
- (void)mapManagerLocationDidSelectedNotification:(NSNotification *)noti{
    
    /// 设置当前位置信息
    self.currentLocLabel.text = noti.object[ZFMapNameKEY];
    
    /// 选中热点信息后,可以搜索当前热点位置,用于更改城市信息
    CGPoint pt = [noti.object[ZFMapPointKEY] CGPointValue];
    NSLog(@"X:%f  Y:%f",pt.x,pt.y);
    CLLocationCoordinate2D point = {pt.y,pt.x};
    [_MapMgr searchCityNameWithCoordinate2D:point];
    
}

```



- 如何自定义界面
1. tableView的样式定制,可以在`ZFAddressSelectorController`对`tb`属性进行定制
2. mapView界面中,定位按钮和选择按钮可以在`ZFMapView.m` L:49-70行进行样式定制
3. searchBar是tableView的表头视图.