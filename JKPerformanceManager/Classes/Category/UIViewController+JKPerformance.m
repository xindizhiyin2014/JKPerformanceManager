//
//  UIViewController+JKPerformance.m
//  vova_performance_ios
//
//  Created by JackLee on 2021/8/16.
//

#import "UIViewController+JKPerformance.h"
#import <objc/runtime.h>
#import "JKPerformanceManager.h"


static const void *firstScreen_pagePerformanceModelKey = &firstScreen_pagePerformanceModelKey;
static const void *interactive_pagePerformanceModelKey = &interactive_pagePerformanceModelKey;

@implementation UIViewController (JKPerformance)

- (instancetype)performance_init
{
    NSString *className = NSStringFromClass([self class]);
    //过滤掉系统类
    if ([className hasPrefix:@"UI"]) {
        return [self performance_init];
    }
    // 过滤掉黑名单
    if ([JKPerformanceManager isInBlackList:className]) {
        return [self performance_init];
    }
    JKPagePerformanceModel *firstScreen_pagePerformanceModel = [JKPagePerformanceModel new];
    firstScreen_pagePerformanceModel.element_type = JKPageTypeFirstScreen;
    firstScreen_pagePerformanceModel.start_time = [[NSDate date] timeIntervalSince1970]  * 1000;
    firstScreen_pagePerformanceModel.page = className;
    self.firstScreen_pagePerformanceModel = firstScreen_pagePerformanceModel;
    return [self performance_init];
}

- (void)performance_viewDidLoad
{
    NSString *className = NSStringFromClass([self class]);
    //过滤掉系统类
    if ([className hasPrefix:@"UI"]) {
        [self performance_viewDidLoad];
        return;
    }
    // 过滤掉黑名单
    if ([JKPerformanceManager isInBlackList:className]) {
        [self performance_viewDidLoad];
        return;
    }
    JKPagePerformanceModel *interactive_pagePerformanceModel = [[JKPagePerformanceModel alloc] init];
    interactive_pagePerformanceModel.element_type = JKPageTypeInteractive;
    interactive_pagePerformanceModel.start_time = [[NSDate date] timeIntervalSince1970]  * 1000;
    interactive_pagePerformanceModel.page = className;
    self.interactive_pagePerformanceModel = interactive_pagePerformanceModel;
   // 特殊页面
    if ([JKPerformanceManager is_firstScreen_specified_vc:self]) {
        self.firstScreen_pagePerformanceModel.start_time = [[NSDate date] timeIntervalSince1970]  * 1000;
    }
    [self performance_viewDidLoad];
}

- (void)performance_viewDidAppear:(BOOL)animated
{
    [self performance_viewDidAppear:animated];
    NSTimeInterval end_time = [[NSDate date] timeIntervalSince1970]  * 1000;
    self.interactive_pagePerformanceModel.end_time = end_time;
    if (self.interactive_pagePerformanceModel.start_time > 0) {// 避免重复打点
        [JKPerformanceManager trackPerformance:self.interactive_pagePerformanceModel vc:self];
        self.interactive_pagePerformanceModel.start_time = 0;
    }
}
#pragma mark - - setter - -
- (void)setFirstScreen_pagePerformanceModel:(JKPagePerformanceModel *)firstScreen_pagePerformanceModel
{
    objc_setAssociatedObject(self, firstScreen_pagePerformanceModelKey, firstScreen_pagePerformanceModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setInteractive_pagePerformanceModel:(JKPagePerformanceModel *)interactive_pagePerformanceModel
{
    objc_setAssociatedObject(self, interactive_pagePerformanceModelKey, interactive_pagePerformanceModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - - getter - -
- (JKPagePerformanceModel *)firstScreen_pagePerformanceModel
{
    return objc_getAssociatedObject(self, firstScreen_pagePerformanceModelKey);
}

- (JKPagePerformanceModel *)interactive_pagePerformanceModel
{
    return objc_getAssociatedObject(self, interactive_pagePerformanceModelKey);
}
@end
