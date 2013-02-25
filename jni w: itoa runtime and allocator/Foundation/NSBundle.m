/*
 * Copyright (c) 2006-2007 Christopher J. W. Lloyd
                 2009 Markus Hitter (mah@jump-ing.de)
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


#import <Foundation/NSBundle.h>
#import <Foundation/NSLocale.h>
#import <Foundation/NSMapTable.h>
#import <Foundation/NSString.h>
#import <Foundation/NSPathUtilities.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSRaise.h>
#import <Foundation/NSPlatform.h>
#import <objc/runtime.h>
#import <Foundation/NSRaiseException.h>

NSString *NSBundleDidLoadNotification=@"NSBundleDidLoadNotification";
NSString *NSLoadedClasses=@"NSLoadedClasses";

@implementation NSBundle

static NSMutableArray *_allBundles=nil;
static NSMutableArray *_allFrameworks=nil;

static NSBundle   *mainBundle=nil;
static NSMapTable *nameToBundle=NULL;
static NSMapTable *pathToObject=NULL;

-(void)_setLoaded:(BOOL)loaded {
   _isLoaded=loaded;
}

/*
  Executables support:
    MyProgram.app/Contents/<platform>/MyProgram[.exe]
   or
    MyProgram[.exe]
    MyProgram.app/Contents/
    
 */
+(NSString *)bundlePathFromModulePath:(NSString *)path {
   NSString *result=nil;
   NSString *directory=[path stringByDeletingLastPathComponent];
   NSString *extension=[[path pathExtension] lowercaseString];
   NSString *name=[[path lastPathComponent] stringByDeletingPathExtension];
   NSRange   version=[name rangeOfString:@"."];

   if(version.location!=NSNotFound)
    name=[name substringToIndex:version.location];

   if(![extension isEqualToString:NSPlatformLoadableObjectFileExtension]){
    NSString *check=[[directory stringByAppendingPathComponent:name] stringByAppendingPathExtension:@"apk"];
        
    if([[NSFileManager defaultManager] fileExistsAtPath:check])
     result=check;
    else
     result=[[directory stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];
   }
   else {
    NSString *loadablePrefix=NSPlatformLoadableObjectFilePrefix;
    NSString *check;
    
    if([loadablePrefix length]>0 && [name hasPrefix:loadablePrefix])
     name=[name substringFromIndex:[loadablePrefix length]];

    check=[[directory stringByAppendingPathComponent:name] stringByAppendingPathExtension:@"framework"];
   
    if([[NSFileManager defaultManager] fileExistsAtPath:check])
     result=check;
    else {
        check=[[[directory stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Frameworks"] stringByAppendingPathComponent:[name stringByAppendingPathExtension:@"framework"]];
     if([[NSFileManager defaultManager] fileExistsAtPath:check])
      result=check;
     else {
      result=[[directory stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];
     }
    }
   }
   return result;
}


+(NSBundle *)bundleWithModulePath:(NSString *)path {
   NSBundle *result;

   path=[self bundlePathFromModulePath:path];

   result=[NSBundle bundleWithPath:path];

   [result _setLoaded:YES];

   return result;
}

+(void)registerFrameworks {
   // unsigned       i,count;
   // const char   **array=objc_copyImageNames(&count);

   // for(i=0;i<count;i++){
   //  NSString *path=[NSString stringWithCString:array[i]];
   //  NSBundle *bundle=[NSBundle bundleWithModulePath:path];

   //  [_allFrameworks addObject:bundle];
   // }
   // free(array);
}

+(void)initialize {
   if(self==[NSBundle class]){

     //TODO
     #define APK_NAME @"/data/app/com.itoa.apk"
     NSString *path=APK_NAME;

   //  const char *override=getenv("CFProcessPath");
   //  const char *module=override ? override : OBJCModulePathForProcess();
   //  NSString   *path=[NSString stringWithCString:module];

   //  if(module==NULL)
   //   NSCLog("+[NSBundle initialize]: module path for process is NULL");
    
     _allBundles=[NSMutableArray new];
     _allFrameworks=[NSMutableArray new];
     pathToObject=NSCreateMapTable(NSObjectMapKeyCallBacks,NSObjectMapValueCallBacks,0);
     nameToBundle=NSCreateMapTable(NSObjectMapKeyCallBacks,NSObjectMapValueCallBacks,0);

     mainBundle=[NSBundle bundleWithPath:path];

   //  [self registerFrameworks];
   }
}


+(NSArray *)allBundles {
   return _allBundles;
}


+(NSArray *)allFrameworks {
   return _allFrameworks;
}


+(NSBundle *)mainBundle {
   return mainBundle;
}

+(NSBundle *)bundleForClass:(Class)class {
   // NSBundle *bundle=NSMapGet(nameToBundle,NSStringFromClass(class));

   // if(bundle==nil){
   //  const char *module=class_getImageName(class);

   //  if(module==NULL)
   //   return [self mainBundle]; // this is correct behaviour for Nil class
   //  else {
   //   NSString   *path=[NSString stringWithCString:module];

   //   bundle=[NSBundle bundleWithModulePath:path];
   //   NSMapInsert(nameToBundle,NSStringFromClass(class),bundle);
   //  }
   // }

   // return bundle;
   return mainBundle;
}

+(NSBundle *)bundleWithIdentifier:(NSString *)identifier {
   NSUnimplementedMethod();
   return 0;
}

-initWithPath:(NSString *)path {
   NSBundle *realBundle=NSMapGet(pathToObject,path);

   if(realBundle!=nil){
    [self dealloc];
    return [realBundle retain];
   }

   _path=[path retain];
   _resourcePath=[_path stringByAppendingPathComponent:@"res"];
   //if(![[NSFileManager defaultManager] fileExistsAtPath:_resourcePath])
    //_resourcePath=[[_path stringByAppendingPathComponent:@"Contents"] stringByAppendingPathComponent:@"Resources"];
   [_resourcePath retain];
   
   _infoDictionary=nil;
   _isLoaded=NO;

   NSMapInsert(pathToObject,path,self);

   [_allBundles addObject:self];

   return self;
}

+(NSBundle *)bundleWithPath:(NSString *)path {
   return [[[self allocWithZone:NULL] initWithPath:path] autorelease];
}

+(NSString *)pathForResource:(NSString *)name ofType:(NSString *)type inDirectory:(NSString *)path {
/*
   NSFileManager *defaultManager = [NSFileManager defaultManager];

   NSString* path_to_search = [NSString stringWithString:[[NSBundle mainBundle] bundlePath]];
   [path_to_search stringByAppendingFormat:@"/%@", path];
   NSArray* files_inside_apk = [defaultManager directoryContentsAtPath:path_to_search];
   
   NSString* full_file_name = [NSString stringWithString:name];
   [full_file_name stringByAppendingFormat:@".%@", type];
   
   int i, files_count = [files_inside_apk count];
   for (i = 0; i < files_count; i++)
   {
       NSString* string = [files_inside_apk objectAtIndex:i];
       NSRange find = [string rangeOfString:full_file_name];
       if(find.location != NSNotFound)
       {
           NSUInteger index = [string length] - [full_file_name length];
           index--;
           if([full_file_name isEqualToString:[string substringFromIndex:index]])
               return [path_to_search stringByAppendingFormat:@"/%@", string];
       }
   }
   
*/
   return nil;
}
+(NSArray *)pathsForResourcesOfType:(NSString *)type inDirectory:(NSString *)path {
/*
    NSFileManager *defaultManager = [NSFileManager defaultManager];

   NSString* path_to_search = [NSString stringWithString:[[NSBundle mainBundle] bundlePath]];
   [path_to_search stringByAppendingFormat:@"/%@", path];
   NSArray* files_inside_apk = [defaultManager directoryContentsAtPath:path_to_search];
   
   NSString* full_file_name = [NSString stringWithString:name];
   [full_file_name stringByAppendingFormat:@".%@", type];
   
   NSArray* result_array = [NSArray array];
   
   int i, files_count = [files_inside_apk count];
   for (i = 0; i < files_count; i++)
   {
       NSString* string = [files_inside_apk objectAtIndex:i];
       NSRange find = [string rangeOfString:full_file_name];
       if(find.location != NSNotFound)
       {
           NSUInteger index = [string length] - [full_file_name length];
           index--;
           if([full_file_name isEqualToString:[string substringFromIndex:index]])
               return [path_to_search stringByAppendingFormat:@"/%@", string];
       }
   }
   
*/
   return nil;
}
+(NSArray *)preferredLocalizationsFromArray:(NSArray *)localizations {
   NSUnimplementedMethod();
   return 0;
}
+(NSArray *)preferredLocalizationsFromArray:(NSArray *)localizations forPreferences:(NSArray *)preferences {
   NSUnimplementedMethod();
   return 0;
}

-(NSString *)bundlePath {
   return _path;
}

-(NSString *)resourcePath {
   return _resourcePath;
}

-(NSString *)builtInPlugInsPath {
   NSUnimplementedMethod();
   return 0;
}

-(NSDictionary *)infoDictionary {
   if(_infoDictionary==nil){
    NSString *path=[self pathForResource:@"Info" ofType:@"plist" inDirectory:[_path stringByAppendingPathComponent:@"res"]];

    _infoDictionary=[[NSDictionary allocWithZone:NULL] initWithContentsOfFile:path];

    if(_infoDictionary==nil)
     _infoDictionary=[NSDictionary new];
   }

   return _infoDictionary;
}

-(NSDictionary *)localizedInfoDictionary {
// FIXME: implement, dont uncomment NSUnimplementedMethod.
  // NSUnimplementedMethod();
   return [self infoDictionary];
}

-objectForInfoDictionaryKey:(NSString *)key {
   return [[self infoDictionary] objectForKey:key];
}

-(NSString *)bundleIdentifier {
   return [[self infoDictionary] objectForKey:@"CFBundleIdentifier"];
}

-(NSString *)developmentLocalization {
   NSUnimplementedMethod();
   return 0;
}
-(NSArray *)executableArchitectures {
   NSUnimplementedMethod();
   return 0;
}

-(NSArray *)localizations {
   NSUnimplementedMethod();
   return 0;
}
-(NSArray *)preferredLocalizations {
   NSUnimplementedMethod();
   return 0;
}
-(NSString *)privateFrameworksPath {
   NSUnimplementedMethod();
   return 0;
}
-(NSString *)sharedFrameworksPath {
   NSUnimplementedMethod();
   return 0;
}
-(NSString *)sharedSupportPath {
   NSUnimplementedMethod();
   return 0;
}

-(NSString *)pathForAuxiliaryExecutable:(NSString *)executable {
   NSFileManager *fm=[NSFileManager defaultManager];
   NSString *path=[[self executablePath] stringByDeletingLastPathComponent];
   NSString *pathexe;

   path=[path stringByAppendingPathComponent:executable];
   if ([fm isExecutableFileAtPath:path])
      return path;

   // Try to enhance compatibility with Unix-ish code.
   if (![NSPlatformExecutableFileExtension isEqualToString:@""]) {
      path=[path stringByAppendingPathExtension:NSPlatformExecutableFileExtension];
      if ([fm isExecutableFileAtPath:path])
         return path;
   }

   return nil;
}

-(Class)principalClass {
   NSString *name=[[self infoDictionary] objectForKey:@"NSPrincipalClass"];

   [self load];

   return (name==nil)?Nil:NSClassFromString(name);
}

-(Class)classNamed:(NSString *)className {
   [self load];

   return NSClassFromString(className);
}

-(BOOL)isLoaded {
   NSUnimplementedMethod();
   return 0;
}
-(BOOL)preflightAndReturnError:(NSError **)error {
   NSUnimplementedMethod();
   return 0;
}
-(BOOL)loadAndReturnError:(NSError **)error {
   NSUnimplementedMethod();
   return 0;
}

/*
  Frameworks are organized as:
    Executables/<shared object, e.g. dll or so>
    Frameworks/MyFramework.framework/
  Bundles are organized like OS X with Contents/<operating system>
 */
 
-(NSString *)_findExecutable {
   NSString *type=[_path pathExtension];
   NSString *name=[[self infoDictionary] objectForKey:@"CFBundleExecutable"];
   NSString *checkDir;
   NSArray  *contents;
   NSInteger       i,count;

   if(name==nil) 
    name=[[_path lastPathComponent] stringByDeletingPathExtension];

   if([type isEqualToString:@"framework"])
    checkDir=[[[_path stringByDeletingLastPathComponent] stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Executables"];
   else
    checkDir=[[_path stringByAppendingPathComponent:@"Contents"] stringByAppendingPathComponent:NSPlatformExecutableDirectory];
    
   contents=[[NSFileManager defaultManager] directoryContentsAtPath:checkDir];
   count=[contents count];

// Need to check for <name>*  versioning
   for(i=0;i<count;i++){
    NSString *check=[contents objectAtIndex:i];

    if([check hasPrefix:name]){
     NSString *ext=[check pathExtension];

     if([ext isEqualToString:NSPlatformLoadableObjectFileExtension] ||
        [ext isEqualToString:NSPlatformExecutableFileExtension])
      return [checkDir stringByAppendingPathComponent:check];
    }
   }

   return [[_path stringByAppendingPathComponent:name] stringByAppendingPathExtension:NSPlatformLoadableObjectFileExtension];
}

-(NSString *)executablePath {
    if(!_executablePath)
    {
        _executablePath=[[self _findExecutable] retain];
    }
    return _executablePath;
}

-(BOOL)load {
    // if(!_isLoaded){
    //     NSString *load=[self executablePath];
        
   //  if(NSLoadModule([load fileSystemRepresentation]) == NULL){
   //   NSLog(@"load of %@ FAILED",load);
   //   return NO;
   //  }
   // }
    // _isLoaded=YES;
   // return YES;
   return NO;
}

-(BOOL)unload {
   NSUnimplementedMethod();
   return 0;
}

-(NSArray *)lookInDirectories {
   if (_lookInDirectories == nil)
   {
    // FIXME: This should be based on language preference order, and tested for presence in bundle before adding
    
      NSString *language = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
      if ([language isEqualToString:@"English"])
         _lookInDirectories = [[NSArray arrayWithObjects:@"English.lproj", @"", nil] retain];
      else
         _lookInDirectories = [[NSArray arrayWithObjects:[language stringByAppendingPathExtension:@"lproj"], @"English.lproj", @"", nil] retain];
   }
   return _lookInDirectories;
}

-(NSString *)pathForResourceFile:(NSString *)file inDirectory:(NSString *)directory {
   NSArray  *lookIn=[self lookInDirectories];
   NSInteger       i,count=[lookIn count];

   for(i=0;i<count;i++){
    NSString *path=[[directory stringByAppendingPathComponent:[lookIn objectAtIndex:i]] stringByAppendingPathComponent:file];

    if([[NSFileManager defaultManager] fileExistsAtPath:path])
     return path;
   }
   
   return nil;
}

-(NSString *)pathForResource:(NSString *)name ofType:(NSString *)type inDirectory:(NSString *)directory {
   NSString *file,*path;

   file=[[name stringByAppendingFormat:@"-%@",NSPlatformResourceNameSuffix] stringByAppendingPathExtension:type];
   if((path=[self pathForResourceFile:file inDirectory:directory])!=nil)
    return path;

   file=[name stringByAppendingPathExtension:type];
   path=[self pathForResourceFile:file inDirectory:directory];

   return path;
}

-(NSString *)pathForResource:(NSString *)name ofType:(NSString *)type inDirectory:(NSString *)path forLocalization:(NSString *)localization {
   //TODO localization
   return [self pathForResource:name ofType:type inDirectory:path];
}

-(NSString *)pathForResource:(NSString *)name ofType:(NSString *)type {
   return [self pathForResource:name ofType:type inDirectory:_resourcePath];
}

-(NSArray *)pathsForResourcesOfType:(NSString *)type inDirectory:(NSString *)path {
    id fullPath=[[self resourcePath] stringByAppendingPathComponent:path];
    id allFiles=[[NSFileManager defaultManager] directoryContentsAtPath:fullPath];
    int i;
    id ret=[NSMutableArray array];
    for(i=0; i<[allFiles count]; i++)
    {
        id filename=[fullPath stringByAppendingPathComponent:[allFiles objectAtIndex:i]];
        if(type==nil || [[filename pathExtension] isEqualToString:type])
            [ret addObject:filename];
    }
   return ret;
}

-(NSArray *)pathsForResourcesOfType:(NSString *)type inDirectory:(NSString *)path forLocalization:(NSString *)localization {
   //TODO localization
   return [self pathsForResourcesOfType:type inDirectory:path];
}

-(NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)table {
   NSString     *result;
   NSString     *path;
   NSString     *contents=nil;
   NSDictionary *dictionary=nil;

   if([table length]==0)
    table=@"Localizable";

   if((path=[self pathForResource:table ofType:@"strings"])!=nil)
    if((contents=[NSString stringWithContentsOfFile:path])!=nil){
     NS_DURING
      dictionary=[contents propertyListFromStringsFileFormat];
     NS_HANDLER
      dictionary=nil;
     NS_ENDHANDLER
    }

   if((result=[dictionary objectForKey:key])==nil)
    result=(value!=nil)?value:key;

   return result;
}

-(NSString *)description {
   return [NSString stringWithFormat:@"<%@[0x%lx] path: %@ resourcePath: %@ isLoaded: %@>", isa, self, _path, _resourcePath, (_isLoaded ? @"YES" : @"NO")];
}

@end

NSString *NSLocalizedString(NSString *key,NSString *comment) {
   return [[NSBundle mainBundle] localizedStringForKey:key value:nil table:nil];
}

NSString *NSLocalizedStringFromTable(NSString *key,NSString *table,NSString *comment) {
   return [[NSBundle mainBundle] localizedStringForKey:key value:nil table:table];
}

NSString *NSLocalizedStringFromTableInBundle(NSString *key,NSString *table,NSBundle *bundle,NSString *comment) {
   return [bundle localizedStringForKey:key value:nil table:table];
}
