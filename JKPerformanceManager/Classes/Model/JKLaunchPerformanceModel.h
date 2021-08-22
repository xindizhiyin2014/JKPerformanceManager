//
//  JKLaunchPerformanceModel.h
//  vova_performance_ios
//
//  Created by JackLee on 2021/8/13.
//

#import "JKPerformanceModel.h"

static NSString * _Nonnull const JKLaunchTypeInit = @"init";
static NSString * _Nonnull const JKLaunchTypeCold = @"cold";
static NSString * _Nonnull const JKLaunchTypeHot = @"hot";


NS_ASSUME_NONNULL_BEGIN

@interface JKLaunchPerformanceModel : JKPerformanceModel
/// 元素名称，唯一标识
@property (nonatomic, copy, readonly) NSString *element_name;

/// 启动类型：分为初次启动："init", 冷启动："cold", 热启动："hot"
@property (nonatomic, copy) NSString *element_type;

// 辅助字段,会自动封装进extra内

/// 单位毫秒
@property (nonatomic, assign) NSTimeInterval start_time;
/// 单位毫秒
@property (nonatomic, assign) NSTimeInterval end_time;
@end

NS_ASSUME_NONNULL_END
