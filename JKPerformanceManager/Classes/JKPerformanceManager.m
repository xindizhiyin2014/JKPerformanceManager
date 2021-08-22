//
//  JKPerformanceManager.m
//  vova_performance_ios
//
//  Created by JackLee on 2021/8/13.
//

#import "JKPerformanceManager.h"
#import "JKLaunchPerformanceModel.h"
#import <objc/runtime.h>
#import <WebKit/WebKit.h>
#import "UIResponder+JKNextResponder.h"

CFAbsoluteTime JK_launchStartTime;
CFAbsoluteTime JK_hotLaunchStartTime;
static NSString * const kAppFirstInstallKey =  @"kAppFirstInstallKey_JKPerformanceManager";
@interface JKPerformanceManager()
@property (nonatomic, strong) NSObject<JKPerformanceHelperProtocol> *trackHelper;
@property (nonatomic, strong) NSMutableArray<NSString *> *blackList;
///特殊的控制器组成的数组
@property (nonatomic, strong) NSHashTable *firstScreenSpecifiedVCArray;
@end

@implementation JKPerformanceManager

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *controlSelectorStr = @"performance_sendAction:to:forEvent:";
        NSString *getureSelectorStr = @"performance_addTarget:action:";
        NSString *gestureSelectorStr1 = @"performance_initWithTarget:action:";
        NSString *setDelegateSelector = @"performance_setDelegate:";
        NSString *reloadDataSelector = @"performance_reloadData";
        NSString *reloadAllComponentsSelector = @"performance_reloadAllComponents";
        NSString *didMoveToWindowSelector = @"performance_didMoveToWindow";
        NSString *initSelector = @"performance_init";
        NSString *viewDidLoadSelector = @"performance_viewDidLoad";
        NSString *viewDidAppearSelector = @"performance_viewDidAppear:";
        NSString *setNavigationDelegateSelector = @"performance_setNavigationDelegate:";
        [JKPerformanceManager performance_exchangeInstanceMethod:[UIControl class] originalSel:@selector(sendAction:to:forEvent:) swizzledSel:NSSelectorFromString(controlSelectorStr)];
        [JKPerformanceManager performance_exchangeInstanceMethod:[UIGestureRecognizer class] originalSel:@selector(addTarget:action:) swizzledSel:NSSelectorFromString(getureSelectorStr)];
        [JKPerformanceManager performance_exchangeInstanceMethod:[UIGestureRecognizer class] originalSel:@selector(initWithTarget:action:) swizzledSel:NSSelectorFromString(gestureSelectorStr1)];
        [JKPerformanceManager performance_exchangeInstanceMethod:[UIPickerView class] originalSel:@selector(setDelegate:) swizzledSel:NSSelectorFromString(setDelegateSelector)];
        [JKPerformanceManager performance_exchangeInstanceMethod:[UITableView class] originalSel:@selector(setDelegate:) swizzledSel:NSSelectorFromString(setDelegateSelector)];
        [JKPerformanceManager performance_exchangeInstanceMethod:[UICollectionView class] originalSel:@selector(setDelegate:) swizzledSel:NSSelectorFromString(setDelegateSelector)];
        [JKPerformanceManager performance_exchangeInstanceMethod:[WKWebView class] originalSel:@selector(setNavigationDelegate:) swizzledSel:NSSelectorFromString(setNavigationDelegateSelector)];
        [JKPerformanceManager performance_exchangeInstanceMethod:[UITableView class] originalSel:@selector(reloadData) swizzledSel:NSSelectorFromString(reloadDataSelector)];
        [JKPerformanceManager performance_exchangeInstanceMethod:[UICollectionView class] originalSel:@selector(reloadData) swizzledSel:NSSelectorFromString(reloadDataSelector)];
        [JKPerformanceManager performance_exchangeInstanceMethod:[UIPickerView class] originalSel:@selector(reloadAllComponents) swizzledSel:NSSelectorFromString(reloadAllComponentsSelector)];
        [JKPerformanceManager performance_exchangeInstanceMethod:[UITableView class] originalSel:@selector(didMoveToWindow) swizzledSel:NSSelectorFromString(didMoveToWindowSelector)];
        [JKPerformanceManager performance_exchangeInstanceMethod:[UICollectionView class] originalSel:@selector(didMoveToWindow) swizzledSel:NSSelectorFromString(didMoveToWindowSelector)];
        
        [JKPerformanceManager performance_exchangeInstanceMethod:[UIPickerView class] originalSel:@selector(didMoveToWindow) swizzledSel:NSSelectorFromString(didMoveToWindowSelector)];
        
        [JKPerformanceManager performance_exchangeInstanceMethod:[UIViewController class] originalSel:@selector(init) swizzledSel:NSSelectorFromString(initSelector)];
        
        [JKPerformanceManager performance_exchangeInstanceMethod:[UIViewController class] originalSel:@selector(viewDidLoad) swizzledSel:NSSelectorFromString(viewDidLoadSelector)];
        
        [JKPerformanceManager performance_exchangeInstanceMethod:[UIViewController class] originalSel:@selector(viewDidAppear:) swizzledSel:NSSelectorFromString(viewDidAppearSelector)];
    });
}

+ (instancetype)sharedInstance
{
    static JKPerformanceManager *_performanceManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _performanceManager = [[self alloc] init];
    });
    return _performanceManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _firstScreenSpecifiedVCArray = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

+ (void)coldLaunchStart
{
    JK_launchStartTime = CFAbsoluteTimeGetCurrent();
}

+ (void)hotLaunchStart
{
    JK_hotLaunchStartTime = CFAbsoluteTimeGetCurrent();
}

+ (void)coldLaunchEnd
{
    if (JK_launchStartTime > 0) {
       CFAbsoluteTime JK_launchEndTime = CFAbsoluteTimeGetCurrent();
       BOOL hasInstalled = [[NSUserDefaults standardUserDefaults] boolForKey:kAppFirstInstallKey];
        JKLaunchPerformanceModel *launchPerformanceModel = [JKLaunchPerformanceModel new];
        if (!hasInstalled) {
            launchPerformanceModel.element_type = JKLaunchTypeInit;
        } else {
            launchPerformanceModel.element_type = JKLaunchTypeCold;
        }
        launchPerformanceModel.start_time = JK_launchStartTime * 1000;
        launchPerformanceModel.end_time = JK_launchEndTime * 1000;
        [JKPerformanceManager trackPerformance:launchPerformanceModel vc:nil];
        JK_launchStartTime = 0;
       [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAppFirstInstallKey];
    }
}

+ (void)hotLaunchEnd
{
    BOOL hasInstalled = [[NSUserDefaults standardUserDefaults] boolForKey:kAppFirstInstallKey];
    if (!hasInstalled) {
        return;
    }
    if (JK_hotLaunchStartTime > 0) {
        CFAbsoluteTime JK_launchEndTime = CFAbsoluteTimeGetCurrent();
        JKLaunchPerformanceModel *launchPerformanceModel = [[JKLaunchPerformanceModel alloc] init];
        launchPerformanceModel.element_type = JKLaunchTypeHot;
        launchPerformanceModel.start_time = JK_hotLaunchStartTime * 1000;
        launchPerformanceModel.end_time = CFAbsoluteTimeGetCurrent() * 1000;
        [JKPerformanceManager trackPerformance:launchPerformanceModel vc:nil];
        JK_hotLaunchStartTime = 0;
    }
}

+ (void)configTrackHelper:(NSObject<JKPerformanceHelperProtocol> *)helper
{
    [JKPerformanceManager sharedInstance].trackHelper = helper;
}

+ (void)add_firstScreen_specified_vc:(__kindof UIViewController *)specified_vc
{
    if (specified_vc) {
        [[JKPerformanceManager sharedInstance].firstScreenSpecifiedVCArray addObject:specified_vc];
    }
}

+ (BOOL)is_firstScreen_specified_vc:(__kindof UIViewController *)specified_vc
{
    return [[JKPerformanceManager sharedInstance].firstScreenSpecifiedVCArray containsObject:specified_vc];
}

+ (void)addPerfomanceBlackClasses:(NSArray<NSString *>*)blackList
{
    if (!blackList) {
        return;
    }
    if (![JKPerformanceManager sharedInstance].blackList) {
        [JKPerformanceManager sharedInstance].blackList = [NSMutableArray new];
    }
    [[JKPerformanceManager sharedInstance].blackList addObjectsFromArray:blackList];
}

+ (BOOL)isInBlackList:(NSString *)className
{
    if ([[JKPerformanceManager sharedInstance].blackList containsObject:className]) {
        return YES;
    }
    return NO;
}

/**
 实例方法替换

 @param fdClass class
 @param originalSel 源方法
 @param swizzledSel 替换方法
 */
+ (void)performance_exchangeInstanceMethod:(Class)fdClass
                   originalSel:(SEL)originalSel
                   swizzledSel:(SEL)swizzledSel
{
    Method originalMethod = class_getInstanceMethod(fdClass, originalSel);
    Method swizzledMethod = class_getInstanceMethod(fdClass, swizzledSel);
    
    // 这里用这个方法做判断，看看origin方法是否有实现，如果没实现，直接用我们自己的方法，如果有实现，则进行交换
    BOOL isAddMethod =
    class_addMethod(fdClass,
                    originalSel,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (isAddMethod) {
        class_replaceMethod(fdClass,
                            swizzledSel,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    }
    
    else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (nullable __kindof UIViewController *)topContainerViewControllerOfResponder:(nullable __kindof UIResponder *)responder
{
    if (!responder) {
        return nil;
    }
    if (![responder isKindOfClass:[UIResponder class]]) {
#if DEBUG
        NSAssert(NO, @"view is not kind of UIResponder");
#endif
        return nil;
    }
    UIResponder *nextResponder = responder.JK_nextResponder;
    while (![nextResponder isKindOfClass:[UIViewController class]]
           && nextResponder.JK_nextResponder) {
        nextResponder = nextResponder.JK_nextResponder;
    }
    if (![nextResponder isKindOfClass:[UIViewController class]]) {
//#if DEBUG
//        NSAssert(NO, @"nextResponder is nil");
//#endif
        nextResponder = nil;
    }
    return (UIViewController *)nextResponder;
}

+ (void)trackPerformance:(__kindof JKPerformanceModel *)performanceModel
                      vc:(nullable __kindof UIViewController *)vc
{
    if ([JKPerformanceManager sharedInstance].trackHelper
        && [[JKPerformanceManager sharedInstance].trackHelper respondsToSelector:@selector(trackPerformance:vc:)]) {
        [[JKPerformanceManager sharedInstance].trackHelper trackPerformance:performanceModel vc:nil];
    }
}

+(id<JKPerformanceHelperProtocol>)helper
{
    return [JKPerformanceManager sharedInstance].trackHelper;
}

@end
