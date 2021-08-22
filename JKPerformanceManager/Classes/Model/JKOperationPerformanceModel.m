//
//  JKOperationPerformanceModel.m
//  vova_performance_ios
//
//  Created by JackLee on 2021/8/13.
//

#import "JKOperationPerformanceModel.h"

@interface JKOperationPerformanceModel()
/// 耗时，单位毫秒
@property (nonatomic, assign) long long during;
@property (nonatomic, copy, readwrite) NSString *element_name;


@end

@implementation JKOperationPerformanceModel
@synthesize element_type = _element_type;
@synthesize extra = _extra;
@synthesize widget = _widget;
@synthesize page = _page;

+ (BOOL)propertyIsIgnored:(NSString *)propertyName
{
    if ([propertyName isEqualToString:@"during"]
        || [propertyName isEqualToString:@"widget"]
        || [propertyName isEqualToString:@"page"]
        || [propertyName isEqualToString:@"start_time"]
        || [propertyName isEqualToString:@"end_time"]) {
        return YES;
    }
    return NO;
}

#pragma mark - - setter - -
- (void)setElement_type:(NSString *)element_type
{
    if ([element_type isEqualToString:@"click"]
        || [element_type isEqualToString:@"itemClick"]
        || [element_type isEqualToString:@"LongPress"]) {
        
    } else {
#if DEBUG
        NSAssert(NO, @"please check element_type!");
#endif
    }
    _element_type = element_type;
}

- (void)setExtra:(NSMutableDictionary *)extra
{
    _extra = extra;
    self.extra[@"during"] = @(self.during);
    self.extra[@"widget"] = self.widget;
    self.extra[@"page"] = self.page;
}

- (void)setDuring:(long long)during
{
    _during = during;
    self.extra[@"during"] = @(self.during);
}

- (void)setWidget:(NSString *)widget
{
#if DEBUG
    if (!widget) {
        NSAssert(NO, @"widget can't be nil");
    }
#endif
    _widget = widget;
    self.extra[@"widget"] = self.widget;
}

- (void)setPage:(NSString *)page
{
#if DEBUG
    if (!page) {
        NSAssert(NO, @"page can't be nil");
    }
#endif
    _page = page;
    self.extra[@"page"] = self.page;

}

- (void)setEnd_time:(NSTimeInterval)end_time
{
    _end_time = end_time;
    long long during = end_time - self.start_time;
    self.during = during;
}

#pragma mark - - getter - -
- (NSString *)element_name
{
    if (!_element_name) {
        _element_name = @"operate";
    }
    return _element_name;
}

- (NSString *)element_type
{
    if (!_element_type) {
        _element_type = @"";
    }
    return _element_type;
}

- (NSMutableDictionary *)extra
{
    if (!_extra) {
        _extra = [NSMutableDictionary new];
    }
    return _extra;
}

- (NSString *)widget
{
    if (!_widget) {
        _widget = @"";
    }
    return _widget;
}

- (NSString *)page
{
    if (!_page) {
        _page = @"";
    }
    return _page;
}

@end
