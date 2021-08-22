//
//  JKPerformanceManager.h
//  vova_performance_ios
//
//  Created by JackLee on 2021/8/13.
//

#import <Foundation/Foundation.h>
#import<UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class JKPerformanceModel;
@protocol JKPerformanceHelperProtocol <NSObject>

@required

- (void)trackPerformance:(__kindof JKPerformanceModel *)performanceModel vc:(nullable __kindof UIViewController *)vc;

@optional

- (void)track_control:(UIControl *)control
           sendAction:(SEL)action
                   to:(id)target
             forEvent:(UIEvent *)event;

- (void)track_gesture:(UIGestureRecognizer *)gesture
               target:(id)target
             selector:(SEL)selector;

- (void)track_pickerView:(UIPickerView *)pickerView
            didSelectRow:(NSInteger)row
             inComponent:(NSInteger)component;

- (void)track_reloadAllComponentsOfPickerView:(UIPickerView *)pickerView;

- (void)track_markPickViewNOSuperView:(UIPickerView *)pickerView;

- (void)track_pickerViewDidMoveToWindow:(UIPickerView *)pickerView;

- (void)track_tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)track_reloadDataOfTableView:(UITableView *)tableView;

- (void)track_markTableViewNOSuperView:(UITableView *)tableView;

- (void)track_tableViewDidMoveToWindow:(UITableView *)tableView;

- (void)track_collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)track_reloadDataOfUICollectionView:(UICollectionView *)collectionView;

- (void)track_markCollectionViewNOSuperView:(UICollectionView *)collectionView;

- (void)track_collectionViewDidMoveToWindow:(UICollectionView *)collectionView;

@end

@interface JKPerformanceManager : NSObject

/// init,cold 启动main函数之前调用这个方法
+ (void)coldLaunchStart;
/// hot 启动开始的时候调用这个方法
+ (void)hotLaunchStart;
/// 冷启动结束的时候调用这个方法
+ (void)coldLaunchEnd;
/// 热启动结束的时候调用这个方法
+ (void)hotLaunchEnd;


+ (void)configTrackHelper:(NSObject<JKPerformanceHelperProtocol> *)helper;
/// 添加特殊的vc，这些vc的首屏采集不是从init开始的
+ (void)add_firstScreen_specified_vc:(__kindof UIViewController *)specified_vc;
/// 是否是特殊的vc，这些vc的首屏采集不是从init开始的
+ (BOOL)is_firstScreen_specified_vc:(__kindof UIViewController *)specified_vc;
/// 配置忽略性能采集的类名的数组
+ (void)addPerfomanceBlackClasses:(NSArray<NSString *>*)blackList;
/// 是否在黑名单中
+ (BOOL)isInBlackList:(NSString *)className;

+ (nullable __kindof UIViewController *)topContainerViewControllerOfResponder:(nullable __kindof UIResponder *)responder;

+ (void)trackPerformance:(__kindof JKPerformanceModel *)performanceModel vc:(nullable __kindof UIViewController *)vc;

+(id<JKPerformanceHelperProtocol>)helper;

@end

NS_ASSUME_NONNULL_END
