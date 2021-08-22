//
//  JKOperationPerformanceModel.h
//  vova_performance_ios
//
//  Created by JackLee on 2021/8/13.
//

#import "JKPerformanceModel.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * _Nonnull const JKOperateTypeClick = @"click";
static NSString * _Nonnull const JKOperateTypeItemClick = @"itemClick";
static NSString * _Nonnull const JKOperateTypeLongPress = @"LongPress";

@interface JKOperationPerformanceModel : JKPerformanceModel

/// 元素名称，唯一标识
@property (nonatomic, copy, readonly) NSString *element_name;

/// 分为： 点击"click", 点击item: "itemClick", 长按"LongPress"
@property (nonatomic, copy) NSString *element_type;


// 辅助字段,会自动封装进extra内

/// iOS：类名+方法名
@property (nonatomic, copy) NSString *widget;
/// iOS 为：VC的名称
@property (nonatomic, copy) NSString *page;

/// 单位毫秒
@property (nonatomic, assign) NSTimeInterval start_time;
/// 单位毫秒
@property (nonatomic, assign) NSTimeInterval end_time;

@end

NS_ASSUME_NONNULL_END
