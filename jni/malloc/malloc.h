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

#ifndef _MALLOC_ZONE_INCLUDED_
#define _MALLOC_ZONE_INCLUDED_

#include <stddef.h>
#include <sys/cdefs.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#define MALLOC_ZONE_VERSION_DEFAULT 0
#define MALLOC_ZONE_VERSION_MEMALIGN 1

typedef struct _malloc_zone_t malloc_zone_t;

// This structure must be synchronized with __CFAllocator.
struct _malloc_zone_t {
    void* reserved1;
    uint32_t reserved2;
    uint32_t reserved3;

    size_t (*size)(malloc_zone_t* zone, const void* ptr);
    void* (*malloc)(malloc_zone_t* zone, size_t size);
    void* (*calloc)(malloc_zone_t* zone, size_t num, size_t size);
    void* (*valloc)(malloc_zone_t* zone, size_t size);
    void (*free)(malloc_zone_t* zone, void* ptr);
    void* (*realloc)(malloc_zone_t* zone, void* ptr, size_t size);
    void (*destroy)(malloc_zone_t* zone);
    const char* zone_name;

    unsigned int version;

    void* (*memalign)(malloc_zone_t* zone, size_t alignment, size_t size);
};

malloc_zone_t* malloc_default_zone(void);

// These two functions are not implemented - 'create' always returns NULL,
//  'destroy' does nothing. They are hard to implemented without modifying
//  standard allocation functions - for example objc runtime allocates memory
//  using malloc_create_zone(), but deletes it via simple free(). Besides, 
//  no one seems to create zones nowdays.
malloc_zone_t* malloc_create_zone(size_t start_size, unsigned int flags);
void malloc_destroy_zone(malloc_zone_t* zone);

void* malloc_zone_malloc(malloc_zone_t* zone, size_t size);
void* malloc_zone_calloc(malloc_zone_t* zone, size_t num, size_t size);
void* malloc_zone_valloc(malloc_zone_t* zone, size_t size);
void* malloc_zone_realloc(malloc_zone_t* zone, void* ptr, size_t size);
void* malloc_zone_memalign(malloc_zone_t* zone, size_t align, size_t size);
void malloc_zone_free(malloc_zone_t* zone, void* ptr);

malloc_zone_t* malloc_zone_from_ptr(const void *ptr);

void malloc_set_zone_name(malloc_zone_t* zone, const char* name);
const char* malloc_get_zone_name(malloc_zone_t* zone);

size_t malloc_size(const void* ptr);
size_t malloc_good_size(size_t size);

#ifdef __cplusplus
} // extern "C"
#endif

#endif /* _MALLOC_ZONE_INCLUDED_ */
