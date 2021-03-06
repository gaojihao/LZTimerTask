/*
 *LZSystemTimeManager
 *
 *Copyright ©com.lizhi1026. All rights reserved.
 */

#import <Foundation/Foundation.h>

typedef void(^KVOBlock)(id target, id observer, id value, NSDictionary *change);

NS_ASSUME_NONNULL_BEGIN

@interface LZSystemTimeManager : NSObject

@property (atomic, assign) NSTimeInterval systemTime;

+ (instancetype)sharedInstance;

- (void)addObserverForSystemTime:(__weak NSObject *)observer onChanged:(KVOBlock)block;

- (void)removeObserverForSystemTime:(NSObject *)observer;

- (void)applicationWillEnterForeground;

- (void)applicationDidEnterBackground;

@end

NS_ASSUME_NONNULL_END
