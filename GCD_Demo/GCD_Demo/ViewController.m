//
//  ViewController.m
//  GCD_Demo
//
//  Created by YangWei on 2021/3/14.
//  Copyright © 2021 YangWei. All rights reserved.
//

#import "ViewController.h"

dispatch_semaphore_t semaphoreLock;

@interface ViewController ()

@property (nonatomic, assign) int ticketSurplusCount;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self createQueue];
//    [self getSystemQueue];
//    [self createTask];
    
    // 主线程 同步任务 在主队列 造成死锁
//    [self mainThreadDoSyncTaskOnMainQueue];
    
    // 异步执行 + 串行队列，嵌套 同步执行在同一个串行队列 造成死锁
//    [self mainThreadDoAsyncTaskThenDoSyncTaskOnSameSerialQueue];
    
    // 同步执行 + 并发队列
//    [self syncConcurrent];
    
    // 异步执行 + 并发队列
//    [self asyncConcurrent];
    
    // 同步执行 + 串行队列
//    [self syncSerial];
    
    // 异步执行 + 串行队列
//    [self asyncSerial];
    
    // 同步执行 + 主队列
//    [self syncMain]; // 主线程执行 死锁
    // 使用 NSThread 的 detachNewThreadSelector 方法会创建线程，并自动启动线程执行 selector 任务
//    [NSThread detachNewThreadSelector:@selector(syncMain) toTarget:self withObject:nil];
    
    // 异步执行 + 主队列
//    [self asyncMain];
    
    // 线程间通信
//    [self communication];
    
    // 栅栏方法 dispatch_barrier_async
//    [self barrier];
    
    // 延时执行方法 dispatch_after
//    [self after];
    
    // 一次性代码（只执行一次）dispatch_once
//    [NSThread detachNewThreadSelector:@selector(once) toTarget:self withObject:nil];
//    [self once];
    
    // 快速迭代方法 dispatch_apply
//    [self apply];
    
    // 队列组 dispatch_group_notify
//    [self groupNotify];
    
    // 队列组 dispatch_group_wait
//    [self groupWait];
    
    // 队列组 dispatch_group_enter、dispatch_group_leave
//    [self groupEnterAndLeave];
    
    // semaphore 线程同步
//    [self semaphoreSync];
    
    // 不使用 semaphore 非线程安全场景
//    [self initTicketStatusNotSave];
    // 使用 semaphore 保证线程安全
//    [self initTicketStatusSave];
}

#pragma mark - 创建队列

- (void)createQueue
{
    // 串行队列的创建方法
    dispatch_queue_t aSerialQueue = dispatch_queue_create("demo.test.serialQueue", DISPATCH_QUEUE_SERIAL);
    
    // 并发队列的创建方法
    dispatch_queue_t aConcurrentQueue = dispatch_queue_create("demo.test.concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    
    NSLog(@"创建一个串行队列：\n%@", aSerialQueue);
    NSLog(@"创建一个并行队列：\n%@", aConcurrentQueue);
}

#pragma mark - 获取系统默认队列

- (void)getSystemQueue
{
    // 主队列的获取方法
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    // 全局并发队列的获取方法
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    NSLog(@"主队列：\n%@", mainQueue);
    NSLog(@"全局并发队列：\n%@", concurrentQueue);
}

#pragma mark - 创建任务

- (void)createTask
{
    dispatch_queue_t queue = dispatch_queue_create("demo.test.serialQueue", DISPATCH_QUEUE_SERIAL);
    
    // 同步执行任务创建方法
    dispatch_sync(queue, ^{
        // 这里放同步执行任务代码
    });
    
    dispatch_async(queue, ^{
        // 这里放异步执行任务代码
    });
}

#pragma mark - 死锁现象例

- (void)mainThreadDoSyncTaskOnMainQueue
{
    NSLog(@"-- start");
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"主线程 + 同步 + 主队列");
    });
    
    NSLog(@"-- end");
}

- (void)mainThreadDoAsyncTaskThenDoSyncTaskOnSameSerialQueue
{
    dispatch_queue_t queue = dispatch_queue_create("test.queue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(queue, ^{ // 异步执行 + 串行队列
        dispatch_sync(queue, ^{ // 同步执行 + 当前串行队列
            // 追加任务 1
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        });
    });
}

#pragma mark - 同步执行 + 并发队列

/**
 * 同步执行 + 并发队列
 * 特点：在当前线程中执行任务，不会开启新线程，执行完一个任务，再执行下一个任务。
 */
- (void)syncConcurrent
{
    NSLog(@"currentThread---%@", [NSThread currentThread]);  // 打印当前线程
    NSLog(@"syncConcurrent---begin");
    
    dispatch_queue_t queue = dispatch_queue_create("test.queue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_sync(queue, ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"1---%@", [NSThread currentThread]);      // 打印当前线程
    });
    
    dispatch_sync(queue, ^{
        // 追加任务 2
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"2---%@", [NSThread currentThread]);      // 打印当前线程
    });
    
    dispatch_sync(queue, ^{
        // 追加任务 3
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"3---%@", [NSThread currentThread]);      // 打印当前线程
    });
    
    NSLog(@"syncConcurrent---end");
}

#pragma mark - 异步执行 + 并发队列

/**
 * 异步执行 + 并发队列
 * 特点：可以开启多个线程，任务交替（同时）执行。
 */
- (void)asyncConcurrent
{
    NSLog(@"currentThread---%@", [NSThread currentThread]);  // 打印当前线程
    NSLog(@"asyncConcurrent---begin");
    
    dispatch_queue_t queue = dispatch_queue_create("test.queue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    dispatch_async(queue, ^{
        // 追加任务 2
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    dispatch_async(queue, ^{
        // 追加任务 3
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    NSLog(@"asyncConcurrent---end");
}

#pragma mark - 同步执行 + 串行队列

/**
 * 同步执行 + 串行队列
 * 特点：不会开启新线程，在当前线程执行任务。任务是串行的，执行完一个任务，再执行下一个任务。
 */
- (void)syncSerial {
    NSLog(@"currentThread---%@", [NSThread currentThread]);  // 打印当前线程
    NSLog(@"syncSerial---begin");
    
    dispatch_queue_t queue = dispatch_queue_create("test.queue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_sync(queue, ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"1---%@", [NSThread currentThread]);      // 打印当前线程
    });
    dispatch_sync(queue, ^{
        // 追加任务 2
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"2---%@", [NSThread currentThread]);      // 打印当前线程
    });
    dispatch_sync(queue, ^{
        // 追加任务 3
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"3---%@", [NSThread currentThread]);      // 打印当前线程
    });
    
    NSLog(@"syncSerial---end");
}

#pragma mark - 异步执行 + 串行队列

/**
 * 异步执行 + 串行队列
 * 特点：会开启新线程，但是因为任务是串行的，执行完一个任务，再执行下一个任务。
 */
- (void)asyncSerial
{
    NSLog(@"currentThread---%@", [NSThread currentThread]);  // 打印当前线程
    NSLog(@"asyncSerial---begin");
    
    dispatch_queue_t queue = dispatch_queue_create("test.queue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(queue, ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"1---%@", [NSThread currentThread]);      // 打印当前线程
    });
    dispatch_async(queue, ^{
        // 追加任务 2
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"2---%@", [NSThread currentThread]);      // 打印当前线程
    });
    dispatch_async(queue, ^{
        // 追加任务 3
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"3---%@", [NSThread currentThread]);      // 打印当前线程
    });
    
    NSLog(@"asyncSerial---end");
}

#pragma mark - 同步执行 + 主队列

/**
 * 同步执行 + 主队列
 * 特点(主线程调用)：互等卡主不执行。
 * 特点(其他线程调用)：不会开启新线程，执行完一个任务，再执行下一个任务。
 */
- (void)syncMain {
    
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"syncMain---begin");
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    dispatch_sync(queue, ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    dispatch_sync(queue, ^{
        // 追加任务 2
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    dispatch_sync(queue, ^{
        // 追加任务 3
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"syncMain---end");
}

#pragma mark - 异步执行 + 主队列

/**
 * 异步执行 + 主队列
 * 特点：只在主线程中执行任务，执行完一个任务，再执行下一个任务
 */
- (void)asyncMain
{
    NSLog(@"currentThread---%@", [NSThread currentThread]);  // 打印当前线程
    NSLog(@"asyncMain---begin");
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    dispatch_async(queue, ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"1---%@", [NSThread currentThread]);      // 打印当前线程
    });
    
    dispatch_async(queue, ^{
        // 追加任务 2
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"2---%@", [NSThread currentThread]);      // 打印当前线程
    });
    
    dispatch_async(queue, ^{
        // 追加任务 3
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"3---%@", [NSThread currentThread]);      // 打印当前线程
    });
    
    NSLog(@"currentThread---%@", [NSThread currentThread]);  // 打印当前线程
    NSLog(@"asyncMain---end");
}

#pragma mark - 线程间通信

/**
 * 线程间通信
 */
- (void)communication
{
    // 获取全局并发队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 获取主队列
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    NSLog(@"1---%@", [NSThread currentThread]);      // 打印当前线程
    
    dispatch_async(queue, ^{
        // 异步追加任务 1
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"2---%@", [NSThread currentThread]);      // 打印当前线程
        
        // 回到主线程
        dispatch_async(mainQueue, ^{
            // 追加在主线程中执行的任务
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"3---%@", [NSThread currentThread]);      // 打印当前线程
        });
        
        NSLog(@"4---%@", [NSThread currentThread]);      // 打印当前线程
    });
    
    NSLog(@"5---%@", [NSThread currentThread]);      // 打印当前线程
}

#pragma mark - 栅栏方法 dispatch_barrier_async

/**
 * 栅栏方法 dispatch_barrier_async
 */
- (void)barrier
{
    dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
    });
    dispatch_async(queue, ^{
        // 追加任务 2
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    dispatch_barrier_async(queue, ^{
        // 追加任务 barrier
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"barrier---%@",[NSThread currentThread]);// 打印当前线程
    });
    
    dispatch_async(queue, ^{
        // 追加任务 3
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
    });
    dispatch_async(queue, ^{
        // 追加任务 4
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"4---%@",[NSThread currentThread]);      // 打印当前线程
    });
}

#pragma mark - 延时执行方法 dispatch_after

/**
 * 延时执行方法 dispatch_after
 */
- (void)after {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"asyncMain---begin");
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 2.0 秒后异步追加任务代码到主队列，并开始执行
        NSLog(@"after---%@",[NSThread currentThread]);  // 打印当前线程
    });
    
    NSLog(@"asyncMain---end");
}

#pragma mark - 一次性代码（只执行一次）dispatch_once

/**
 * 一次性代码（只执行一次）dispatch_once
 */
- (void)once {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 只执行 1 次的代码（这里面默认是线程安全的）
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
    });
}

#pragma mark - 快速迭代方法 dispatch_apply

/**
 * 快速迭代方法 dispatch_apply
 */
- (void)apply {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSLog(@"apply---begin ---%@", [NSThread currentThread]);
    
    dispatch_apply(6, queue, ^(size_t index) {
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"%zd---%@",index, [NSThread currentThread]);
    });
    
    NSLog(@"apply---end ---%@", [NSThread currentThread]);
}

#pragma mark - 队列组

#pragma mark 队列组 dispatch_group_notify

/**
 * 队列组 dispatch_group_notify
 */
- (void)groupNotify {
    NSLog(@"begin------%@",[NSThread currentThread]);  // 打印当前线程
    
    dispatch_group_t group =  dispatch_group_create();
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 追加任务 2
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // 等前面的异步任务 1、任务 2 都执行完毕后，回到主线程执行下边任务
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    NSLog(@"end---%@",[NSThread currentThread]);  // 打印当前线程
}

#pragma mark 队列组 dispatch_group_wait

/**
 * 队列组 dispatch_group_wait
 */
- (void)groupWait {
    NSLog(@"begin---%@",[NSThread currentThread]);  // 打印当前线程
    
    dispatch_group_t group =  dispatch_group_create();
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 追加任务 2
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    // 等待上面的任务全部完成后，会往下继续执行（会阻塞当前线程）
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    NSLog(@"end---%@",[NSThread currentThread]);  // 打印当前线程
}

#pragma mark 队列组 dispatch_group_enter、dispatch_group_leave

/**
 * 队列组 dispatch_group_enter、dispatch_group_leave
 */
- (void)groupEnterAndLeave {
    NSLog(@"begin---%@",[NSThread currentThread]);  // 打印当前线程
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程

        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        // 追加任务 2
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
        
        dispatch_group_leave(group);
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // 等前面的异步操作都执行完毕后，回到主线程.
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    NSLog(@"end---%@",[NSThread currentThread]);  // 打印当前线程
}

#pragma mark - GCD 信号量：dispatch_semaphore

#pragma mark semaphore 线程同步

/**
 * semaphore 线程同步
 */
- (void)semaphoreSync {
    
    NSLog(@"semaphore---begin---%@",[NSThread currentThread]);  // 打印当前线程
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __block int number = 0;
    dispatch_async(queue, ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        
        number = 100;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"semaphore---end, number = %d",number);
}

#pragma mark 线程安全

/**
 * 非线程安全：不使用 semaphore
 * 初始化火车票数量、卖票窗口（非线程安全）、并开始卖票
 */
- (void)initTicketStatusNotSave
{
    NSLog(@"semaphore---begin---%@", [NSThread currentThread]);  // 打印当前线程
    
    self.ticketSurplusCount = 50;
    
    // queue1 代表北京火车票售卖窗口
    dispatch_queue_t queue1 = dispatch_queue_create("net.bujige.testQueue1", DISPATCH_QUEUE_SERIAL);
    // queue2 代表上海火车票售卖窗口
    dispatch_queue_t queue2 = dispatch_queue_create("net.bujige.testQueue2", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(queue1, ^{
        [self saleTicketNotSafe];
    });
    
    dispatch_async(queue2, ^{
        [self saleTicketNotSafe];
    });
    
    NSLog(@"initTicketStatusNotSave---end---%@", [NSThread currentThread]);  // 打印当前线程
}

/**
 * 售卖火车票（非线程安全）
 */
- (void)saleTicketNotSafe {
    
    while (1) {
        
        if (self.ticketSurplusCount > 0) {  // 如果还有票，继续售卖
            self.ticketSurplusCount--;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%d 窗口：%@", self.ticketSurplusCount, [NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.2];
        } else { // 如果已卖完，关闭售票窗口
            NSLog(@"所有火车票均已售完");
            break;
        }
        
    }
}

/**
 * 线程安全：使用 semaphore 加锁
 * 初始化火车票数量、卖票窗口（线程安全）、并开始卖票
 */
- (void)initTicketStatusSave {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"semaphore---begin");
    
    semaphoreLock = dispatch_semaphore_create(1);
    
    self.ticketSurplusCount = 50;
    
    // queue1 代表北京火车票售卖窗口
    dispatch_queue_t queue1 = dispatch_queue_create("net.bujige.testQueue1", DISPATCH_QUEUE_SERIAL);
    // queue2 代表上海火车票售卖窗口
    dispatch_queue_t queue2 = dispatch_queue_create("net.bujige.testQueue2", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(queue1, ^{
        [self saleTicketSafe];
    });
    
    dispatch_async(queue2, ^{
        [self saleTicketSafe];
    });
}

/**
 * 售卖火车票（线程安全）
 */
- (void)saleTicketSafe {
    while (1) {
        // 相当于加锁
        dispatch_semaphore_wait(semaphoreLock, DISPATCH_TIME_FOREVER);
        
        if (self.ticketSurplusCount > 0) {  // 如果还有票，继续售卖
            self.ticketSurplusCount--;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%d 窗口：%@", self.ticketSurplusCount, [NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.2];
        } else { // 如果已卖完，关闭售票窗口
            NSLog(@"所有火车票均已售完");
            
            // 相当于解锁
            dispatch_semaphore_signal(semaphoreLock);
            break;
        }
        
        // 相当于解锁
        dispatch_semaphore_signal(semaphoreLock);
    }
}

@end
