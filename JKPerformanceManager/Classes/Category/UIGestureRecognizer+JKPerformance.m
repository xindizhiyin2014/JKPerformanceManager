//
//  UIGestureRecognizer+JKPerformance.m
//  vova_performance_ios
//
//  Created by JackLee on 2021/8/13.
//

#import "UIGestureRecognizer+JKPerformance.h"
#import "JKOperationPerformanceModel.h"
#import "JKPerformanceManager.h"
#import "UIView+JKPerformance.h"
#import "JKPerformanceManager.h"
#import <objc/runtime.h>
#import <Aspects/Aspects.h>
#import "UIView+JKPerformance.h"


static const void *track_gesture_target_has_hookedKey = &track_gesture_target_has_hookedKey;

@implementation UIGestureRecognizer (JKPerformance)

-(instancetype)performance_initWithTarget:(id)target action:(SEL)action
{
    __kindof UIGestureRecognizer *instance = (UIGestureRecognizer *)[self performance_initWithTarget:target action:action];
    [instance handleOfTarget:target selector:action];
    return instance;
}

- (void)performance_addTarget:(id)target action:(SEL)action
{
    [self performance_addTarget:target action:action];
    [self handleOfTarget:target selector:action];
}

- (void)handleOfTarget:(id)target selector:(SEL)selector
{
    if (![target respondsToSelector:selector]) {
        return;
    }
    NSString *selectorStr = NSStringFromSelector(selector);
    if (!selectorStr
        || [selectorStr hasPrefix:@"_"]) { //私有事件的方法不进行拦截
        return;
    }
    NSString *target_ClassName = NSStringFromClass([target class]);
    // 过滤掉系统的视图
    if (([target_ClassName hasPrefix:@"UI"]
         && ![target_ClassName isEqualToString:@"UIView"])) {
        return;
    }
    // 过滤掉系统私有类
    if ([target_ClassName hasPrefix:@"_"]) {
        return;
    }
    // 忽略掉黑名单，避免干扰
    if ([JKPerformanceManager isInBlackList:target_ClassName]) {
        return;
    }
    //过滤掉系统的手势,系统的手势通过子类去实现
    BOOL isInwhiteList = [self gestureInWhiteList];
    if (!isInwhiteList) {
        return;
    }
    // 过滤掉不响应的
    if (![target respondsToSelector:selector]) {
        return;
    }
    // 过滤掉已经hook的
    NSMutableArray *hookedArray = (NSMutableArray *)objc_getAssociatedObject(target, track_gesture_target_has_hookedKey);
    if ([hookedArray containsObject:selectorStr]) {
        return;
    }
    NSError *error1 = nil;
    [(NSObject *)target aspect_hookSelector:selector withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> data){
        if ([[JKPerformanceManager helper] respondsToSelector:@selector(track_gesture:target:selector:)]) {
            [[JKPerformanceManager helper] track_gesture:self target:target selector:selector];
        }
        
        JKOperationPerformanceModel *operatePerformanceModel = [JKOperationPerformanceModel new];
        operatePerformanceModel.start_time = [[NSDate date] timeIntervalSince1970]  * 1000;
        
        NSInvocation *invocation = [data originalInvocation];
        [invocation invoke];
        
        if ([self isKindOfClass:[UITapGestureRecognizer class]]
             || [self isKindOfClass:[UILongPressGestureRecognizer class]]) {
            operatePerformanceModel.end_time = [[NSDate date] timeIntervalSince1970]  * 1000;
            if ([self isKindOfClass:[UITapGestureRecognizer class]]) {
                operatePerformanceModel.element_type = JKOperateTypeClick;
            } else if ([self isKindOfClass:[UILongPressGestureRecognizer class]]) {
                operatePerformanceModel.element_type = JKOperateTypeLongPress;
            }
            operatePerformanceModel.widget = [NSString stringWithFormat:@"%@+%@",target_ClassName,selectorStr];
            if (!self.view.track_containerVC) {
                UIViewController *track_containerVC = [JKPerformanceManager topContainerViewControllerOfResponder:self.view];
                self.view.track_containerVC = track_containerVC;
            }
            operatePerformanceModel.page = NSStringFromClass(self.view.track_containerVC.class)?:NSStringFromClass([UIViewController class]);
            [JKPerformanceManager trackPerformance:operatePerformanceModel vc:self.self.view.track_containerVC];
        }
        
    } error:&error1];
    
    if (error1) {
#if DEBUG
        NSLog(@"UIGestureRecognizer+JKTrack error1:%@",error1);
        NSAssert(NO, @"UIGestureRecognizer+JKTrack error1");
#endif
    } else {
        NSMutableArray *array = (NSMutableArray *)objc_getAssociatedObject(target, track_gesture_target_has_hookedKey);
        if (!array) {
            array = [NSMutableArray new];
        }
        [array addObject:selectorStr];
        objc_setAssociatedObject(target, track_gesture_target_has_hookedKey, array, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (BOOL)gestureInWhiteList;
{
    NSString *self_ClassName = NSStringFromClass([self class]);
    if ([self_ClassName isEqualToString:@"UITapGestureRecognizer"]
        || [self_ClassName isEqualToString:@"UIPanGestureRecognizer"]
        || [self_ClassName isEqualToString:@"UILongPressGestureRecognizer"]
        || [self_ClassName isEqualToString:@"UIPinchGestureRecognizer"]
        || [self_ClassName isEqualToString:@"UISwipeGestureRecognizer"]
        || [self_ClassName isEqualToString:@"UIRotationGestureRecognizer"]) {
        return YES;
    }
    return NO;
}
@end
