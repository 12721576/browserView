//
//  XLPhotoBrowser.m
//  XLPhotoBrowserDemo
//
//  Created by Liushannoon on 16/7/16.
//  Copyright © 2016年 LiuShannoon. All rights reserved.
//

#import "XLPhotoBrowser.h"
#import "XLZoomingScrollView.h"

@interface XLPhotoBrowser () <XLZoomingScrollViewDelegate , UIScrollViewDelegate>

/**
 *  存放所有图片的容器
 */
@property (nonatomic , strong) UIScrollView  *scrollView;
/**
 *   保存图片的过程指示菊花
 */
@property (nonatomic , strong) UIActivityIndicatorView  *indicatorView;
/**
 *  正在使用的XLZoomingScrollView对象集
 */
@property (nonatomic , strong) NSMutableSet  *visibleZoomingScrollViews;
/**
 *  循环利用池中的XLZoomingScrollView对象集,用于循环利用
 */
@property (nonatomic , strong) NSMutableSet  *reusableZoomingScrollViews;

/**
 *  index label
 */
@property (nonatomic , strong) UILabel  *indexLabel;
/**
 *  保存按钮
 */
@property (nonatomic , strong) UIButton *saveButton;

@property(nonatomic, strong) NSArray *images;

@end

@implementation XLPhotoBrowser

#pragma mark    -   set / get

- (void)setBrowserStyle:(XLPhotoBrowserStyle)browserStyle
{
    _browserStyle = browserStyle;
    [self setUpBrowserStyle];
}


#pragma mark    -   initial

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initial];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initial];
    }
    return self;
}

- (void)initial
{
    self.backgroundColor = XLPhotoBrowserBackgrounColor;
    self.visibleZoomingScrollViews = [[NSMutableSet alloc] init];
    self.reusableZoomingScrollViews = [[NSMutableSet alloc] init];
    [self placeholderImage];
    
    _browserStyle = XLPhotoBrowserStylePageControl;
    
    self.currentImageIndex = 0;
    self.imageCount = 0;
}

- (void)iniaialUI
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self setUpScrollView];
    [self setUpToolBars];
    [self setUpBrowserStyle];
    [self showFirstImage];
    [self updatePageControlIndex];
}

- (void)setUpScrollView
{
    CGRect rect = self.bounds;
    rect.size.width += XLPhotoBrowserImageViewMargin;
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.frame = rect;
    self.scrollView.xl_x = 0;
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.contentSize = CGSizeMake((self.scrollView.frame.size.width) * self.imageCount, 0);
    [self addSubview:self.scrollView];
    self.scrollView.contentOffset = CGPointMake(self.currentImageIndex * (self.scrollView.frame.size.width), 0);
    if (self.currentImageIndex == 0) { // 修复bug , 如果刚进入的时候是0,不会调用scrollViewDidScroll:方法,不会展示第一张图片
        [self showPhotos];
    }
}

- (void)setUpToolBars
{
    UILabel *indexLabel = [[UILabel alloc] init];
    indexLabel.bounds = CGRectMake(0, 0, 80, 30);
    indexLabel.xl_centerX = self.xl_width * 0.5;
    indexLabel.xl_centerY = 35;
    indexLabel.textAlignment = NSTextAlignmentCenter;
    indexLabel.textColor = [UIColor whiteColor];
    indexLabel.font = [UIFont systemFontOfSize:18];
    indexLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    indexLabel.layer.cornerRadius = indexLabel.bounds.size.height * 0.5;
    indexLabel.clipsToBounds = YES;
    self.indexLabel = indexLabel;
    [self addSubview:indexLabel];
    
    UIButton *saveButton = [[UIButton alloc] init];
    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    saveButton.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.90f];
    saveButton.layer.cornerRadius = 5;
    saveButton.clipsToBounds = YES;
    [saveButton addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
    saveButton.frame = CGRectMake(30, self.bounds.size.height - 70, 50, 25);
    self.saveButton = saveButton;
    [self addSubview:saveButton];
}

- (void)setUpBrowserStyle
{
    switch (self.browserStyle) {
        case XLPhotoBrowserStylePageControl:
        {
            self.indexLabel.hidden = YES;
            self.saveButton.hidden = YES;
        }
            break;
        case XLPhotoBrowserStyleIndexLabel:
        {
            self.indexLabel.hidden = NO;
            self.saveButton.hidden = YES;
        }
            break;
        case XLPhotoBrowserStyleSimple:
        {
            self.indexLabel.hidden = NO;
            self.saveButton.hidden = NO;
        }
            break;
        default:
            break;
    }
}

- (void)dealloc
{
    [self.reusableZoomingScrollViews removeAllObjects];
    [self.visibleZoomingScrollViews removeAllObjects];
}

#pragma mark    -   private method

- (UIWindow *)findTheMainWindow
{
    NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
    for (UIWindow *window in frontToBackWindows) {
        BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
        BOOL windowIsVisible = !window.hidden && window.alpha > 0;
        BOOL windowLevelSupported = (window.windowLevel >= UIWindowLevelNormal);
        
        if(windowOnMainScreen && windowIsVisible && windowLevelSupported) {
            return window;
        }
    }
    return [[[UIApplication sharedApplication] delegate] window];
}

#pragma mark    -   private -- 长按图片相关

- (void)longPress:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        
    }
}

#pragma mark    -   private -- save image

- (void)saveImage
{
    ;
}

#pragma mark    -   private ---loadimage

- (void)showPhotos
{
    // 只有一张图片
    if (self.imageCount == 1) {
        [self setUpImageForZoomingScrollViewAtIndex:0];
        return;
    }
    
    CGRect visibleBounds = self.scrollView.bounds;
    NSInteger firstIndex = floor((CGRectGetMinX(visibleBounds)) / CGRectGetWidth(visibleBounds));
    NSInteger lastIndex  = floor((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
    
    if (firstIndex < 0) {
        firstIndex = 0;
    }
    if (firstIndex >= self.imageCount) {
        firstIndex = self.imageCount - 1;
    }
    if (lastIndex < 0){
        lastIndex = 0;
    }
    if (lastIndex >= self.imageCount) {
        lastIndex = self.imageCount - 1;
    }
    
    // 回收不再显示的zoomingScrollView
    NSInteger zoomingScrollViewIndex = 0;
    for (XLZoomingScrollView *zoomingScrollView in self.visibleZoomingScrollViews) {
        zoomingScrollViewIndex = zoomingScrollView.tag - 100;
        if (zoomingScrollViewIndex < firstIndex || zoomingScrollViewIndex > lastIndex) {
            [self.reusableZoomingScrollViews addObject:zoomingScrollView];
            [zoomingScrollView prepareForReuse];
            [zoomingScrollView removeFromSuperview];
        }
    }
    
    // _visiblePhotoViews 减去 _reusablePhotoViews中的元素
    [self.visibleZoomingScrollViews minusSet:self.reusableZoomingScrollViews];
    while (self.reusableZoomingScrollViews.count > 2) { // 循环利用池中最多保存两个可以用对象
        [self.reusableZoomingScrollViews removeObject:[self.reusableZoomingScrollViews anyObject]];
    }
    
    // 展示图片
    for (NSInteger index = firstIndex; index <= lastIndex; index++) {
        if (![self isShowingZoomingScrollViewAtIndex:index]) {
            [self setUpImageForZoomingScrollViewAtIndex:index];
        }
    }
}

/**
 *  判断指定的某个位置图片是否在显示
 */
- (BOOL)isShowingZoomingScrollViewAtIndex:(NSInteger)index
{
    for (XLZoomingScrollView* view in self.visibleZoomingScrollViews) {
        if ((view.tag - 100) == index) {
            return YES;
        }
    }
    return NO;
}

/**
 *  获取指定位置的XLZoomingScrollView , 三级查找,正在显示的池,回收池,创建新的并赋值
 *
 *  @param index 指定位置索引
 */
- (XLZoomingScrollView *)zoomingScrollViewAtIndex:(NSInteger)index
{
    for (XLZoomingScrollView* zoomingScrollView in self.visibleZoomingScrollViews) {
        if ((zoomingScrollView.tag - 100) == index) {
            return zoomingScrollView;
        }
    }
    XLZoomingScrollView* zoomingScrollView = [self dequeueReusableZoomingScrollView];
    [self setUpImageForZoomingScrollViewAtIndex:index];
    return zoomingScrollView;
}

/**
 *   加载指定位置的图片
 */
- (void)setUpImageForZoomingScrollViewAtIndex:(NSInteger)index
{
    XLZoomingScrollView *zoomingScrollView = [self dequeueReusableZoomingScrollView];
    zoomingScrollView.zoomingScrollViewdelegate = self;
    [zoomingScrollView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)]];
    zoomingScrollView.tag = 100 + index;
    zoomingScrollView.frame = CGRectMake((self.scrollView.xl_width) * index, 0, self.xl_width, self.xl_height);
    self.currentImageIndex = index;
    if (zoomingScrollView.hasLoadedImage == NO) {
        if ([self highQualityImageURLForIndex:index]) { // 如果提供了高清大图数据源,就去加载
            [zoomingScrollView setShowHighQualityImageWithURL:[self highQualityImageURLForIndex:index] placeholderImage:[self placeholderImageForIndex:index]];
        } else if ([self assetForIndex:index]) {
            ALAsset *asset = [self assetForIndex:index];
            CGImageRef imageRef = asset.defaultRepresentation.fullScreenImage;
            [zoomingScrollView setShowImage:[UIImage imageWithCGImage:imageRef]];
            CGImageRelease(imageRef);
        } else {
            [zoomingScrollView setShowImage:[self placeholderImageForIndex:index]];
        }
        zoomingScrollView.hasLoadedImage = YES;
    }
    
    [self.visibleZoomingScrollViews addObject:zoomingScrollView];
    [self.scrollView addSubview:zoomingScrollView];
}

/**
 *  从缓存池中获取一个XLZoomingScrollView对象
 */
- (XLZoomingScrollView *)dequeueReusableZoomingScrollView
{
    XLZoomingScrollView *photoView = [self.reusableZoomingScrollViews anyObject];
    if (photoView) {
        [self.reusableZoomingScrollViews removeObject:photoView];
    } else {
        photoView = [[XLZoomingScrollView alloc] init];
    }
    return photoView;
}

/**
 *  获取指定位置的占位图片,和外界的数据源交互
 */
- (UIImage *)placeholderImageForIndex:(NSInteger)index
{
    if (self.datasource && [self.datasource respondsToSelector:@selector(photoBrowser:placeholderImageForIndex:)]) {
        return [UIImage imageNamed:@"test"];
//        return [self.datasource photoBrowser:self placeholderImageForIndex:index];
    } else if(self.images.count>index) {
        if ([self.images[index] isKindOfClass:[UIImage class]]) {
            return self.images[index];
        } else {
            return self.placeholderImage;
        }
    }
    return self.placeholderImage;
}

/**
 *  获取指定位置的高清大图URL,和外界的数据源交互
 */
- (NSURL *)highQualityImageURLForIndex:(NSInteger)index
{
    if (self.datasource && [self.datasource respondsToSelector:@selector(photoBrowser:highQualityImageURLForIndex:)]) {
        NSURL *url = [self.datasource photoBrowser:self highQualityImageURLForIndex:index];
        if (!url) {
           
            return nil;
        }
        if ([url isKindOfClass:[NSString class]]) {
            url = [NSURL URLWithString:(NSString *)url];
        }
        if (![url isKindOfClass:[NSURL class]]) {
            ;
        }
        return url;
    } else if(self.images.count>index) {
        if ([self.images[index] isKindOfClass:[NSURL class]]) {
            return self.images[index];
        } else if ([self.images[index] isKindOfClass:[NSString class]]) {
            NSURL *url = [NSURL URLWithString:self.images[index]];
            return url;
        } else {
            return nil;
        }
    }
    return nil;
}

/**
 *  获取指定位置的 ALAsset,获取图片
 */
- (ALAsset *)assetForIndex:(NSInteger)index
{
    if (self.datasource && [self.datasource respondsToSelector:@selector(photoBrowser:assetForIndex:)]) {
        return [self.datasource photoBrowser:self assetForIndex:index];
    } else if (self.images.count > index) {
        if ([self.images[index] isKindOfClass:[ALAsset class]]) {
            return self.images[index];
        } else {
            return nil;
        }
    }
    return nil;
}

/**
 *  获取多图浏览,指定位置图片的UIImageView视图,用于做弹出放大动画和回缩动画
 */
- (UIView *)sourceImageViewForIndex:(NSInteger)index
{
    if (self.datasource && [self.datasource respondsToSelector:@selector(photoBrowser:sourceImageViewForIndex:)]) {
        return [self.datasource photoBrowser:self sourceImageViewForIndex:index];
    }
    return nil;
}

/**
 *  第一个展示的图片 , 点击图片,放大的动画就是从这里来的
 */
- (void)showFirstImage
{
    // 获取到用户点击的那个UIImageView对象,进行坐标转化
    CGRect startRect;
    if (self.sourceImageView) {
        
    } else if(self.datasource && [self.datasource respondsToSelector:@selector(photoBrowser:sourceImageViewForIndex:)]) {
        self.sourceImageView = [self.datasource photoBrowser:self sourceImageViewForIndex:self.currentImageIndex];
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            self.alpha = 1.0;
        }];
        return;
    }
    startRect = [self.sourceImageView.superview convertRect:self.sourceImageView.frame toView:self];
    
    UIImageView *tempView = [[UIImageView alloc] init];
    tempView.image = [self placeholderImageForIndex:self.currentImageIndex];
    tempView.frame = startRect;
    [self addSubview:tempView];
    
    CGRect targetRect; // 目标frame
    UIImage *image = self.sourceImageView.image;
    CGFloat imageWidthHeightRatio = image.size.width / image.size.height;
    CGFloat width = XLScreenW;
    CGFloat height = XLScreenW / imageWidthHeightRatio;
    CGFloat x = 0;
    CGFloat y;
    if (height > XLScreenH) {
        y = 0;
    } else {
        y = (XLScreenH - height ) * 0.5;
    }
    targetRect = CGRectMake(x, y, width, height);
    self.scrollView.hidden = YES;
    self.alpha = 1.0;

    // 动画修改图片视图的frame , 居中同时放大
    [UIView animateWithDuration:XLPhotoBrowserShowImageAnimationDuration animations:^{
        tempView.frame = targetRect;
    } completion:^(BOOL finished) {
        [tempView removeFromSuperview];
        self.scrollView.hidden = NO;
    }];
}

#pragma mark    -   XLZoomingScrollViewDelegate

/**
 *  单击图片,退出浏览
 */
- (void)zoomingScrollView:(XLZoomingScrollView *)zoomingScrollView singleTapDetected:(UITapGestureRecognizer *)singleTap
{
    NSInteger currentIndex = zoomingScrollView.tag - 100;
    UIView *sourceView = [self sourceImageViewForIndex:currentIndex];
    if (sourceView == nil) {
        [self dismiss];
        return;
    }
    self.scrollView.hidden = YES;
    self.indexLabel.hidden = YES;
    self.saveButton.hidden = YES;

    CGRect targetTemp = [sourceView.superview convertRect:sourceView.frame toView:self];
    
    UIImageView *tempView = [[UIImageView alloc] init];
    tempView.contentMode = sourceView.contentMode;
    tempView.clipsToBounds = YES;
    tempView.image = zoomingScrollView.currentImage;
    tempView.frame = CGRectMake( - zoomingScrollView.contentOffset.x + zoomingScrollView.imageView.xl_x,  - zoomingScrollView.contentOffset.y + zoomingScrollView.imageView.xl_y, zoomingScrollView.imageView.xl_width, zoomingScrollView.imageView.xl_height);
    [self addSubview:tempView];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [UIView animateWithDuration:XLPhotoBrowserHideImageAnimationDuration animations:^{
        tempView.frame = targetTemp;
        self.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self showPhotos];
    NSInteger pageNum = floor((scrollView.contentOffset.x + scrollView.bounds.size.width * 0.5) / scrollView.bounds.size.width);
    self.currentImageIndex = pageNum == self.imageCount ? pageNum - 1 : pageNum;
    [self updatePageControlIndex];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger pageNum = floor((scrollView.contentOffset.x + scrollView.bounds.size.width * 0.5) / scrollView.bounds.size.width);
    self.currentImageIndex = pageNum == self.imageCount ? pageNum - 1 : pageNum;
    [self updatePageControlIndex];
}

/**
 *  修改图片指示索引label
 */
- (void)updatePageControlIndex
{
    if (self.imageCount == 1 ) {
        self.indexLabel.hidden = YES;
        return;
    }

    NSString *title = [NSString stringWithFormat:@"%zd / %zd",self.currentImageIndex+1,self.imageCount];
    self.indexLabel.text = title;
    
    [self setUpBrowserStyle];
}

#pragma mark    -   public method

/**
 *  快速创建并进入图片浏览器
 *
 *  @param currentImageIndex 开始展示的图片索引
 *  @param imageCount        图片数量
 *  @param datasource        数据源
 *
 */
+ (instancetype)showPhotoBrowserWithCurrentImageIndex:(NSInteger)currentImageIndex imageCount:(NSUInteger)imageCount datasource:(id<XLPhotoBrowserDatasource>)datasource
{
    XLPhotoBrowser *browser = [[XLPhotoBrowser alloc] init];
    browser.imageCount = imageCount;
    browser.currentImageIndex = currentImageIndex;
    browser.datasource = datasource;
    [browser show];
    return browser;
}


- (void)show
{
    if (self.imageCount <= 0) {
        return;
    }
    if (self.currentImageIndex >= self.imageCount) {
        self.currentImageIndex = self.imageCount - 1;
    }
    if (self.currentImageIndex < 0) {
        self.currentImageIndex = 0;
    }
    UIWindow *window = [self findTheMainWindow];
    
    self.frame = window.bounds;
    self.alpha = 0.0;
    [window addSubview:self];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [self iniaialUI];
}

/**
 *  退出
 */
- (void)dismiss
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [UIView animateWithDuration:XLPhotoBrowserHideImageAnimationDuration animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

/**
 *  初始化底部ActionSheet弹框数据
 *
 *  @param title                  ActionSheet的title
 *  @param delegate               XLPhotoBrowserDelegate
 *  @param cancelButtonTitle      取消按钮文字
 *  @param deleteButtonTitle      删除按钮文字
 *  @param otherButtonTitles      其他按钮数组
 */
- (void)setActionSheetWithTitle:(nullable NSString *)title delegate:(nullable id<XLPhotoBrowserDelegate>)delegate cancelButtonTitle:(nullable NSString *)cancelButtonTitle deleteButtonTitle:(nullable NSString *)deleteButtonTitle otherButtonTitles:(nullable NSString *)otherButtonTitle, ...
{
    NSMutableArray *otherButtonTitlesArray = [NSMutableArray array];
    NSString *buttonTitle;
    va_list argumentList;
    if (otherButtonTitle) {
        [otherButtonTitlesArray addObject:otherButtonTitle];
        va_start(argumentList, otherButtonTitle);
        while ((buttonTitle = va_arg(argumentList, id))) {
            [otherButtonTitlesArray addObject:buttonTitle];
        }
        va_end(argumentList);
    }

    if (delegate) {
        self.delegate = delegate;
    }
}

/**
 *  保存当前展示的图片
 */
- (void)saveCurrentShowImage
{
    [self saveImage];
}

#pragma mark    -   public method  -->  XLPhotoBrowser简易使用方式:一行代码展示

/**
 一行代码展示(在某些使用场景,不需要做很复杂的操作,例如不需要长按弹出actionSheet,从而不需要实现数据源方法和代理方法,那么可以选择这个方法,直接传数据源数组进来,框架内部做处理)
 
 @param images            图片数据源数组(,内部可以是UIImage/NSURL网络图片地址/ALAsset)
 @param currentImageIndex 展示第几张
 
 @return XLPhotoBrowser实例对象
 */
+ (instancetype)showPhotoBrowserWithImages:(NSArray *)images currentImageIndex:(NSInteger)currentImageIndex
{
    if (images.count <=0 || images ==nil) {
        return nil;
    }
    
    Class imageClass = [images.firstObject class];
    for (id image in images) {
        if (![image isKindOfClass:imageClass]) {
            return nil;
        }
    }
    
    XLPhotoBrowser *browser = [[XLPhotoBrowser alloc] init];
    browser.imageCount = images.count;
    browser.currentImageIndex = currentImageIndex;
    browser.images = images;
    [browser show];
    return browser;
}

@end
