//
//  ZFViewController.m
//  ZFLocation
//
//  Created by 13072785111 on 02/18/2017.
//  Copyright (c) 2017 13072785111. All rights reserved.
//

#import "ZFAddressSelectorController.h"
#import "ZFHomeViewController.h"
#import "ZFMapManager.h"
#import "ZFAddressCell.h"
@interface ZFAddressSelectorController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>

@property(nonatomic,weak)ZFMapView *mapView;

@property(nonatomic,strong)NSArray *poiArr;

@property (weak, nonatomic) UITableView *addressTableView;

@end

@implementation ZFAddressSelectorController



- (void)viewDidLoad
{
    [super viewDidLoad];
    //获取一个地图,添加到界面上
    ZFMapView *map = [[ZFMapManager sharedInstance] getMap];
    self.mapView = map;
    map.frame = CGRectMake(0, 0, self.view.bounds.size.width, 350);
    [self.view addSubview:map];
    
    // 添加一个tableView 显示地址信息结果
    UITableView *addressTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 350, self.view.bounds.size.width, self.view.bounds.size.height - 350) style:UITableViewStylePlain];
    self.addressTableView = addressTableView;
    addressTableView.delegate = self;
    addressTableView.dataSource = self;
    
    [addressTableView registerClass:[ZFAddressCell class] forCellReuseIdentifier:@"CELL"];
    
    [self.view addSubview:addressTableView];
    
    
    /// 添加一个search Bar
    UISearchBar *searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 0, 40)];
    self.addressTableView.tableHeaderView = searchBar;
    searchBar.delegate = self;
    
    /// 注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapManagerPoiDidUpdateNotification:) name:KZFMapManagerPoiDidUpdateNotification object:nil];
}


- (void)mapManagerPoiDidUpdateNotification:(NSNotification *)noti
{
    self.poiArr = noti.object;
    [self.addressTableView reloadData];
}

#pragma mark - 周围热点信息
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.poiArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZFAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL" forIndexPath:indexPath];

    cell.textLabel.text = self.poiArr[indexPath.row][ZFMapNameKEY];
    float distance = [self.poiArr[indexPath.row][ZFMapDistanceKEY] floatValue] / 1000;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"距您 %.1f 公里 %@",distance,self.poiArr[indexPath.row][ZFMapAddressKEY]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /// 用户的主动操作都需要主动更新城市信息
    _MapMgr.isUpdateCity = YES;
    ///通知外层控制器选择的哪个地址
    [[NSNotificationCenter defaultCenter] postNotificationName:KZFMapManagerLocationDidSelectedNotification object:self.poiArr[indexPath.row]];
    /// pop
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [[ZFMapManager sharedInstance] searchWithKeyword:searchText];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
