//
//  TGDealDetailViewController.m
//  团购HD
//
//  Created by BJT on 17/6/24.
//  Copyright © 2017年 BJT. All rights reserved.
//

#import "UIImageView+WebCache.h"
#import "DPAPI.h"
#import "MBProgressHUD+MJ.h"
#import "MJExtension.h"

#import "TGDealDetailViewController.h"
#import "TGDeal.h"
#import "TGConst.h"
#import "TGCenterLineLabel.h"
#import "TGDealRestrictions.h"

@interface TGDealDetailViewController () <UIWebViewDelegate,DPRequestDelegate>
/** 显示详情信息的 weibView */
@property (weak, nonatomic) IBOutlet UIWebView *webView;
/** webView 表示正在加载 */
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
/** 返回按钮点击 */
- (IBAction)back;
/** 订单图标 */
@property (weak, nonatomic) IBOutlet UIImageView *orderIcon;
/** 标题 */
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
/** 描述 */
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
/** 原价 */
@property (weak, nonatomic) IBOutlet UILabel *listPriceLabel;
/** 现价 */
@property (weak, nonatomic) IBOutlet UILabel *currentPriceLabel;

/** 随时退 */
@property (weak, nonatomic) IBOutlet UIButton *refundableAnyTimeBtn;
/** 过期退 */
@property (weak, nonatomic) IBOutlet UIButton *refundableExpireBtn;
/** 剩余时间 */
@property (weak, nonatomic) IBOutlet UIButton *leftTimeBtn;
/** 已售出 */
@property (weak, nonatomic) IBOutlet UIButton *soldNumberBtn;

@end

@implementation TGDealDetailViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // 设置背景色
    self.view.backgroundColor = kTGGlobalBackGroundColor;
    
    NSURL *url = [NSURL URLWithString:self.deal.deal_h5_url];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    // 加载网页时先隐藏,展示 loadingView表示正在下载
    self.webView.hidden = YES;
    
    // 设置订单详情
    [self setupDealDetail];
    
    
    // 获取订单更多详情
    DPAPI *dpApi = [[DPAPI alloc] init];
    NSMutableDictionary *paras = [NSMutableDictionary dictionary];
    paras[@"deal_id"] = self.deal.deal_id;
    [dpApi requestWithURL:@"v1/deal/get_single_deal" params:paras delegate:self];
}

/**
 *  设置订单详情
 */
-(void)setupDealDetail
{
    
    // 设置订单详情
    [self.orderIcon sd_setImageWithURL:[NSURL URLWithString:self.deal.image_url] placeholderImage:[UIImage imageNamed:@"placeholder_deal"]];
    self.titleLabel.text = self.deal.title;
    self.descLabel.text = self.deal.desc;
    
    
    NSString *priceStr = self.deal.current_price.description;
    NSString *currentPrice = [NSString stringWithFormat:@"¥ %@",priceStr];
    // 当服务器返回数据小数位数很长时,四舍五入保留2位小数
    //    priceStr = @"12.34567";
    NSInteger dotLoc = [priceStr rangeOfString:@"."].location;
    if (dotLoc != NSNotFound ) { // 有小数位
        
        if (priceStr.length - dotLoc > 3) { // 大于2位小数
            //            currentPrice = [currentPrice substringToIndex:dotLoc + 4];
            //            newPrice = (int)(100 * [currentPrice floatValue] + 0.5) / 100.0;
            currentPrice = [NSString stringWithFormat:@"¥ %.2f",[priceStr floatValue]];
        }
    }
    
    self.currentPriceLabel.text = currentPrice;
    
    self.listPriceLabel.text = [NSString stringWithFormat:@"门店价¥ %@",self.deal.list_price];
    
    NSString *soldText = [NSString stringWithFormat:@"已售出%d",self.deal.purchase_count];
    [self.soldNumberBtn setTitle:soldText forState:UIControlStateNormal];
    
    // 设置剩余时间
//        NSLog(@"purchase_deadline== %@",self.deal.purchase_deadline);
    //    // purchase_deadline== 2017-07-29
    
    NSString *leftTime;
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    NSDate *deadDate = [fmt dateFromString:self.deal.purchase_deadline];
    // 因为是次日0点过期, 需追加一天
    deadDate = [deadDate dateByAddingTimeInterval:24 * 60 * 60];
    
    // 获取当前日期与截止日期之间的间隔
    NSCalendarUnit unit = NSCalendarUnitDay | NSCalendarUnitHour| NSCalendarUnitMinute ;
    NSDateComponents *cmps = [[NSCalendar currentCalendar] components:unit fromDate:[NSDate date] toDate:deadDate options:0];
    
    if ( cmps.day < 0|| cmps.hour<0 || cmps.minute < 0) {
        leftTime = @"已过期";
    }else if (cmps.day > 365){
        leftTime = @"一年内不会过期";
    }else{
        leftTime = [NSString stringWithFormat:@"%d天%d小时%d分",cmps.day,cmps.hour,cmps.minute];
    }
    
    [self.leftTimeBtn setTitle:leftTime forState:UIControlStateNormal];
    
}


/** 设置当前控制器只支持横屏 */
-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    // 只支持横屏
    return UIInterfaceOrientationMaskLandscape;
}

#pragma mark -DPRequestDelegate  代理方法
-(void)request:(DPRequest *)request didFinishLoadingWithResult:(id)result
{
//    NSLog(@"%@",result);
    // 返回一个订单
    self.deal = [TGDeal objectWithKeyValues:[result[@"deals"] firstObject]];
    // 设置支持退款信息
    self.refundableAnyTimeBtn.selected = self.deal.restrictions.is_refundable;
    self.refundableExpireBtn.selected = self.deal.restrictions.is_refundable;
    
    
}

-(void)request:(DPRequest *)request didFailWithError:(NSError *)error
{
    // toView不写时, hud 添加到window 上, window的原点坐标不会跟着屏幕旋转,hud视图会颠倒,所以要显示在self.collectionView上,横竖屏旋转时就没问题了
    [MBProgressHUD showError:@"网络繁忙,请稍后再试..." toView:self.view];
}


#pragma mark - WebView 代理方法
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
//    NSLog(@"%@, %@",self.deal.deal_h5_url,request.URL.absoluteString);
    return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    NSMutableString *js = [NSMutableString string];
    // 移除 header 返回按钮
    [js appendString:@"var tgHeader = document.getElementsByTagName('header')[0];"];
    [js appendString:@"tgHeader.parentNode.removeChild(tgHeader);"];
    
    // 移除 headbar
    [js appendString:@"var tgheadbar = document.getElementsByClassName('headbar')[0];"];
    [js appendString:@"tgheadbar.parentNode.removeChild(tgheadbar);"];
    
    // 移除 cost-box 购买按钮
    [js appendString:@"var tgBox = document.getElementsByClassName('cost-box')[0];"];
    [js appendString:@"tgBox.parentNode.removeChild(tgBox);"];
    
    // 移除 buy-now 购买按钮
    [js appendString:@"var tgBuyNow = document.getElementsByClassName('buy-now')[0];"];
    [js appendString:@"tgBuyNow.parentNode.removeChild(tgBuyNow);"];
    
    // 移除 footer-btn-fix 底部按钮
    [js appendString:@"var tgFooterFix = document.getElementsByClassName('footer-btn-fix')[0];"];
    [js appendString:@"tgFooterFix.parentNode.removeChild(tgFooterFix);"];
    
    // 利用webView执行JS
    [webView stringByEvaluatingJavaScriptFromString:js];
    
    // 加载完成,显示 webView , 停止动画并隐藏 loadingView
    webView.hidden = NO;
    [self.loadingView stopAnimating];
    
    /* 获取详情 HTML */
//    NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('html')[0].outerHTML"];
//    NSLog(@"%@",html);
}

/** 返回 */
- (IBAction)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
@end
