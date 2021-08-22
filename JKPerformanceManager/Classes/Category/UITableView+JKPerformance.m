//
//  UITableView+JKPerformance.m
//  vova_performance_ios
//
//  Created by JackLee on 2021/8/13.
//

#import "UITableView+JKPerformance.h"
#import <Aspects/Aspects.h>
#import <objc/runtime.h>
#import "JKOperationPerformanceModel.h"
#import "JKPerformanceManager.h"
#import "UIView+JKPerformance.h"
#import "UIViewController+JKPerformance.h"

static const void *performance_tableView_target_has_hookedKey = &performance_tableView_target_has_hookedKey;

@implementation UITableView (JKPerformance)

- (void)performance_setDelegate:(id)delegate
{
    [self performance_setDelegate:delegate];
    //过滤掉异常
    if (!delegate) {
        return;
    }
    NSString *delegate_ClassName = NSStringFromClass([delegate class]);
    // 过滤掉系统子类
    if (![NSStringFromClass([self class]) isEqualToString:@"UITableView"]) {
        return;
    }
    // 过滤掉系统视图
    if ([delegate_ClassName hasPrefix:@"UI"]) {
        return;
    }
    // 忽略掉黑名单
    if ([JKPerformanceManager isInBlackList:delegate_ClassName]) {
        return;
    }
    // 过滤掉未实现代理方法的情况
    if (![delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        return;
    }
    // 过滤掉已经hook的情况
    BOOL hasHooked = [objc_getAssociatedObject(delegate, performance_tableView_target_has_hookedKey) boolValue];
    if (hasHooked) {
        return;
    }
    NSError *error1 = nil;
    [(NSObject *)delegate aspect_hookSelector:@selector(tableView:didSelectRowAtIndexPath:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> data){
        JKOperationPerformanceModel *operatePerformanceModel = [JKOperationPerformanceModel new];
        operatePerformanceModel.start_time = [[NSDate date] timeIntervalSince1970]  * 1000;
        if ([[JKPerformanceManager helper] respondsToSelector:@selector(track_tableView:didSelectRowAtIndexPath:)]) {
            NSArray *arguments = [data arguments];
            if (arguments.count == 2) {
                UITableView *tableView = (UITableView *)arguments.firstObject;
                NSIndexPath *indexPath = (NSIndexPath *)arguments.lastObject;
                [[JKPerformanceManager helper] track_tableView:tableView didSelectRowAtIndexPath:indexPath];
            } else {
                NSAssert(NO, @"参数错误请排查");
            }
        }
        NSInvocation *invocation = [data originalInvocation];
        [invocation invoke];
        
        operatePerformanceModel.end_time = [[NSDate date] timeIntervalSince1970]  * 1000;
        operatePerformanceModel.element_type = JKOperateTypeItemClick;
        operatePerformanceModel.widget = [NSString stringWithFormat:@"%@+%@",delegate_ClassName,NSStringFromSelector(@selector(tableView:didSelectRowAtIndexPath:))];
        if (!self.track_containerVC) {
            UIViewController *track_containerVC = [JKPerformanceManager topContainerViewControllerOfResponder:self];
            self.track_containerVC = track_containerVC;
        }
        operatePerformanceModel.page = NSStringFromClass(self.track_containerVC.class)?:NSStringFromClass([UIViewController class]);
        [JKPerformanceManager trackPerformance:operatePerformanceModel vc:self.track_containerVC];
    } error:&error1];
    
    if (error1) {
#if DEBUG
        NSLog(@"UITableView+JKTrack error1:%@",error1);
        NSAssert(NO, @"UITableView+JKTrack error1");
#endif
    } else {
        objc_setAssociatedObject(delegate, performance_tableView_target_has_hookedKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)performance_reloadData
{
    [self performance_reloadData];
    //屏蔽掉系统子类
    if (![NSStringFromClass([self class]) isEqualToString:@"UITableView"]) {
        return;
    }
    NSString *delegate_ClassName = NSStringFromClass([self.delegate class]);
    // 过滤掉系统视图
    if ([delegate_ClassName hasPrefix:@"UI"]) {
        return;
    }
    // 忽略掉黑名单
    if ([JKPerformanceManager isInBlackList:delegate_ClassName]) {
        return;
    }
    if (!self.window) {
        if ([[JKPerformanceManager helper] respondsToSelector:@selector(track_markTableViewNOSuperView:)]) {
            [[JKPerformanceManager helper] track_markTableViewNOSuperView:self];
        }
        return;
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    if ([[JKPerformanceManager helper] respondsToSelector:@selector(track_reloadDataOfTableView:)]) {
        [[JKPerformanceManager helper] track_reloadDataOfTableView:self];
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
    //过滤掉异常
    if (!delegate) {
        return;
    }
    NSString *delegate_ClassName = NSStringFromClass([delegate class]);
    // 过滤掉系统子类
    if (![NSStringFromClass([self class]) isEqualToString:@"UITableView"]) {
        return;
    }
    // 过滤掉系统视图
    if ([delegate_ClassName hasPrefix:@"UI"]) {
        return;
    }
    // 忽略掉黑名单
    if ([JKPerformanceManager isInBlackList:delegate_ClassName]) {
        return;
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    if ([[JKPerformanceManager helper] respondsToSelector:@selector(track_tableViewDidMoveToWindow:)]) {
        [[JKPerformanceManager helper] track_tableViewDidMoveToWindow:self];
    }
    [self performance_firtScreenTrack];
}

- (void)performance_firtScreenTrack
{
    if (self.visibleCells.count >= 1) {
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
