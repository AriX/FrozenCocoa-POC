/* Copyright (c) 2006-2007 Christopher J. W. Lloyd
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */


#import <Foundation/NSObject.h>
#import <Foundation/NSThread.h>
#import <Foundation/NSString.h>
#include <pthread.h>

@class NSDate;
@class NSThread;

@protocol NSLocking
-(void)lock;
-(void)unlock;
@end

@interface NSLock : NSObject <NSLocking> {
    pthread_mutex_t _mutex;
}

-(NSString *)name;
-(void)setName:(NSString *)value;

-(BOOL)tryLock;
-(BOOL)lockBeforeDate:(NSDate *)value;

@end

@interface NSConditionLock : NSObject <NSLocking> {
    pthread_cond_t _cond;
    pthread_mutex_t _mutex;
    NSInteger _value;
    NSThread *_lockingThread;
}

-initWithCondition:(NSInteger)condition;

-(NSInteger)condition;

-(BOOL)tryLock;
-(BOOL)tryLockWhenCondition:(NSInteger)condition;

-(void)lockWhenCondition:(NSInteger)condition;
-(void)unlockWithCondition:(NSInteger)condition;

-(BOOL)lockBeforeDate:(NSDate *)date;
-(BOOL)lockWhenCondition:(NSInteger)condition beforeDate:(NSDate *)date;

@end

@interface NSRecursiveLock : NSObject <NSLocking> {
    NSLock *_lock;
    NSThread *_lockingThread;
    int _numberOfLocks;
    NSString *_name;
}
-(NSString *)name;
-(void)setName:(NSString *)value;

-(BOOL)tryLock;
-(BOOL)lockBeforeDate:(NSDate *)value;
@end



@interface NSRecursiveLock (Private)
-(BOOL)isLocked;
@end
