/*
 * Copyright (C) 2011 Dmitry Skiba
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#if !defined(__COREFOUNDATION_CFALLOCATORINTERNAL__)
#define __COREFOUNDATION_CFALLOCATORINTERNAL__ 1

#if defined(__HAS_PRIVATE_EXTERN__)
	#define CF_INTERNAL __private_extern__
#elif defined(__GNUC__)
	#define CF_INTERNAL __attribute__((visibility("hidden")))
#else
	#define CF_INTERNAL
#endif

#if defined(__cplusplus)
extern "C" {
#endif

CF_EXPORT
CFAllocatorRef _CFAllocatorGetAllocator(CFTypeRef cf);

CF_EXPORT
void _CFAllocatorInitialize(void);

// The only valid objects with NULL _cfisa are malloc_zone_t.
CF_INLINE Boolean _CFIsMallocZone(CFTypeRef cf) {
    return CF_BASE(cf)->_isa == NULL && CF_TYPEID(cf) == 0;  
}

#if defined(__cplusplus)
}
#endif

#endif /* !__COREFOUNDATION_CFALLOCATORINTERNAL__ */
