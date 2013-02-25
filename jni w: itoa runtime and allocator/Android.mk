# Copyright (C) 2009 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE    := hello-jni
LOCAL_SRC_FILES := hello-jni.m

LOCAL_SRC_FILES += CoreFoundation/AppServices.subproj/CFUserNotification.c CoreFoundation/Base.subproj/CFBase.c CoreFoundation/Base.subproj/CFAllocator.c CoreFoundation/Base.subproj/CFFileUtilities.c CoreFoundation/Base.subproj/CFPlatform.c CoreFoundation/Base.subproj/CFRuntime.c CoreFoundation/Base.subproj/CFSortFunctions.c CoreFoundation/Base.subproj/CFUtilities.c CoreFoundation/Base.subproj/CFUUID.c CoreFoundation/Base.subproj/uuid.c CoreFoundation/Collections.subproj/CFArray.c CoreFoundation/Collections.subproj/CFBag.c CoreFoundation/Collections.subproj/CFBinaryHeap.c CoreFoundation/Collections.subproj/CFBitVector.c CoreFoundation/Collections.subproj/CFData.c CoreFoundation/Collections.subproj/CFDictionary.c CoreFoundation/Collections.subproj/CFSet.c CoreFoundation/Collections.subproj/CFStorage.c CoreFoundation/Collections.subproj/CFTree.c CoreFoundation/NumberDate.subproj/CFDate.c CoreFoundation/NumberDate.subproj/CFNumber.c CoreFoundation/NumberDate.subproj/CFTimeZone.c CoreFoundation/Parsing.subproj/CFBinaryPList.c CoreFoundation/Parsing.subproj/CFPropertyList.c CoreFoundation/Parsing.subproj/CFXMLInputStream.c CoreFoundation/Parsing.subproj/CFXMLNode.c CoreFoundation/Parsing.subproj/CFXMLParser.c CoreFoundation/Parsing.subproj/CFXMLTree.c CoreFoundation/PlugIn.subproj/CFBundle.c CoreFoundation/PlugIn.subproj/CFBundle_Resources.c CoreFoundation/PlugIn.subproj/CFPlugIn.c CoreFoundation/PlugIn.subproj/CFPlugIn_Factory.c CoreFoundation/PlugIn.subproj/CFPlugIn_Instance.c CoreFoundation/PlugIn.subproj/CFPlugIn_PlugIn.c CoreFoundation/String.subproj/CFCharacterSet.c CoreFoundation/String.subproj/CFString.c CoreFoundation/String.subproj/CFStringEncodings.c CoreFoundation/String.subproj/CFStringScanner.c CoreFoundation/String.subproj/CFStringUtilities.c CoreFoundation/StringEncodings.subproj/CFBuiltinConverters.c CoreFoundation/StringEncodings.subproj/CFStringEncodingConverter.c CoreFoundation/StringEncodings.subproj/CFUniChar.c CoreFoundation/StringEncodings.subproj/CFUnicodeDecomposition.c CoreFoundation/StringEncodings.subproj/CFUnicodePrecomposition.c CoreFoundation/URL.subproj/CFURL.c CoreFoundation/URL.subproj/CFURLAccess.c CoreFoundation/version.c

LOCAL_SRC_FILES += \
    CoreFoundation/Itoa.subproj/CFLog.c \
    CoreFoundation/Itoa.subproj/CFPlatformLinux.c \

LOCAL_SRC_FILES += \
    Foundation/NSObject.m \
    Foundation/NSZone.m \
    Foundation/NSObjCRuntime.m \
    Foundation/NSException.m \
    Foundation/NSNull.m \
    Foundation/NSCFType.m \
    Foundation/NSData.m \
    Foundation/NSMutableData.m \
    Foundation/NSCFData.m \
    Foundation/NSCFMutableData.m \
    Foundation/NSCFString.m \
    Foundation/NSCFMutableString.m \
    Foundation/NSString.m \
    Foundation/NSMutableString.m \
    Foundation/NSInternal.m \
    Foundation/NSRange.m \
    Foundation/NSCF.m \
    \
    \
    Foundation/NSAutoReleasePool.m \
    Foundation/NSMemoryFunctions.m \
    \
    Foundation/NSHTTPCookie.m \
    Foundation/NSHTTPCookieStorage.m \
    Foundation/NSCoder.m \
    Foundation/NSDecimal.m \
    Foundation/NSDecimalNumber.m \
    Foundation/NSMapTable.m \
    Foundation/NSLocale.m \
    Foundation/NSFormatter.m \
    Foundation/NSByteOrder.m \
    Foundation/NSError.m \
    Foundation/NSSortDescriptor.m \
    Foundation/NSProcessInfo.m \
    \
    Foundation/valuetransformer/NSValueTransformer.m \
    Foundation/valuetransformer/NSValueTransformer_IsNil.m \
    Foundation/valuetransformer/NSValueTransformer_IsNotNil.m \
    Foundation/valuetransformer/NSValueTransformer_NegateBoolean.m \
    Foundation/valuetransformer/NSValueTransformer_UnarchiveFromData.m \
    \
    Foundation/NSScanner.m \
    Foundation/scanner/NSScanner_concrete.m \
    \
    Foundation/NSDictionary.m \
    Foundation/dictionary/NSDictionary_mapTable.m \
    Foundation/dictionary/NSMutableDictionary_mapTable.m \
    \
    Foundation/notification/NSNotification.m \
    Foundation/notification/NSNotificationQueue.m \
    Foundation/notification/NSNotification_concrete.m \
    Foundation/notification/NSNotificationObserver.m \
    Foundation/notification/NSObjectToObservers.m \
    Foundation/notification/NSNotificationAndModes.m \
    \
    Foundation/NSEnumerator.m \
    Foundation/enumerator/NSEnumerator_array.m \
    Foundation/enumerator/NSEnumerator_arrayReverse.m \
    Foundation/enumerator/NSEnumerator_dictionaryKeys.m \
    Foundation/enumerator/NSEnumerator_dictionaryObjects.m \
    Foundation/enumerator/NSEnumerator_set.m \
    \
    Foundation/NSSet.m \
    Foundation/set/NSSet_concrete.m \
    Foundation/set/NSSet_placeholder.m \
    Foundation/set/NSMutableSet_concrete.m \
    \
    Foundation/NSArray.m \
    Foundation/array/NSArray_concrete.m \
    Foundation/array/NSArray_placeholder.m \
    Foundation/array/NSMutableArray_concrete.m \
    \
    Foundation/NSValue.m \
    Foundation/value/NSValue_concrete.m \
    Foundation/value/NSValue_nonRetainedObject.m \
    Foundation/value/NSValue_placeholder.m \
    Foundation/value/NSValue_pointer.m \
    \
    Foundation/NSNumberFormatter.m \
    Foundation/number/NSNumber_BOOL.m \
    Foundation/number/NSNumber_BOOL_const.m \
    Foundation/number/NSNumber_char.m \
    Foundation/number/NSNumber_double.m \
    Foundation/number/NSNumber_double_const.m \
    Foundation/number/NSNumber_float.m \
    Foundation/number/NSNumber_int.m \
    Foundation/number/NSNumber_long.m \
    Foundation/number/NSNumber_longLong.m \
    Foundation/number/NSNumber_placeholder.m \
    Foundation/number/NSNumber_short.m \
    Foundation/number/NSNumber_unsignedChar.m \
    Foundation/number/NSNumber_unsignedInt.m \
    Foundation/number/NSNumber_unsignedLong.m \
    Foundation/number/NSNumber_unsignedLongLong.m \
    Foundation/number/NSNumber_unsignedShort.m \
    \
    Foundation/NSRaise.m \
    Foundation/NSPlatform.m \
    Foundation/NSMethodSignature.m \
    \
    Foundation/operation/NSAtomicList.m \
    Foundation/operation/NSLatchTrigger.m \
    Foundation/operation/NSOperation.m \
    Foundation/operation/NSOperationQueue.m \
    \
    Foundation/attributedstring/NSAttributedString.m \
    Foundation/attributedstring/NSAttributedString_manyAttributes.m \
    Foundation/attributedstring/NSAttributedString_nilAttributes.m \
    Foundation/attributedstring/NSAttributedString_oneAttribute.m \
    Foundation/attributedstring/NSAttributedString_placeholder.m \
    Foundation/attributedstring/NSMutableAttributedString.m \
    Foundation/attributedstring/NSMutableAttributedString_concrete.m \
    Foundation/attributedstring/NSMutableString_proxyToMutableAttributedString.m \
    Foundation/attributedstring/NSRangeEntries.m \
    \
    Foundation/NSUserDefaults.m \
    Foundation/userdefaults/NSPersistantDomain.m \
    \
    Foundation/NSDate.m \
    Foundation/NSCalendar.m \
    Foundation/NSDateFormatter.m \
    Foundation/NSCalendarDate.m \
    Foundation/date/NSDate_timeInterval.m \
    \
    Foundation/NSTimeZone.m \
    Foundation/timezone/NSTimeZone_absolute.m \
    Foundation/timezone/NSTimeZone_concrete.m \
    Foundation/timezone/NSTimeZoneTransition.m \
    Foundation/timezone/NSTimeZoneType.m \
    \
    Foundation/NSTimer.m \
    Foundation/timer/NSTimer_concrete.m \
    Foundation/timer/NSTimer_invocation.m \
    Foundation/timer/NSTimer_targetAction.m \
    \
    Foundation/NSPropertyList.m \
    Foundation/propertylist/NSOldXMLAttribute.m \
    Foundation/propertylist/NSOldXMLDocument.m \
    Foundation/propertylist/NSOldXMLElement.m \
    Foundation/propertylist/NSOldXMLReader.m \
    Foundation/propertylist/NSPropertyListReader.m \
    Foundation/propertylist/NSPropertyListReader_binary1.m \
    Foundation/propertylist/NSPropertyListReader_vintage.m \
    Foundation/propertylist/NSPropertyListReader_xml1.m \
    Foundation/propertylist/NSPropertyListWriter_vintage.m \
    Foundation/propertylist/NSPropertyListWriter_xml1.m \
    \
    Foundation/NSCharacterSet.m \
    Foundation/characterset/NSCharacterSet_bitmap.m \
    Foundation/characterset/NSCharacterSet_range.m \
    Foundation/characterset/NSCharacterSet_rangeInverted.m \
    Foundation/characterset/NSCharacterSet_string.m \
    Foundation/characterset/NSMutableCharacterSet_bitmap.m \
    \
    Foundation/NSPredicate.m \
    Foundation/NSComparisonPredicate.m \
    Foundation/NSCompoundPredicate.m \
    Foundation/NSExpression.m \
    Foundation/predicate/NSExpression_array.m \
    Foundation/predicate/NSExpression_assignment.m \
    Foundation/predicate/NSExpression_constant.m \
    Foundation/predicate/NSExpression_function.m \
    Foundation/predicate/NSExpression_keypath.m \
    Foundation/predicate/NSExpression_operator.m \
    Foundation/predicate/NSExpression_self.m \
    Foundation/predicate/NSExpression_variable.m \
    Foundation/predicate/NSPredicate_BOOL.m \
    \
    Foundation/NSThread.m \
    Foundation/NSSynchronization.m \
    Foundation/NSLock.m \
    Foundation/NSDelayedPerform.m \
    Foundation/NSInputSource.m \
    Foundation/NSInputSourceSet.m \
    Foundation/NSOrderedPerform.m \
    Foundation/NSRunLoop.m \
    Foundation/NSRunLoopState.m \
    Foundation/NSInlineSetTable.m \
    Foundation/NSSocket.m \
    Foundation/NSKeyedArchiver.m \
    Foundation/NSHashTable.m \
    \
    Foundation/NSURL.m \
    \
    Foundation/NSConcreteDirectoryEnumerator.m \
    Foundation/NSFileManager.m \
    Foundation/NSPathUtilities.m \
    Foundation/NSBundle.m \
    Foundation/NSIndexPath.m \
    Foundation/NSIndexSet.m \
    Foundation/NSHost.m \

LOCAL_SRC_FILES += \
    libkern/android/OSAtomic.c \
    libkern/android/android_atomic.S \
    libkern/android/OSSpinLock.c \
    malloc/malloc_base.c \
    malloc/android/malloc_impl.c

LOCAL_C_INCLUDES := $(LOCAL_PATH)/../jni $(LOCAL_PATH)/../jni/CoreFoundation $(LOCAL_PATH)/../jni/CoreFoundation/CoreFoundation
MY_VERSION = 299.33
LOCAL_CFLAGS = -lcorefoundationlite -D__LINUX__=1 -DCOMPATIBLE_GCC4=1 -D__LITTLE_ENDIAN__=1 -DCF_BUILDING_CF=1 -DCF_ENABLED=1 -g -fno-common -pipe -DVERSION=$(MY_VERSION) -DCOCOTRON_DISALLOW_FORWARDING -fconstant-string-class=NSConstantString

include $(BUILD_SHARED_LIBRARY)
