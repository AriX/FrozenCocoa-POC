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

#include <malloc/malloc.h>
#include <malloc.h>
#include <windows.h>

/* Helpers */

static size_t getpagesize() {
    static size_t pageSize = 0;
    if (!pageSize) {
        SYSTEM_INFO info = {0};
        GetSystemInfo(&info);
        pageSize = info.dwPageSize;
    }
    return pageSize;
}

/* Default zone */

static size_t zone_size(malloc_zone_t* zone, const void* ptr) {
    return _msize((void*)ptr);
}

static void* zone_malloc(malloc_zone_t* zone, size_t size) {
    return malloc(size);
}

static void* zone_calloc(malloc_zone_t* zone, size_t num, size_t size) {
    return calloc(num, size);
}

static void* zone_valloc(malloc_zone_t* zone, size_t size) {
    return _aligned_malloc(getpagesize(), size);
}

static void* zone_realloc(malloc_zone_t* zone, void* ptr, size_t size) {
    return realloc(ptr, size);
}

static void* zone_memalign(malloc_zone_t* zone, size_t align, size_t size) {
    return _aligned_malloc(align, size);
}

static void zone_free(malloc_zone_t* zone, void* ptr) {
    free(ptr);
}

static void zone_destroy(malloc_zone_t* zone) {
    /*noop*/
}

static malloc_zone_t default_zone = {
    NULL, 0, 0,
    zone_size,
    zone_malloc,
    zone_calloc,
    zone_valloc,
    zone_free,
    zone_realloc,
    zone_destroy,
    "default",
    MALLOC_ZONE_VERSION_MEMALIGN,
    zone_memalign
};

malloc_zone_t* malloc_default_zone(void) {
    return &default_zone;
}

/* Other functions */

size_t malloc_size(const void* ptr) {
    return _msize((void*)ptr);
}

size_t malloc_good_size(size_t size) {
    return size;
}
