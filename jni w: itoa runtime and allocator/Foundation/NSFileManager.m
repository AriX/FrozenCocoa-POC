/*
 * Copyright (C) 2010 Dmitry Skiba, Dmitry Skorinko
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


#import <Foundation/NSFileManager.h>
#import <Foundation/NSThread.h>
#import <Foundation/NSRaise.h>
#import <Foundation/NSValue.h>
#import <Foundation/NSData.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSConcreteDirectoryEnumerator.h>
#import <Foundation/NSBundle.h>
#import <Foundation/NSPathUtilities.h>
#import <Foundation/NSPlatform.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSRange.h>
#import <Foundation/NSRaiseException.h>

//#include <libzzip/zzip.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/param.h>
#include <sys/limits.h>
#include <unistd.h>
#include <fcntl.h>
#include <pwd.h>
#include <grp.h>
#include <dirent.h>
#include <errno.h>
#include <string.h>

NSString *NSFileType = @"NSFileType";
NSString *NSFileTypeRegular = @"NSFileTypeRegular";
NSString *NSFileTypeDirectory = @"NSFileTypeDirectory";
NSString *NSFileTypeSymbolicLink = @"NSFileTypeSymbolicLink";
NSString *NSFileTypeCharacterSpecial = @"NSFileTypeCharacterSpecial";
NSString *NSFileTypeBlockSpecial = @"NSFileTypeBlockSpecial";
NSString *NSFileTypeFIFO = @"NSFileTypeFIFO";
NSString *NSFileTypeSocket = @"NSFileTypeSocket";
NSString *NSFileTypeUnknown = @"NSFileTypeUnknown";

NSString *NSFileSize = @"NSFileSize";
NSString *NSFileModificationDate = @"NSFileModificationDate";
NSString *NSFileOwnerAccountName = @"NSFileOwnerAccountName";
NSString *NSFileGroupOwnerAccountName = @"NSFileGroupOwnerAccountName";

NSString *NSFileReferenceCount = @"NSFileReferenceCount";
NSString *NSFileIdentifier = @"NSFileIdentifier";
NSString *NSFileDeviceIdentifier = @"NSFileDeviceIdentifier";
NSString *NSFilePosixPermissions = @"NSFilePosixPermissions";
NSString *NSFileHFSCreatorCode = @"NSFileHFSCreatorCode";
NSString *NSFileHFSTypeCode = @"NSFileHFSTypeCode";

NSString *NSFileSystemNumber=@"NSFileSystemNumber";
NSString *NSFileSystemSize=@"NSFileSystemSize";
NSString *NSFileSystemFreeSize=@"NSFileSystemFreeSize";

@implementation NSFileManager

+(NSFileManager *)defaultManager {
   return NSThreadSharedInstance(@"NSFileManager");
}

-delegate {
   NSUnimplementedMethod();
   return 0;
}
-(void)setDelegate:delegate {
   NSUnimplementedMethod();
}

-(NSDictionary *)attributesOfFileSystemForPath:(NSString *)path error:(NSError **)errorp {
   NSUnimplementedMethod();
   return 0;
}
-(NSDictionary *)attributesOfItemAtPath:(NSString *)path error:(NSError **)error {
   NSUnimplementedMethod();
   return 0;
}
-(BOOL)changeCurrentDirectoryPath:(NSString *)path {
   NSUnimplementedMethod();
   return 0;
}
-(NSArray *)componentsToDisplayForPath:(NSString *)path {
   NSUnimplementedMethod();
   return 0;
}
-(BOOL)contentsEqualAtPath:(NSString *)path1 andPath:(NSString *)path2 {
   NSUnimplementedMethod();
   return 0;
}
-(NSArray *)contentsOfDirectoryAtPath:(NSString *)path error:(NSError **)error {
   NSUnimplementedMethod();
   return 0;
}
-(BOOL)copyItemAtPath:(NSString *)fromPath toPath:(NSString *)toPath error:(NSError **)error {
   NSUnimplementedMethod();
   return 0;
}
-(NSString *)destinationOfSymbolicLinkAtPath:(NSString *)path error:(NSError **)error {
   NSUnimplementedMethod();
   return 0;
}

-(NSString *)displayNameAtPath:(NSString *)path {
   NSBundle *bundle=[NSBundle bundleWithPath:path];
   NSString *name=nil;
   if(bundle) {
    NSDictionary *localizedInfo=[bundle localizedInfoDictionary];
    name=[localizedInfo objectForKey:@"CFBundleDisplayName"];
    if(!name)
     name=[localizedInfo objectForKey:@"CFBundleName"];
   }
   if(!name)
    name=[path lastPathComponent];
   return name;
}

-(NSDictionary *)fileSystemAttributesAtPath:(NSString *)path {
   NSUnimplementedMethod();
   return 0;
}

-(BOOL)isDeletableFileAtPath:(NSString *)path {
   NSUnimplementedMethod();
   return 0;
}

-(BOOL)linkItemAtPath:(NSString *)fromPath toPath:(NSString *)toPath error:(NSError **)error {
   NSUnimplementedMethod();
   return 0;
}
-(BOOL)linkPath:(NSString *)source toPath:(NSString *)destination handler:handler {
   NSUnimplementedMethod();
   return 0;
}
-(BOOL)moveItemAtPath:(NSString *)fromPath toPath:(NSString *)toPath error:(NSError **)error {
   NSUnimplementedMethod();
   return 0;
}
-(BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error {
   NSUnimplementedMethod();
   return 0;
}

-(BOOL)setAttributes:(NSDictionary *)attributes ofItemAtPath:(NSString *)path error:(NSError **)error {
   NSUnimplementedMethod();
   return 0;
}

-(NSString *)stringWithFileSystemRepresentation:(const char *)string length:(NSUInteger)length {
   NSUnimplementedMethod();
   return 0;
}

-(NSArray *)_subpathsAtPath:(NSString *)path basePath:(NSString*)basePath 
paths:(NSMutableArray*)paths
{
    NSArray* files = [self directoryContentsAtPath:path];

    int x; for (x = 0; x < [files count]; x++)
    {
        [paths addObject:[basePath stringByAppendingPathComponent:[files objectAtIndex:x]]];
    }
    
    for (x = 0; x < [files count]; x++)
    {
        BOOL isDir = NO;
        NSString* newPath = [path stringByAppendingPathComponent:[files objectAtIndex:x]];
        [self fileExistsAtPath:newPath isDirectory:&isDir];
        if (isDir)
            [self _subpathsAtPath:newPath basePath:[basePath stringByAppendingPathComponent:[files objectAtIndex:x]] paths:paths];
    }
}

-(NSArray *)subpathsAtPath:(NSString *)path {
    NSMutableArray *result=[NSMutableArray array];
    
    [self _subpathsAtPath:path basePath:@"" paths:result];
    return result;
}

-(NSArray *)subpathsOfDirectoryAtPath:(NSString *)path error:(NSError **)error {
   NSUnimplementedMethod();
   return 0;
}

-(NSData *)contentsAtPath:(NSString *)path {
   return [NSData dataWithContentsOfFile:path];
}

-(BOOL)createFileAtPath:(NSString *)path contents:(NSData *)data
             attributes:(NSDictionary *)attributes 
{
    //no creating inside apk
    if([[path stringByStandardizingPath] hasPrefix:[[NSBundle mainBundle] bundlePath]])
        return NO;
    return NSPlatformWriteContentsOfFile(path, [data bytes], [data length], YES);
}

-(NSArray *)directoryContentsAtPath:(NSString *)path {
    NSMutableArray *result=[NSMutableArray array];
    NSString* bundle = [[NSBundle mainBundle] bundlePath];
    BOOL inside_apk = [[path stringByStandardizingPath] hasPrefix:bundle];
    NSString* subpath;
    
/*    ZZIP_DIR *dirp;
    if(!inside_apk)
        dirp = zzip_opendir([[path stringByStandardizingPath] fileSystemRepresentation]);
    else
    {
        dirp = zzip_opendir([bundle fileSystemRepresentation]);
        
        if([bundle length] == [[path stringByStandardizingPath] length] ||
          ([bundle length] == [[path stringByStandardizingPath] length]-1 && [path hasSuffix:@"/"]))
        {
            //no subpath! files inside root of apk
            subpath=@"";
        }                
        else
        {
            //NSUInteger start = find.length; start++;
            subpath = [path substringWithRange:NSMakeRange([bundle length]+1, [[path stringByStandardizingPath] length] - [bundle length] - 1)];
            if(![subpath hasSuffix:@"/"]) subpath = [subpath stringByAppendingString:@"/"];
        }
    }
        
    if (dirp == NULL)
        return nil;
        
    struct zzip_dirent *dire;
   
    while (dire = zzip_readdir(dirp)){
     if(strcmp(".",dire->d_name)==0)
      continue;
     if(strcmp("..",dire->d_name)==0)
      continue;
      
     NSString* file_inside_dir = [NSString stringWithCString:dire->d_name];
     
     if(inside_apk)
     {
         //inside apk
         if([subpath length] && [file_inside_dir rangeOfString:subpath].location == NSNotFound)
              continue;
         file_inside_dir = [file_inside_dir substringWithRange:NSMakeRange([subpath length],  [file_inside_dir length] - [subpath length])];
         
         NSRange find_slash = [file_inside_dir rangeOfString:@"/"];
         if(find_slash.location != NSNotFound)
             [result addObject:[file_inside_dir substringWithRange:NSMakeRange(0, find_slash.location)]];
         else
             [result addObject:file_inside_dir];           
     }
     else
         [result addObject:file_inside_dir];

     //TODO?
     //[file_inside_dir release];
     //[subpath release];
    }

    zzip_closedir(dirp);
*/
    //return array unique
    return [[NSSet setWithArray:result] allObjects];
}

-(NSDirectoryEnumerator *)enumeratorAtPath:(NSString *)path {
    return [[[NSConcreteDirectoryEnumerator alloc] initWithPath: path] autorelease];
}

-(BOOL)createDirectoryAtPath:(NSString *)path attributes:(NSDictionary *)attributes 
{
    //no creating inside apk
    if([[path stringByStandardizingPath] hasPrefix:[[NSBundle mainBundle] bundlePath]])
        return NO;
    // you can set all these, but we don't respect 'em all yet
    NSDate *date = [attributes objectForKey:NSFileModificationDate];
    NSString *owner = [attributes objectForKey:NSFileOwnerAccountName];
    NSString *group = [attributes objectForKey:NSFileGroupOwnerAccountName];
    
    int mode = [[attributes objectForKey:NSFilePosixPermissions] intValue];

    if (mode == 0)
        mode = FOUNDATION_DIR_MODE;

    return (mkdir([path fileSystemRepresentation], mode) == 0);
}

-(BOOL)createDirectoryAtPath:(NSString *)path withIntermediateDirectories:(BOOL)intermediates attributes:(NSDictionary *)attributes error:(NSError **)error {
   NSUnimplementedMethod();
   return 0;
}

-(BOOL)createSymbolicLinkAtPath:(NSString *)path pathContent:(NSString *)otherPath {
    return (symlink([otherPath fileSystemRepresentation], [path fileSystemRepresentation]) == 0);
}

-(BOOL)createSymbolicLinkAtPath:(NSString *)path withDestinationPath:(NSString *)destPath error:(NSError **)error {
   NSUnimplementedMethod();
   return 0;
}

-(NSString *)pathContentOfSymbolicLinkAtPath:(NSString *)path {
    char linkbuf[MAXPATHLEN+1];
    size_t length;

    length = readlink([path fileSystemRepresentation], linkbuf, MAXPATHLEN);
    if (length ==-1)
        return nil;

    linkbuf[length] = 0;
    return [NSString stringWithCString:linkbuf];
}

-(BOOL)fileExistsAtPath:(NSString *)path {
   BOOL foo;
   return [self fileExistsAtPath:path isDirectory:&foo];
}

-(BOOL)fileExistsAtPath:(NSString *)path isDirectory:(BOOL *)isDirectory {
/*    struct stat buf;
    struct zzip_dirent *dire;

    if(![[path stringByStandardizingPath] hasPrefix:[[NSBundle mainBundle] bundlePath]])
    {
       //outside of apk
       if(stat([path fileSystemRepresentation],&buf)<0)
           return NO;
       if(isDirectory!=NULL)
           *isDirectory=S_ISDIR(buf.st_mode);     
       return YES;
    }
    else
    {
        //inside apk
        //There are cant be empty folders inside apk. I don't know why, but it's more easy

        ZZIP_DIR *dirp = zzip_opendir([[[NSBundle mainBundle] bundlePath] fileSystemRepresentation]);
        if(!dirp) return NO;
        while (dire = zzip_readdir(dirp))
        {
            NSString* file_inside_dir_full = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:[NSString stringWithCString:dire->d_name]];
            if([file_inside_dir_full hasPrefix:[path stringByStandardizingPath]])
            {
                if([file_inside_dir_full length] == [[path stringByStandardizingPath] length])
                {
                    if(isDirectory) *isDirectory=NO;
                    return YES;
                }
                else if([[path stringByStandardizingPath] hasSuffix:@"/"])
                {
                    if(isDirectory) *isDirectory=YES;
                    return YES;
                }
                else if([file_inside_dir_full hasPrefix:[[path stringByStandardizingPath] stringByAppendingFormat:@"/"]])
                {
                    if(isDirectory) *isDirectory=YES;
                    return YES;
                }
            }
        }
    }
    
    return NO;
}

// we dont want to use fileExists outside apk... because it chases links
-(BOOL)_isDirectory:(NSString *)path {
    struct stat buf;

    if([[path stringByStandardizingPath] hasPrefix:[[NSBundle mainBundle] bundlePath]])
    {
        //inside apk
        BOOL is_dir;
        [self fileExistsAtPath:path isDirectory:&is_dir];
        return is_dir;
    }

    if(lstat([path fileSystemRepresentation],&buf)<0)
        return NO;

    if (buf.st_mode & S_IFDIR && !(buf.st_mode & S_IFLNK))
        return YES;
*/
    return NO;
}

-(BOOL)_errorHandler:handler src:(NSString *)src dest:(NSString *)dest operation:(NSString *)op {
    if ([handler respondsToSelector:@selector(fileManager:shouldProceedAfterError:)]) {
        NSDictionary *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:
            src, @"Path",
            [NSString stringWithFormat:@"%@: %s", op, strerror(errno)], @"Error",
            dest, @"ToPath",
            nil];

        if ([handler fileManager:self shouldProceedAfterError:errorInfo])
            return YES;
    }

    return NO;
}

-(BOOL)removeFileAtPath:(NSString *)path handler:handler {
    if([path isEqualToString:@"."] || [path isEqualToString:@".."])
        NSRaiseException(NSInvalidArgumentException, self, _cmd, @"%@: invalid path", path);
    
    if([[path stringByStandardizingPath] hasPrefix:[[NSBundle mainBundle] bundlePath]])
        return [self _errorHandler:handler src:path dest:@"" operation:@"removeFile: removing inside apk"];

    if ([handler respondsToSelector:@selector(fileManager:willProcessPath:)])
        [handler fileManager:self willProcessPath:path];
 
    if(![self _isDirectory:path]){
        if(remove([path fileSystemRepresentation]) == -1)
            return [self _errorHandler:handler src:path dest:@"" operation:@"removeFile: remove()"];
    }
    else{
        NSArray *contents=[self directoryContentsAtPath:path];
        NSInteger i,count=[contents count];

        for(i=0;i<count;i++){
            NSString *name = [contents objectAtIndex:i];
            NSString *fullPath;

            if([name isEqualToString:@"."] || [name isEqualToString:@".."])
                continue;

            fullPath=[path stringByAppendingPathComponent:name];
            if(![self removeFileAtPath:fullPath handler:handler])
                return NO;
        }

        if(rmdir([path fileSystemRepresentation]) == -1)
            return [self _errorHandler:handler src:path dest:@"" operation:@"removeFile: rmdir()"];
    }
    return YES;
}

-(BOOL)movePath:(NSString *)src toPath:(NSString *)dest handler:handler {
/*
    It's not this easy...
    return rename([src fileSystemRepresentation],[dest fileSystemRepresentation])?NO:YES;
 */

    BOOL isDirectory;

    if ([handler respondsToSelector:@selector(fileManager:willProcessPath:)])
        [handler fileManager:self willProcessPath:src];

    if ([self fileExistsAtPath:src isDirectory:&isDirectory] == NO)
        return NO;
    if ([self fileExistsAtPath:dest isDirectory:&isDirectory] == YES)
        return NO;

    if ([self copyPath:src toPath:dest handler:handler] == NO) {
        [self removeFileAtPath:dest handler:handler];
        return NO;
    }

    // not much we can do if this fails
    [self removeFileAtPath:src handler:handler];

    return YES;
}

-(BOOL)copyPath:(NSString *)src toPath:(NSString *)dest handler:handler {
    BOOL isDirectory;

    if(![self fileExistsAtPath:src isDirectory:&isDirectory])
        return [self _errorHandler:handler src:src dest:dest operation:@"copyPath: fileExistsAtPath:"];
    
    if([[dest stringByStandardizingPath] hasPrefix:[[NSBundle mainBundle] bundlePath]])
        return [self _errorHandler:handler src:src dest:dest operation:@"copyPath: copying into apk"];

    if ([handler respondsToSelector:@selector(fileManager:willProcessPath:)])
        [handler fileManager:self willProcessPath:src];

    if (!isDirectory){
 /*       ZZIP_FILE *file_r;
        ZZIP_FILE *file_w;
        char buf[4096];
        size_t count;

        if ((file_w = zzip_open([dest fileSystemRepresentation], O_WRONLY|O_CREAT)) == NULL) 
            return [self _errorHandler:handler src:src dest:dest operation:@"copyPath: open() for writing"];
        if ((file_r = zzip_open([src fileSystemRepresentation], O_RDONLY)) == NULL)
            return [self _errorHandler:handler src:src dest:dest operation:@"copyPath: open() for reading"];

        while (count = zzip_read(file_r, &buf, sizeof(buf))) {
            if (count == -1) 
                break;

            if (zzip_write(file_w, &buf, count) != count) {
                //it should be simple file!
                count = -1;
                break;
            }
        }

        zzip_close(file_w);
        zzip_close(file_r);

        if (count == -1)
            return [self _errorHandler:handler src:src dest:dest operation:@"copyPath: read()/write()"];
        else
            return YES;*/
    }
    else {
        NSArray *files;
        NSInteger      i,count;

        if (mkdir([dest fileSystemRepresentation], FOUNDATION_DIR_MODE) != 0)
            return [self _errorHandler:handler src:src dest:dest operation:@"copyPath: mkdir(subdir)"];

        //if (chdir([dest fileSystemRepresentation]) != 0)
        //    return [self _errorHandler:handler src:src dest:dest operation:@"copyPath: chdir(subdir)"];

        files = [self directoryContentsAtPath:src];
        count = [files count];

        for(i=0;i<count;i++){
            NSString *name=[files objectAtIndex:i];
            NSString *subsrc, *subdst;

            if ([name isEqualToString:@"."] || [name isEqualToString:@".."])
                 continue;

            subsrc=[src stringByAppendingPathComponent:name];
            subdst=[dest stringByAppendingPathComponent:name];

            if([self copyPath:subsrc toPath:subdst handler:handler] == NO) 
                return NO;
        }

        //if (chdir("..") != 0)
        //    return [self _errorHandler:handler src:src dest:dest operation:@"copyPath: chdir(..)"];
    }

    return YES;
}

-(NSString *)currentDirectoryPath {
    char  path[MAXPATHLEN+1];

    if (getcwd(path, sizeof(path)) != NULL)
        return [NSString stringWithCString:path];

    return nil;
}

-(NSDictionary *)fileAttributesAtPath:(NSString *)path traverseLink:(BOOL)traverse {
    NSMutableDictionary *result=[NSMutableDictionary dictionary];
    struct stat statBuf;
    struct passwd *pwd;
    struct group *grp;
    NSString *type;

    if (lstat([path fileSystemRepresentation], &statBuf) != 0) 
        return nil;

    // (Not in POSIX.1-1996.)
    if (S_ISLNK(statBuf.st_mode) && traverse) {
        NSString *linkContents = [self pathContentOfSymbolicLinkAtPath:path];
        return [self fileAttributesAtPath:linkContents traverseLink:traverse];
    }

    [result setObject:[NSNumber numberWithUnsignedLong:statBuf.st_size]
               forKey:NSFileSize];
    [result setObject:[NSDate dateWithTimeIntervalSince1970:statBuf.st_mtime]
               forKey:NSFileModificationDate];

    // User/group names don't always exist for the IDs in the filesystem.
    // If we don't check for NULLs, we'll segfault.
    pwd = getpwuid(statBuf.st_uid);
    if (pwd != NULL)
        [result setObject:[NSString stringWithCString:pwd->pw_name]
                   forKey:NSFileOwnerAccountName];

    grp = getgrgid(statBuf.st_gid);
    if (grp != NULL)
        [result setObject:[NSString stringWithCString:grp->gr_name]
                   forKey:NSFileGroupOwnerAccountName];

    [result setObject:[NSNumber numberWithUnsignedLong:statBuf.st_nlink]
               forKey:NSFileReferenceCount];
    [result setObject:[NSNumber numberWithUnsignedLong:statBuf.st_ino]
               forKey:NSFileIdentifier];
    [result setObject:[NSNumber numberWithUnsignedLong:statBuf.st_dev]
               forKey:NSFileDeviceIdentifier];
    [result setObject:[NSNumber numberWithUnsignedLong:statBuf.st_mode]
               forKey:NSFilePosixPermissions];

    // ugh.. skip this if we can
    if (!S_ISREG(statBuf.st_mode)) {
        if (S_ISDIR(statBuf.st_mode))
            [result setObject:NSFileTypeDirectory forKey:NSFileType];
        else if (S_ISCHR(statBuf.st_mode))
            [result setObject:NSFileTypeCharacterSpecial forKey:NSFileType];
        else if (S_ISBLK(statBuf.st_mode))
            [result setObject:NSFileTypeBlockSpecial forKey:NSFileType];
        else if (S_ISFIFO(statBuf.st_mode))
            [result setObject:NSFileTypeFIFO forKey:NSFileType];
        else if (S_ISLNK(statBuf.st_mode))
            [result setObject:NSFileTypeSymbolicLink forKey:NSFileType];
        else if (S_ISSOCK(statBuf.st_mode))
            [result setObject:NSFileTypeSocket forKey:NSFileType];
    }
    else
        [result setObject:NSFileTypeRegular forKey:NSFileType];

    return result;
}

-(BOOL)isReadableFileAtPath:(NSString *)path {
    return access([path fileSystemRepresentation], R_OK) ? NO : YES;
}

-(BOOL)isWritableFileAtPath:(NSString *)path {
    return access([path fileSystemRepresentation], W_OK) ? NO : YES;
}

-(BOOL)isExecutableFileAtPath:(NSString *)path {
    return access([path fileSystemRepresentation], X_OK) ? NO : YES;
}

-(BOOL)changeFileAttributes:(NSDictionary *)attributes atPath:(NSString *)path {
   NSInvalidAbstractInvocation();
   return NO;
}

-(const char *)fileSystemRepresentationWithPath:(NSString *)path {
    return [path cStringUsingEncoding:NSUTF8StringEncoding];
}

-(const uint16_t *)fileSystemRepresentationWithPathW:(NSString *)path {
   NSInvalidAbstractInvocation();
   return NULL;
}


@end

@implementation NSDictionary(NSFileAttributes)

-(NSDate *)fileModificationDate {
   return [self objectForKey:NSFileModificationDate];
}

-(NSUInteger)filePosixPermissions {
   return [[self objectForKey:NSFilePosixPermissions] unsignedIntegerValue];
}

-(NSString *)fileOwnerAccountName {
   return [self objectForKey:NSFileOwnerAccountName];
}

-(NSString *)fileGroupOwnerAccountName {
   return [self objectForKey:NSFileGroupOwnerAccountName];
}

-(NSString *)fileType {
   return [self objectForKey:NSFileType];
}

-(uint64_t)fileSize {
   return [[self objectForKey:NSFileSize] unsignedLongLongValue];
}

@end


@implementation NSDirectoryEnumerator

-(void)skipDescendents {
   NSUnimplementedMethod();
}

-(NSDictionary *)directoryAttributes {
   return nil;
}

-(NSDictionary *)fileAttributes {
   return nil;
}

@end
