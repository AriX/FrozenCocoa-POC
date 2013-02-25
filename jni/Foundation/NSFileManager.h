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
#import <Foundation/NSDictionary.h>
#import <Foundation/NSFileManager.h>

@class NSData,NSDate,NSError;

FOUNDATION_EXPORT NSString *NSFileType;
FOUNDATION_EXPORT NSString    *NSFileTypeRegular;
FOUNDATION_EXPORT NSString    *NSFileTypeDirectory;
FOUNDATION_EXPORT NSString    *NSFileTypeSymbolicLink;

FOUNDATION_EXPORT NSString    *NSFileTypeCharacterSpecial;
FOUNDATION_EXPORT NSString    *NSFileTypeBlockSpecial;
FOUNDATION_EXPORT NSString    *NSFileTypeFIFO;

FOUNDATION_EXPORT NSString    *NSFileTypeSocket;

FOUNDATION_EXPORT NSString    *NSFileTypeUnknown;

FOUNDATION_EXPORT NSString *NSFileSize;
FOUNDATION_EXPORT NSString *NSFileModificationDate;
FOUNDATION_EXPORT NSString *NSFileOwnerAccountName;
FOUNDATION_EXPORT NSString *NSFileGroupOwnerAccountName;

FOUNDATION_EXPORT NSString *NSFilePosixPermissions;
FOUNDATION_EXPORT NSString *NSFileReferenceCount;
FOUNDATION_EXPORT NSString *NSFileIdentifier;
FOUNDATION_EXPORT NSString *NSFileDeviceIdentifier;

FOUNDATION_EXPORT NSString *NSFileSystemNumber;
FOUNDATION_EXPORT NSString *NSFileSystemSize;
FOUNDATION_EXPORT NSString *NSFileSystemFreeSize;

@interface NSDirectoryEnumerator : NSEnumerator
-(void)skipDescendents;
-(NSDictionary *)directoryAttributes;
-(NSDictionary *)fileAttributes;
@end

@interface NSFileManager : NSObject

+(NSFileManager *)defaultManager;

-delegate;
-(void)setDelegate:delegate;

-(NSDictionary *)attributesOfFileSystemForPath:(NSString *)path error:(NSError **)errorp;
-(NSDictionary *)attributesOfItemAtPath:(NSString *)path error:(NSError **)error;
-(BOOL)changeCurrentDirectoryPath:(NSString *)path;
-(NSArray *)componentsToDisplayForPath:(NSString *)path;
-(BOOL)contentsEqualAtPath:(NSString *)path1 andPath:(NSString *)path2;
-(NSArray *)contentsOfDirectoryAtPath:(NSString *)path error:(NSError **)error;
-(BOOL)copyItemAtPath:(NSString *)fromPath toPath:(NSString *)toPath error:(NSError **)error;
-(NSString *)destinationOfSymbolicLinkAtPath:(NSString *)path error:(NSError **)error;

-(NSString *)displayNameAtPath:(NSString *)path;

-(NSDictionary *)fileSystemAttributesAtPath:(NSString *)path;

-(BOOL)isDeletableFileAtPath:(NSString *)path;

-(BOOL)linkItemAtPath:(NSString *)fromPath toPath:(NSString *)toPath error:(NSError **)error;
-(BOOL)linkPath:(NSString *)source toPath:(NSString *)destination handler:handler;
-(BOOL)moveItemAtPath:(NSString *)fromPath toPath:(NSString *)toPath error:(NSError **)error;
-(BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error;

-(BOOL)setAttributes:(NSDictionary *)attributes ofItemAtPath:(NSString *)path error:(NSError **)error;

-(NSString *)stringWithFileSystemRepresentation:(const char *)string length:(NSUInteger)length;

-(NSArray *)subpathsAtPath:(NSString *)path;
-(NSArray *)subpathsOfDirectoryAtPath:(NSString *)path error:(NSError **)error;

-(NSData *)contentsAtPath:(NSString *)path;

-(BOOL)createFileAtPath:(NSString *)path contents:(NSData *)data attributes:(NSDictionary *)attributes;

-(NSArray *)directoryContentsAtPath:(NSString *)path;
-(NSDirectoryEnumerator *)enumeratorAtPath:(NSString *)path;

-(BOOL)createDirectoryAtPath:(NSString *)path attributes:(NSDictionary *)attributes;
-(BOOL)createDirectoryAtPath:(NSString *)path withIntermediateDirectories:(BOOL)intermediates attributes:(NSDictionary *)attributes error:(NSError **)error;

-(BOOL)createSymbolicLinkAtPath:(NSString *)path pathContent:(NSString *)destination;
-(BOOL)createSymbolicLinkAtPath:(NSString *)path withDestinationPath:(NSString *)toPath error:(NSError **)error;

-(NSString *)pathContentOfSymbolicLinkAtPath:(NSString *)path;

-(BOOL)fileExistsAtPath:(NSString *)path;
-(BOOL)fileExistsAtPath:(NSString *)path isDirectory:(BOOL *)isDirectory;

-(BOOL)removeFileAtPath:(NSString *)path handler:handler;

-(BOOL)movePath:(NSString *)src toPath:(NSString *)dest handler:handler;
-(BOOL)copyPath:(NSString *)src toPath:(NSString *)dest handler:handler;

-(NSString *)currentDirectoryPath;

-(NSDictionary *)fileAttributesAtPath:(NSString *)path traverseLink:(BOOL)traverse;

-(BOOL)isReadableFileAtPath:(NSString *)path;
-(BOOL)isWritableFileAtPath:(NSString *)path;
-(BOOL)isExecutableFileAtPath:(NSString *)path;

-(BOOL)changeFileAttributes:(NSDictionary *)attributes atPath:(NSString *)path;

-(const char *)fileSystemRepresentationWithPath:(NSString *)path;
-(const uint16_t *)fileSystemRepresentationWithPathW:(NSString *)path;

@end

@interface NSObject(NSFileManager_handler)
-(BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSDictionary *)dictionary;
-(void)fileManager:(NSFileManager *)fileManager willProcessPath:(NSString *)path;
@end

@interface NSObject(NSFileManagerDelegate)
-(BOOL)fileManager:(NSFileManager *)fileManager shouldCopyItemAtPath:(NSString *)path toPath:(NSString *)toPath;
-(BOOL)fileManager:(NSFileManager *)fileManager shouldLinkItemAtPath:(NSString *)path toPath:(NSString *)toPath;
-(BOOL)fileManager:(NSFileManager *)fileManager shouldMoveItemAtPath:(NSString *)path toPath:(NSString *)toPath;
-(BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error copyingItemAtPath:(NSString *)path toPath:(NSString *)toPath;
-(BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error linkingItemAtPath:(NSString *)path toPath:(NSString *)toPath;
-(BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error movingItemAtPath:(NSString *)path toPath:(NSString *)toPath;
-(BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error removingItemAtPath:(NSString *)path;

-(BOOL)fileManager:(NSFileManager *)fileManager shouldRemoveItemAtPath:(NSString *)path;

@end

@interface NSDictionary(NSFileManager_fileAttributes)
-(NSDate *)fileModificationDate;
-(NSUInteger)filePosixPermissions;
-(NSString *)fileOwnerAccountName;
-(NSString *)fileGroupOwnerAccountName;
-(NSString *)fileType;
-(uint64_t)fileSize;
@end

