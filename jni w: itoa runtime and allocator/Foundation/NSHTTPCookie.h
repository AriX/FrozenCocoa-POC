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

@class NSArray,NSDictionary,NSURL,NSDate;

FOUNDATION_EXPORT NSString *NSHTTPCookieSecure;
FOUNDATION_EXPORT NSString *NSHTTPCookieDiscard;
FOUNDATION_EXPORT NSString *NSHTTPCookieExpires;
FOUNDATION_EXPORT NSString *NSHTTPCookieMaximumAge;
FOUNDATION_EXPORT NSString *NSHTTPCookieOriginURL;

FOUNDATION_EXPORT NSString *NSHTTPCookieVersion;
FOUNDATION_EXPORT NSString *NSHTTPCookieDomain;
FOUNDATION_EXPORT NSString *NSHTTPCookiePath;
FOUNDATION_EXPORT NSString *NSHTTPCookieName;
FOUNDATION_EXPORT NSString *NSHTTPCookiePort;
FOUNDATION_EXPORT NSString *NSHTTPCookieValue;

FOUNDATION_EXPORT NSString *NSHTTPCookieComment;
FOUNDATION_EXPORT NSString *NSHTTPCookieCommentURL;

@interface NSHTTPCookie : NSObject <NSCopying> {
   NSDictionary *_properties;
}

+(NSArray *)cookiesWithResponseHeaderFields:(NSDictionary *)headerFields forURL:(NSURL *)url;
+(NSDictionary *)requestHeaderFieldsWithCookies:(NSArray *)cookies;

+cookieWithProperties:(NSDictionary *)properties;

-initWithProperties:(NSDictionary *)properties;

-(NSDictionary *)properties;

-(BOOL)isSecure;
-(BOOL)isSessionOnly;
-(NSDate *)expiresDate;

-(NSUInteger)version;
-(NSString *)domain;
-(NSString *)path;
-(NSString *)name;
-(NSArray *)portList;
-(NSString *)value;

-(NSString *)comment;
-(NSURL *)commentURL;

@end
