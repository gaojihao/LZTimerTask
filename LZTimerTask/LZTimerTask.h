//
//  LZTimerTask.h
//  xingyujiaoyu
//
//  Created by 栗志 on 2018/1/17.
//  Copyright © 2018年 com.lizhi1026. All rights reserved.
//

#import <Foundation/Foundation.h>

//倒计时模式
typedef enum CountDownMode : NSUInteger {
    CountDownModeFinished,//已停止
    CountDownModeForStartTime,//开始倒计时
    CountDownModeForEndTime,//结束倒计时
} CountDownMode;

/*!
 *  @brief 倒计时回调
 *
 *  @param currentTime 当前系统时间
 *  @param mode        倒计时模式
 *  @param days        剩余天
 *  @param hours       剩余小时
 *  @param minutes     剩余分钟
 *  @param seconds     剩余秒
 *  @param stop        是否需要结束倒计时
 */
typedef void(^CountDownTaskHandler)(NSTimeInterval currentTime, CountDownMode mode, long long days,long long hours,long long minutes,long long seconds,BOOL *stop);

/*!
 *  @brief 定时任务回调
 *
 *  @param repeatCount 任务已执行次数
 *  @param stop        是否需要结束任务
 */
typedef void(^TimerTaskHandler)(long long repeatCount, BOOL *stop);

NS_ASSUME_NONNULL_BEGIN

@interface LZTimerTask : NSObject

/*!
 *  @brief 创建一个任务，可用于做心跳、定时任务等，如短信验证码、启动页广告倒计时，需自己处理切刀后台停止的问题
 *
 *  @param target  执行任务的对象
 *  @param ti      执行任务的时间间隔
 *  @param repeat  是否需要循环执行
 *  @param delay   第一次执行的延迟时间
 *  @param handler 任务block
 *
 *  @return LZTimerTask
 */
- (instancetype)initTimerTaskWithTarget:(id)target
                           timeInterval:(NSTimeInterval)ti
                                repeats:(BOOL)repeat
                             afterDelay:(NSTimeInterval)delay
                                handler:(TimerTaskHandler)handler;

- (void)stopTimerTask;

/*!
 *  @brief 开启一个倒计时任务，一般用于秒杀，闪购等活动的倒计时，不需自己处理切刀后台停止的问题
 *
 *  @param target     倒计时对象
 *  @param startTime  需要倒计时的活动开始时间，没有则传0
 *  @param endTime    需要倒计时的活动结束时间，没有则传0
 *  @param serverTime 服务器当前时间，没有则传0
 *  @param handler    回调
 */
+ (void)countDownTaskWithTarget:(id)target
                      startTime:(NSTimeInterval)startTime
                        endTime:(NSTimeInterval)endTime
                     serverTime:(NSTimeInterval)serverTime
                        handler:(CountDownTaskHandler)handler;

@end

NS_ASSUME_NONNULL_END
