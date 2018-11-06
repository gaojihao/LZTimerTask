//
//  LZSystemTimeManager.m
//  xingyujiaoyu
//
//  Created by 栗志 on 2018/1/17.
//  Copyright © 2018年 com.lizhi1026. All rights reserved.
//

#import "LZSystemTimeManager.h"
#import "LZTimerTask.h"

@interface KVOModel : NSObject

@property (nonatomic, weak) NSObject *observer;
@property (nonatomic, copy) KVOBlock callback;

@end

@implementation KVOModel

@end

@interface LZSystemTimeManager ()

@property (nonatomic, strong) NSMutableArray *observerArray;
@property (nonatomic, strong) LZTimerTask *timerTask;
@property (nonatomic, assign) NSTimeInterval enterBackgroundTime;

@end

@implementation LZSystemTimeManager

@synthesize systemTime = _systemTime;

+ (instancetype)sharedInstance {
    static LZSystemTimeManager *_manager;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _manager = [[LZSystemTimeManager alloc] init];
    });
    
    return _manager;
}

- (void)dealloc{
    [self stopTimer];
}

- (void)startTimer {
    
    __weak typeof(self) w_self = self;
    
    self.timerTask = [[LZTimerTask alloc] initTimerTaskWithTarget:self timeInterval:1.0 repeats:YES afterDelay:0 handler:^(long long repeatCount, BOOL *stop) {
        __strong typeof(w_self) self = w_self;
        self.systemTime += 1;
        [self excuteCallbackWithValue:@(self.systemTime) dictionary:@{NSKeyValueChangeNewKey:@(self.systemTime),NSKeyValueChangeOldKey:@(self.systemTime-1)}];
    }];
}

- (void)stopTimer{
    
    if (self.timerTask) {
        _systemTime = 0;
        [self.timerTask stopTimerTask];
        self.timerTask = nil;
    }
}

- (void)excuteCallbackWithValue:(id)value dictionary:(NSDictionary *)info{
    __weak typeof(self) w_self = self;
    void (^callback)() = ^{
        __strong typeof(w_self) self = w_self;
        [self.observerArray enumerateObjectsUsingBlock:^(KVOModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            // 观察者已经被释放则移除
            if (obj.observer == nil) {
                [self.observerArray removeObject:obj];
            }else{
                // 执行回调
                if (obj.callback) {
                    obj.callback(self, obj.observer, value, info ? info : [NSDictionary new]);
                }
            }
        }];
    };
    
    if (![[NSThread currentThread] isMainThread]) {
        dispatch_sync(dispatch_get_main_queue(), callback);
    } else {
        callback();
    }
}

- (void)addObserverForSystemTime:(__weak NSObject *)observer onChanged:(KVOBlock)block {
    if (observer && block) {
        __block BOOL isContains = NO;
        [self.observerArray enumerateObjectsUsingBlock:^(KVOModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.observer == observer) {
                isContains = YES;
                *stop = YES;
            }
        }];
        if (!isContains) {
            KVOModel *model = [[KVOModel alloc] init];
            model.observer = observer;
            model.callback = block;
            [self.observerArray addObject:model];
        }
        // 启动timer
        if (self.timerTask == nil) {
            [self startTimer];
        }
    }
}

- (void)removeObserverForSystemTime:(NSObject *)observer{
    
    [self.observerArray enumerateObjectsUsingBlock:^(KVOModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.observer == nil || obj.observer == observer || obj.callback == nil) {
            [self.observerArray removeObject:obj];
        }
    }];
}

- (void)applicationWillEnterForeground {
    
    NSTimeInterval currentTime = [[NSDate new] timeIntervalSince1970];
    
    if (self.enterBackgroundTime > 0 && self.systemTime > 0 && currentTime > self.enterBackgroundTime) {
        self.systemTime += (currentTime-self.enterBackgroundTime);
    }
    self.enterBackgroundTime = 0;
}

- (void)applicationDidEnterBackground {
    
    self.enterBackgroundTime = [[NSDate new] timeIntervalSince1970];
}

- (NSMutableArray *)observerArray{
    if (_observerArray == nil) {
        _observerArray = [NSMutableArray array];
    }
    return _observerArray;
}

- (NSTimeInterval)systemTime {
    if (_systemTime <= 0) {
        return [[NSDate new] timeIntervalSince1970];
    } else {
        return _systemTime;
    }
}

- (void)setSystemTime:(NSTimeInterval)systemTime {
    if (systemTime < 0) {
        return;
    }
    if (systemTime <= _systemTime) {
        return;
    }
    // 加入一个时间校准策略，如果跟本地时间差别5秒以内则取本地时间，否则用服务器时间
    NSTimeInterval localTime = [[NSDate new] timeIntervalSince1970];
    NSTimeInterval diffValue = localTime - systemTime;
    if (diffValue > 0 && diffValue < 5) {
        _systemTime = localTime;
    }else{
        _systemTime = systemTime;
    }
}

@end
