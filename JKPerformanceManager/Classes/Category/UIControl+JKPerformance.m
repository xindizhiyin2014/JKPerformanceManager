//
//  UIControl+JKPerformance.m
//  vova_performance_ios
//
//  Created by JackLee on 2021/8/13.
//

#import "UIControl+JKPerformance.h"
#import "JKOperationPerformanceModel.h"
#import "JKPerformanceManager.h"
#import "UIView+JKPerformance.h"
#import "JKPerformanceManager.h"


@implementation UIControl (JKPerformance)

- (void)performance_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    JKOperationPerformanceModel *operatePerformanceModel = [JKOperationPerformanceModel new];
    operatePerformanceModel.start_time = [[NSDate date] timeIntervalSince1970]  * 1000;
    if ([[JKPerformanceManager helper] respondsToSelector:@selector(track_control:sendAction:to:forEvent:)]) {
        [[JKPerformanceManager helper] track_control:self sendAction:action to:target forEvent:event];
    }
    // 正常执行事件
    [self performance_sendAction:action to:target forEvent:event];
    // 忽略掉黑名单，避免干扰
    NSString *target_ClassName = NSStringFromClass([target class]);
    // 过滤掉系统私有类
    if ([target_ClassName hasPrefix:@"_"]) {
        return;
    }
    if ([JKPerformanceManager isInBlackList:target_ClassName]) {
        return;
    }
    
    // 性能采集打点
    operatePerformanceModel.end_time = [[NSDate date] timeIntervalSince1970]  * 1000;
    operatePerformanceModel.element_type = JKOperateTypeClick;
    operatePerformanceModel.widget = [NSString stringWithFormat:@"%@+%@",target_ClassName,NSStringFromSelector(action)];
    if (!self.track_containerVC) {
        UIViewController *track_containerVC = [JKPerformanceManager topContainerViewControllerOfResponder:self];
        self.track_containerVC = track_containerVC;
    }
    operatePerformanceModel.page = NSStringFromClass(self.track_containerVC.class)?:NSStringFromClass([UIViewController class]);
    [JKPerformanceManager trackPerformance:operatePerformanceModel vc:self.track_containerVC];
    
}
@end
