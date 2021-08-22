//
//  UIPickerView+JKPerformance.m
//  vova_performance_ios
//
//  Created by JackLee on 2021/8/13.
//

#import "UIPickerView+JKPerformance.h"
#import <Aspects/Aspects.h>
#import <objc/runtime.h>
#import "JKOperationPerformanceModel.h"
#import "JKPerformanceManager.h"
#import "UIView+JKPerformance.h"
#import "UIViewController+JKPerformance.h"


static const void *performance_pickerView_target_has_hookedKey = &performance_pickerView_target_has_hookedKey;
static const void *performance_hasLayoutImmediatelyKey = &performance_hasLayoutImmediatelyKey;

@implementation UIPickerView (JKPerformance)

- (void)performance_setDelegate:(id)delegate
{
    [self performance_setDelegate:delegate];
    // 过滤掉异常
    if (!delegate) {
        return;
    }
    NSString *delegate_ClassName = NSStringFromClass([delegate class]);
    // 过滤掉系统子类
    if (![NSStringFromClass([self class]) isEqualToString:@"UIPickerView"]) {
        return;
    }
    
    // 过滤掉系统视图
    if ([delegate_ClassName hasPrefix:@"UI"]) {
        return;
    }
    // 忽略掉黑名单，避免干扰
    if ([JKPerformanceManager isInBlackList:delegate_ClassName]) {
        return;
    }
    // 过滤掉未实现代理方法的情况
    if (![delegate respondsToSelector:@selector(pickerView:didSelectRow:inComponent:)]) {
        return;
    }
    // 过滤掉已经hook的情况
    BOOL hasHooked = [objc_getAssociatedObject(delegate, performance_pickerView_target_has_hookedKey) boolValue];
    if (hasHooked) {
        return;
    }
    
    NSError *error1 = nil;
    [(NSObject *)delegate aspect_hookSelector:@selector(pickerView:didSelectRow:inComponent:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> data){
        JKOperationPerformanceModel *operatePerformanceModel = [JKOperationPerformanceModel new];
        operatePerformanceModel.start_time = [[NSDate date] timeIntervalSince1970]  * 1000;
        
        if ([[JKPerformanceManager helper] respondsToSelector:@selector(track_pickerView:didSelectRow:inComponent:)]) {
            NSArray *arguments = [data arguments];
            if (arguments.count == 2) {
                NSInteger row = [arguments.firstObject integerValue];
                NSInteger component = [arguments.lastObject intValue];
                [[JKPerformanceManager helper] track_pickerView:self didSelectRow:row inComponent:component];
            } else {
#if DEBUG
                NSAssert(NO, @"参数异常请排查");
#endif
            }
        }
        NSInvocation *invocation = [data originalInvocation];
        [invocation invoke];
        
        operatePerformanceModel.end_time = [[NSDate date] timeIntervalSince1970]  * 1000;
        operatePerformanceModel.element_type = JKOperateTypeItemClick;
        operatePerformanceModel.widget = [NSString stringWithFormat:@"%@+%@",delegate_ClassName,NSStringFromSelector(@selector(pickerView:didSelectRow:inComponent:))];
        if (!self.track_containerVC) {
            UIViewController *track_containerVC = [JKPerformanceManager topContainerViewControllerOfResponder:self];
            self.track_containerVC = track_containerVC;
        }
        operatePerformanceModel.page = NSStringFromClass(self.track_containerVC.class)?:NSStringFromClass([UIViewController class]);
        [JKPerformanceManager trackPerformance:operatePerformanceModel vc:self.track_containerVC];
        
    } error:&error1];
    if (error1) {
#if DEBUG
        NSLog(@"UIPickerView+JKTrack error1:%@",error1);
        NSAssert(NO, @"UIPickerView+JKTrack error1");
#endif
    } else {
        objc_setAssociatedObject(delegate, performance_pickerView_target_has_hookedKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)performance_reloadAllComponents
{
    [self performance_reloadAllComponents];
    //屏蔽掉系统子类
    if (![NSStringFromClass([self class]) isEqualToString:@"UIPickerView"]) {
        return;
    }
    // 没有父视图忽略掉
    if (!self.window) {
        if ([[JKPerformanceManager helper]  respondsToSelector:@selector(track_markPickViewNOSuperView:)]) {
            
        }
        return;
    }
    // 忽略掉黑名单
    NSString *deletate_ClassName = NSStringFromClass([self.delegate class]);
    if ([JKPerformanceManager isInBlackList:deletate_ClassName]) {
        return;
    }
    [self setNeedsLayout];
    [self layoutIfNeeded];
    if ([[JKPerformanceManager helper] respondsToSelector:@selector(track_reloadAllComponentsOfPickerView:)]) {
        [[JKPerformanceManager helper] track_reloadAllComponentsOfPickerView:self];
    }
    [self performance_firtScreenTrack];
}

- (void)performance_didMoveToWindow
{
    [self performance_didMoveToWindow];
    //视图离开页面的时候window为nil，此时过滤掉
    if (!self.window) {
        return;
    }
    id delegate = self.delegate;
    // 过滤掉异常
    if (!delegate) {
        return;
    }
    NSString *delegate_ClassName = NSStringFromClass([delegate class]);
    // 过滤掉系统子类
    if (![NSStringFromClass([self class]) isEqualToString:@"UIPickerView"]) {
        return;
    }
    
    // 过滤掉系统视图
    if ([delegate_ClassName hasPrefix:@"UI"]) {
        return;
    }
    
    // 忽略掉黑名单，避免干扰
    if ([JKPerformanceManager isInBlackList:delegate_ClassName]) {
        return;
    }
    [self setNeedsLayout];
    [self layoutIfNeeded];
    if ([[JKPerformanceManager helper] respondsToSelector:@selector(track_pickerViewDidMoveToWindow:)]) {
        [[JKPerformanceManager helper] track_pickerViewDidMoveToWindow:self];
    }
    [self performance_firtScreenTrack];
}

- (void)performance_firtScreenTrack
{
    if (self.numberOfComponents >= 1) {
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
    }
}
@end
