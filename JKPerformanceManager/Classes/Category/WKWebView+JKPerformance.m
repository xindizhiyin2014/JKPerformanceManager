//
//  WKWebView+JKPerformance.m
//  vova_performance_ios
//
//  Created by JackLee on 2021/8/17.
//

#import "WKWebView+JKPerformance.h"
#import <Aspects/Aspects.h>
#import <objc/runtime.h>
#import "JKOperationPerformanceModel.h"
#import "JKPerformanceManager.h"
#import "UIView+JKPerformance.h"
#import "UIViewController+JKPerformance.h"

static const void *performance_webView_target_has_hookedKey = &performance_webView_target_has_hookedKey;

@implementation WKWebView (JKPerformance)
- (void)performance_setNavigationDelegate:(id<WKNavigationDelegate>)navigationDelegate
{
    [self performance_setNavigationDelegate:navigationDelegate];
    // 过滤掉系统子类
    if (![NSStringFromClass([self class]) isEqualToString:@"WKWebView"]) {
        return;
    }
    NSString *delegate_ClassName = NSStringFromClass([navigationDelegate class]);
    // 过滤掉系统视图
    if ([delegate_ClassName hasPrefix:@"UI"]) {
        return;
    }
    // 过滤掉黑名单
    if ([JKPerformanceManager isInBlackList:delegate_ClassName]) {
        return;
    }
    // 过滤掉不响应代理方法
    if (![navigationDelegate respondsToSelector:@selector(webView:didFinishNavigation:)]) {
        return;
    }
    // 过滤掉已经hook的
    BOOL hasHooked = [objc_getAssociatedObject(navigationDelegate, performance_webView_target_has_hookedKey) boolValue];
    if (hasHooked) {
        return;
    }
    NSError *error = nil;
    [(NSObject *)navigationDelegate aspect_hookSelector:@selector(webView:didFinishNavigation:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> data){
        if (!self.track_containerVC) {
            UIViewController *track_containerVC = [JKPerformanceManager topContainerViewControllerOfResponder:self];
            self.track_containerVC = track_containerVC;
        }
        // 避免重复打点
        if (self.track_containerVC.firstScreen_pagePerformanceModel.start_time > 0) {
            NSTimeInterval end_time = [[NSDate date] timeIntervalSince1970]  * 1000;
            self.track_containerVC.firstScreen_pagePerformanceModel.end_time = end_time;
            [JKPerformanceManager trackPerformance:self.track_containerVC.firstScreen_pagePerformanceModel vc:self.track_containerVC];
            self.track_containerVC.firstScreen_pagePerformanceModel.start_time = 0;
        }

    } error:&error];
    
    if (error) {
#if DEBUG
        NSLog(@"WKWebView+JKTrack error:%@",error);
        NSAssert(NO, @"WKWebView+JKTrack error");
#endif
    } else {
        objc_setAssociatedObject(navigationDelegate, performance_webView_target_has_hookedKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}
@end
