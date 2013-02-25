/*
 * Copyright (c) 2006-2007 Christopher J. W. Lloyd
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

#import <pthread.h>

#import <Foundation/NSLock.h>
#import <Foundation/NSRaise.h>
#import <Foundation/NSPlatform.h>
#import <Foundation/NSException.h>
#import <Foundation/NSString.h>
#import <Foundation/NSThread.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSRaiseException.h>
#import <time.h>
#import <math.h>
#import <errno.h>

@implementation NSLock

+allocWithZone:(NSZone *)zone {
    return NSAllocateObject(self,0,zone);

}

- init {
    pthread_mutex_init(&_mutex, NULL);

    return self;
}

-(void)dealloc {
    pthread_mutex_destroy(&_mutex);
    [super dealloc];
}

-(void)lock {
    if (pthread_mutex_lock(&_mutex) == -1)
        NSRaiseException(NSInvalidArgumentException,
                         self, _cmd, @"pthread_mutex_lock() returned -1");
}

-(void)unlock {
    if (pthread_mutex_unlock(&_mutex) == -1)
        NSRaiseException(NSInvalidArgumentException,
                         self, _cmd, @"pthread_mutex_lock() returned -1");
}


-(NSString *)name {
   NSInvalidAbstractInvocation();
   return nil;
}

-(void)setName:(NSString *)value {
   NSInvalidAbstractInvocation();
}

-(BOOL)tryLock {
   NSInvalidAbstractInvocation();
   return NO;
}

-(BOOL)lockBeforeDate:(NSDate *)value {
   NSInvalidAbstractInvocation();
   return NO;
}

@end


@implementation NSConditionLock

-(id)init {
   return [self initWithCondition:0];
}

-(id)initWithCondition:(NSInteger)value {
   if(self = [super init]) {
      pthread_cond_init(&_cond, NULL);
      pthread_mutex_init(&_mutex, NULL);
      _value=value;
   }
   return self;
}

-(void)dealloc {
   pthread_mutex_destroy(&_mutex);
   pthread_cond_destroy(&_cond);
   [super dealloc];
}

-(NSInteger)condition {
   return _value;
}

-(void)lock {
    int rc;
    if((rc = pthread_mutex_lock(&_mutex)) != 0) {
        [NSException raise:NSInvalidArgumentException format:@"failed to lock %@ (errno: %d)", self, rc];
    }
    _lockingThread=NSCurrentThread();
}

-(void)unlock {
   if(_lockingThread!=NSCurrentThread()) {
      [NSException raise:NSInvalidArgumentException format:@"trying to unlock %@ from thread %@, was locked from %@", self, NSCurrentThread(), _lockingThread];
   }
   
   _lockingThread=nil;
   pthread_mutex_unlock(&_mutex);
}

-(BOOL)tryLock {
   if(pthread_mutex_trylock(&_mutex))
      return NO;
   _lockingThread=NSCurrentThread();
   return YES;
}

-(BOOL)tryLockWhenCondition:(NSInteger)condition {
   if([self tryLock]) {
      return NO;
   }
   
   if(_value==condition) {
      return YES;
   }
   [self unlock];
   return NO;
}

-(void)lockWhenCondition:(NSInteger)condition {
   
    int rc;
    
    if((rc = pthread_mutex_lock(&_mutex)) != 0) {
        [NSException raise:NSInvalidArgumentException format:@"failed to lock %@ (errno: %d)", self, rc];
    }
    
    while(_value!=condition) {
        switch ((rc = pthread_cond_wait(&_cond, &_mutex))) {
            case 0:
                break;
            default:
                if((rc = pthread_mutex_unlock(&_mutex)) != 0) {
                    [NSException raise:NSInvalidArgumentException format:@"failed to unlock %@ (errno: %d)", self, rc];
                }
                [NSException raise:NSInvalidArgumentException format:@"failed to lock %@ (errno: %d)", self, rc];
        }
        
    }
    
    _lockingThread=NSCurrentThread();
}

-(void)unlockWithCondition:(NSInteger)condition {
   if(_lockingThread!=NSCurrentThread()) {
      [NSException raise:NSInvalidArgumentException format:@"trying to unlock %@ from thread %@, was locked from %@", self, NSCurrentThread(), _lockingThread];
   }

    _lockingThread=nil;
    _value=condition;
    int rc;
    if((rc = pthread_cond_broadcast(&_cond)) != 0) {
        [NSException raise:NSInvalidArgumentException format:@"failed to broadcast %@ (errno: %d)", self, rc];
    }
    if((rc = pthread_mutex_unlock(&_mutex)) != 0) {
        [NSException raise:NSInvalidArgumentException format:@"failed to unlock %@ (errno: %d)", self, rc];
    }
}

-(BOOL)lockBeforeDate:(NSDate *)date {
    int rc;
    struct timespec t={0};
    NSTimeInterval d=[date timeIntervalSinceNow];
    t.tv_sec=(unsigned int)d;
    t.tv_nsec=fmod(d, 1.0)*1000000.0;
    
    if((rc = pthread_mutex_lock(&_mutex)) != 0) {
        [NSException raise:NSInvalidArgumentException format:@"failed to lock %@ (errno: %d)", self, rc];
    }
    
    switch ((rc = pthread_cond_timedwait(&_cond, &_mutex, &t))) {
        case 0:
            _lockingThread=NSCurrentThread();
            return YES;
        case ETIMEDOUT:
            if((rc = pthread_mutex_unlock(&_mutex)) != 0) {
                [NSException raise:NSInvalidArgumentException format:@"failed to unlock %@ (errno: %d)", self, rc];
            }
            return NO;
        default:
            if((rc = pthread_mutex_unlock(&_mutex)) != 0) {
                [NSException raise:NSInvalidArgumentException format:@"failed to unlock %@ (errno: %d)", self, rc];
            }
            [NSException raise:NSInvalidArgumentException format:@"failed to lock %@ before date %@ (errno: %d)", self, date, rc];
            return NO;
    }
}

-(BOOL)lockWhenCondition:(NSInteger)condition beforeDate:(NSDate *)date {
    struct timespec t={0};
    int rc;
    NSTimeInterval d=[date timeIntervalSinceNow];
    t.tv_sec=(unsigned int)d;
    t.tv_nsec=fmod(d, 1.0)*1000000.0;

    if((rc = pthread_mutex_lock(&_mutex)) != 0) {
        [NSException raise:NSInvalidArgumentException format:@"failed to lock %@ (errno: %d)", self, rc];
    }
    
    while(_value!=condition) {
        switch ((rc = pthread_cond_timedwait(&_cond, &_mutex, &t))) {
            case 0:
                break;
            case ETIMEDOUT:
                if((rc = pthread_mutex_unlock(&_mutex)) != 0) {
                    [NSException raise:NSInvalidArgumentException format:@"failed to unlock %@ (errno: %d)", self, rc];
                }
                return NO;
            default:
                if((rc = pthread_mutex_unlock(&_mutex)) != 0) {
                    [NSException raise:NSInvalidArgumentException format:@"failed to unlock %@ (errno: %d)", self, rc];
                }
                [NSException raise:NSInvalidArgumentException format:@"failed to lock %@ before date %@ (errno: %d)", self, date, rc];
                return NO;
        }
    }
    
    _lockingThread=NSCurrentThread();
    return YES;
}

+allocWithZone:(NSZone *)zone {
   return NSAllocateObject(self,0,zone);
}

@end


@implementation NSRecursiveLock
-(id)init
{
    if((self = [super init]))
    {
        _lock=[NSLock new];
    }
    return self;
}

-(void)dealloc
{
    [_lock release];
    [_name release];
    [super dealloc];
}

-(NSString *)name;
{
    return _name;
}

-(void)setName:(NSString *)value;
{
    if(value!=_name)
    {
        [_name release];
        _name=[value retain];
    }
}

-(void)lock
{
   if(_lockingThread==[NSThread currentThread])
   {
      _numberOfLocks++;
      return;
   }
   
   [_lock lock];
   // got the lock. so it's ours now
   _lockingThread=[NSThread currentThread];
   _numberOfLocks=1;
}

-(void)unlock
{
    id currentThread=[NSThread currentThread];
    if(_lockingThread==currentThread)
    {
        _numberOfLocks--;
        if(_numberOfLocks==0)
        {
            _lockingThread=nil;
            [_lock unlock];
        }
    }
    else
        [NSException raise:NSInternalInconsistencyException format:@"tried to unlock lock %@ owned by thread %@ from thread %@", self, _lockingThread, currentThread];
}

-(BOOL)tryLock;
{
    id currentThread=[NSThread currentThread];
    BOOL ret=[_lock tryLock];
    if(ret)
    {
        // got the lock. so it's ours now
        _lockingThread=currentThread;
        _numberOfLocks=1;
        return YES;
    }
    else if(_lockingThread==currentThread)
    {
        // didn't get the lock, but just because our thread already had it
        _numberOfLocks++;
        return YES;
    }
    return NO;
}

-(BOOL)lockBeforeDate:(NSDate *)value;
{
    if([self tryLock])
        return YES;
    // tryLock failed. That means someone else owns the lock. So we wait it out:
    BOOL ret=[_lock lockBeforeDate:value];
    if(ret)
    {
        _lockingThread=[NSThread currentThread];
        _numberOfLocks=1;
    }
    return ret;
}

-(BOOL)isLocked
{
    return _numberOfLocks!=0;
}

-(id)description
{
    return [NSString stringWithFormat:@"(%@, name %@, locked %i times", [super description], _name, _numberOfLocks];
}
@end

