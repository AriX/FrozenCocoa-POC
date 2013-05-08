Frozen Cocoa proof-of-concept from PennApps. See [FrozenCocoa.com](http://frozencocoa.com). The magic is in the 'jni' folder.

Unfortunately, I did not use any code tracking during the event, so it is hard to see which parts of this I hacked together and which parts I ripped from other projects. At some point I'll put together a diff and retroactively make commits!

Compile with the CrystaX NDK.

####Android/Objective-C project notes:

http://www.crystax.net/en/android/ndk/7
This is the Android NDK I ended up using with (GCC) Objective-C support built-in. I think I built a custom version but you should just be able to use the precompiled one. Maybe that's what I did too; I can't remember now!

https://github.com/DmitrySkiba/itoa
This is a stalled project to do basically what Frozen Cocoa aims to do. This guy has his own build system wrapping Android NDK that doesn't seem to be compatible with modern versions of the NDK. I found some of his code helpful, though, especially CleanCF and Itoa-Foundation. He claims to have ported some amount of UIKit (wrapping Android's classes), but hasn't provided any of the code. He wrote a library extending the JNI bridge, which is interesting; Java/Objective-C integration is very interesting, and there may be some cool ways to bridge here, considering the dynamic nature of both languages (especially Objective-C). His Objective-C runtime might be a good resource too; could be helpful in porting Apple's "objc4" runtime to Android.

https://code.google.com/p/cocotron/source/browse/
This is the Google project page for Cocotron, which provides reimplementations of a lot of Apple's frameworks, including Foundation, CoreFoundation (as a wrapper around Foundation), QuartzCore, CoreGraphics, CoreData, and the Objective-C runtime. (Frozen Cocoa's Foundation is based on this one)
I really like Cocotron and think it should be very helpful.

http://opensource.apple.com/source/objc4/objc4-532.2/
http://opensource.apple.com/source/CF/CF-744.12/
These are the latest open source versions of the Objective-C runtime and CoreFoundation, respectively.

https://github.com/apportableinc/Foundation
This is Apportable's Foundation, which is mostly based on GNUStep. Despite its README, it doesn't actually compile because it depends on stuff they wrote that's not open source.

I'd recommend playing around with the Objective-C NDK and getting a simple Objective-C example set up (you can subclass Object instead of NSObject; Object is included in the runtime). Then you might also want to play around with clang, which is apparently included in the latest Android NDK and actually has support for Objective-C built-in (but no Objective-C runtime - porting Apple's is a good idea!)

Also I'll note that getting this stuff running is pretty hard. It may require a lot of time hacking away at the Objective-C runtime and/or reading Cocotron/GNUStep code.