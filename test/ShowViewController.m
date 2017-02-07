//
//  ShowViewController.m
//  test
//
//  Created by huangkai on 16/2/23.
//  Copyright © 2016年 huangkai. All rights reserved.
//

#import "ShowViewController.h"
#import "testCollectionViewCell.h"
#include <malloc/malloc.h>

#import <AFNetworking.h>
#import <SDWebImage/UIImageView+WebCache.h>

#import "TKGTWPlanMasterListTableViewCell.h"
#import "TKGTWPlanMasterHeaderView.h"


@interface ShowViewController ()

@property (strong, nonatomic) CALayer *blueLayer;

@property (strong, nonatomic)UIImage *image;

@property (strong, nonatomic)UIImageView *imageView;

@property (strong, nonatomic) NSMutableArray  *heightArr;

@property (strong, nonatomic)UIBezierPath *path;

@property (strong, nonatomic)CAShapeLayer *shapeLayer;

@property (strong, nonatomic) NSMutableArray  *todayArr;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong)TKGTWPlanMasterHeaderView *mMasterHeaderView;

@property (nonatomic, strong)NSString *searchSting;

@end

@implementation ShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - net
- (void)loadNetList{
    NSString *url = @"http://app.gentou.com.cn/servlet/json";
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer]; // 上传普通格式
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSMutableDictionary *reqParam =  [NSMutableDictionary dictionary];
    reqParam[@"funcNo"]        = @"483000";
    reqParam[@"order_flag"]    = @"3";
    reqParam[@"cur_page"]      = @"1";
    reqParam[@"num_per_page"]  = @"200";
    
    [manager GET:url parameters:reqParam progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        
        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSDictionary *data = [ShowViewController jsonStringToData:string];
        NSArray *array = [(NSArray *)[data[@"results"]valueForKey:@"data"]firstObject];
        
        [self getTodayEndData:array];
//         NSLog(@"。。。。。");
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",[error localizedDescription]);
    }];
}

- (void)getTodayEndData:(NSArray *)data{
    for (NSDictionary *dic in data) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *url = @"http://app.gentou.com.cn/servlet/json";
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            manager.requestSerializer = [AFHTTPRequestSerializer serializer]; // 上传普通格式
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            
            NSMutableDictionary *reqParam =  [NSMutableDictionary dictionary];
            reqParam[@"funcNo"]    = @"483008";
            reqParam[@"plan_id"]   = dic[@"plan_id"];
            
            [manager GET:url parameters:reqParam progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                
                NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                
                NSDictionary *data = [ShowViewController jsonStringToData:string];
                NSDictionary *dic = [(NSArray *)data[@"results"] firstObject];
                
                if ([dic[@"end_date"]isEqualToString:self.searchSting] && [dic[@"plan_status"]isEqualToString:@"2"]) {
                    NSDictionary *today_dic = @{
                                                @"user_name": dic[@"user_name"],
                                                @"deposit_money": dic[@"deposit_money"],
                                                @"total_yields": dic[@"total_yields"],
                                                @"profit_rate": dic[@"profit_rate"],
                                                };
                    [self.todayArr addObject:today_dic];
                    [self.tableView reloadData];
                }
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"%@",[error localizedDescription]);
            }];
            
        });
    }
}

#pragma mark - UITableViewDataSource && UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.todayArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"TKGTWPlanMasterListTableViewCell";
    
    TKGTWPlanMasterListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        NSArray *arrayt = [[NSBundle mainBundle] loadNibNamed:@"TKGTWPlanMasterListTableViewCell" owner:nil options:nil];
        cell = [arrayt lastObject];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    [cell initWithData:self.todayArr[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 53;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return self.mMasterHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 42;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.todayArr removeAllObjects];
    self.searchSting = searchBar.text;
    [self loadNetList];
    [self.view endEditing:YES];
}

#pragma mark - public
//压缩图片到指定尺寸大小
+ (UIImage *)compressOriginalImage:(UIImage *)image toSize:(CGSize)size{
    UIImage *resultImage = image;
    UIGraphicsBeginImageContext(size);
    [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIGraphicsEndImageContext();
    return resultImage;
}

//压缩图片到指定文件大小
+ (NSData *)compressOriginalImage:(UIImage *)image toMaxDataSizeKBytes:(CGFloat)size{
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    CGFloat dataKBytes = data.length/1000.0;
    CGFloat maxQuality = 0.9f;
    CGFloat lastData = dataKBytes;
    
    NSTimeInterval start = [NSDate date].timeIntervalSince1970;
    int i = 0;
    
    while (dataKBytes > size && maxQuality > 0.01f) {
        i++;
        
        float delQuality = 0;
    
        if (data.length > 1024 * 1024 * 10) {
            delQuality = 0.8f;
        }else if(data.length > 1024 * 1024 * 5){
            delQuality = 0.5f;
        }else if(data.length > 1024 * 1024 * 2){
            delQuality = 0.1f;
        }else {
            delQuality = 0.01f;
        }
        
        maxQuality = maxQuality - delQuality;
        data = UIImageJPEGRepresentation(image, maxQuality);
        
        dataKBytes = data.length/1000.0;
        if (lastData == dataKBytes) {
            break;
        }else{
            lastData = dataKBytes;
        }
    }
    NSTimeInterval end = [NSDate date].timeIntervalSince1970;
    
    double time = end - start;
    NSLog(@"time = %f", time);
    NSLog(@"i = %d", i);
    
    return data;
}

//压缩图片，这个压缩得还是挺明显的
+(UIImage *)imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size scale:(CGFloat)scale{
    
    NSTimeInterval start = [NSDate date].timeIntervalSince1970;
    int j = 0;
    
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    
    CGFloat width = imageSize.width;
    
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = size.width;
    
    CGFloat targetHeight = size.height;
    
    CGFloat scaleFactor = 0.0;
    
    CGFloat scaledWidth = targetWidth;
    
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if(CGSizeEqualToSize(imageSize, size) == NO){
        
        CGFloat widthFactor = targetWidth / width;
        
        CGFloat heightFactor = targetHeight / height;
        
        if(widthFactor > heightFactor){
            
            scaleFactor = widthFactor;
            
        }
        
        else{
            
            scaleFactor = heightFactor;
            
        }
        
        scaledWidth = width * scaleFactor;
        
        scaledHeight = height * scaleFactor;
        
        if(widthFactor > heightFactor){
            
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            
        }else if(widthFactor < heightFactor){
            
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            
        }
        
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    
    CGRect thumbnailRect = CGRectZero;
    
    thumbnailRect.origin = thumbnailPoint;
    
    thumbnailRect.size.width = scaledWidth;
    
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil){
        
        NSLog(@"scale image fail");
        
    }
    
    UIGraphicsEndImageContext();
    
    NSTimeInterval end = [NSDate date].timeIntervalSince1970;
    
    double time = end - start;
    NSLog(@"time = %f", time);
    NSLog(@"j = %d", j);
    
    return newImage;
    
}

+(NSString*)dataTojsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:0
                                                         error:&error];
    if (! jsonData) {
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

+(id)jsonStringToData:(NSString *)json_string{
    id object = nil;
    NSError *error;
    NSData *data = [json_string dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        ;
    }else{
        object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    }
    
    return object;
}

- (void)getImageBy:(NSDictionary *)data{
    // 占位图片
    UIImage *placeholder = [UIImage imageNamed:@"test2.jpg"];
    
    // 从内存\沙盒缓存中获得原图
    UIImage *originalImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:data[@"picture_url"]];
    if (originalImage) { // 如果内存\沙盒缓存有原图，那么就直接显示原图（不管现在是什么网络状态）
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:data[@"picture_url"]] placeholderImage:placeholder];
    } else { // 内存\沙盒缓存没有原图
        AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
        if (mgr.isReachableViaWiFi) { // 在使用Wifi, 下载原图
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:data[@"picture_url"]] placeholderImage:placeholder];
        } else if (mgr.isReachableViaWWAN) { // 在使用手机自带网络
                // 用户的配置项假设利用NSUserDefaults存储到了沙盒中
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"alwaysDownloadOriginalImage"];
                [[NSUserDefaults standardUserDefaults] synchronize];

            BOOL alwaysDownloadOriginalImage = [[NSUserDefaults standardUserDefaults] boolForKey:@"alwaysDownloadOriginalImage"];
            if (alwaysDownloadOriginalImage) { // 下载原图
                [self.imageView sd_setImageWithURL:[NSURL URLWithString:data[@"picture_url"]] placeholderImage:placeholder];
            } else { // 下载小图
                [self.imageView sd_setImageWithURL:[NSURL URLWithString:data[@"thumbnailImage"]] placeholderImage:placeholder];
            }
        } else { // 没有网络
            UIImage *thumbnailImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:data[@"thumbnailImage"]];
            if (thumbnailImage) { // 内存\沙盒缓存中有小图
                [self.imageView sd_setImageWithURL:[NSURL URLWithString:data[@"thumbnailImage"]] placeholderImage:placeholder];
            } else {
//                [self.imageView sd_setImageWithURL:nil placeholderImage:placeholder];
                [self.imageView sd_setImageWithURL:[NSURL URLWithString:data[@"picture_url"]] placeholderImage:placeholder];
            }
        }
    }
}

#pragma mark - actions
- (void)animtationTest{
    
    CAKeyframeAnimation *rectRunAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    //设定关键帧位置，必须含起始与终止位置
    rectRunAnimation.values = @[[NSValue valueWithCGPoint:self.blueLayer.frame.origin],
                                [NSValue valueWithCGPoint:CGPointMake(320 - 80, self.blueLayer.frame.origin.y)],
                                [NSValue valueWithCGPoint:CGPointMake(320 - 80, self.blueLayer.frame.origin.y + 100)],
                                [NSValue valueWithCGPoint:CGPointMake(self.blueLayer.frame.origin.x, self.blueLayer.frame.origin.y + 100)],
                                [NSValue valueWithCGPoint:self.blueLayer.frame.origin]];
    
    //设定每个关键帧的时长，如果没有显式地设置，则默认每个帧的时间=总duration/(values.count - 1)
    rectRunAnimation.keyTimes = @[[NSNumber numberWithFloat:0.0],
                                  [NSNumber numberWithFloat:0.4],
                                  [NSNumber numberWithFloat:0.6],
                                  [NSNumber numberWithFloat:0.8],
                                  [NSNumber numberWithFloat:1]];
    
    rectRunAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                         [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
                                         [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
                                         [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    
    rectRunAnimation.repeatCount = 1000;
    rectRunAnimation.autoreverses = NO;
    rectRunAnimation.calculationMode = kCAAnimationLinear;
    rectRunAnimation.duration = 4;
    
    [self.blueLayer addAnimation:rectRunAnimation forKey:@"rectRunAnimation"];
}

#pragma mark - getters
-(CALayer *)blueLayer{
    if (!_blueLayer) {
        _blueLayer = [CALayer layer];
        _blueLayer.frame = CGRectMake(50.0f, 80.0f, 300.0f, 200.f);
        _blueLayer.contents = (__bridge id)self.image.CGImage;

    }
    
    return _blueLayer;
}


-(UIImage *)image{
    if (!_image) {
        _image = [UIImage imageNamed:@"test"];
    }
    
    return _image;
}

-(UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(50, 300, 300,200)];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.image = self.image;
    }
    
    return _imageView;
}


- (UIBezierPath *)path{
    if (!_path) {
        _path = [UIBezierPath bezierPathWithRoundedRect:self.imageView.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(10, 10)];
    }
    return _path;
}

- (CAShapeLayer *)shapeLayer{
    if(!_shapeLayer){
        _shapeLayer = [[CAShapeLayer alloc] init];
        _shapeLayer.path  = self.path.CGPath;
        _shapeLayer.frame = self.imageView.bounds;
    }
    return _shapeLayer;
}

- (NSMutableArray *)todayArr{
    if (!_todayArr) {
        _todayArr = [NSMutableArray array];
    }
    return _todayArr;
}

- (TKGTWPlanMasterHeaderView *)mMasterHeaderView{
    if (!_mMasterHeaderView) {
        _mMasterHeaderView = [[TKGTWPlanMasterHeaderView alloc]initView];
    }
    return _mMasterHeaderView;
}

@end
