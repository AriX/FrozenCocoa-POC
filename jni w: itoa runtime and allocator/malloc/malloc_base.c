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
#include <string.h>

/* Basic implementation */

malloc_zone_t* malloc_create_zone(size_t start_size, unsigned int flags) {
    return NULL;
}

malloc_zone_t* malloc_zone_from_ptr(const void* ptr) {
    return malloc_default_zone();
}

/* Forwarders */

void malloc_destroy_zone(malloc_zone_t* zone) {
    zone->destroy(zone);
}

void* malloc_zone_malloc(malloc_zone_t* zone, size_t size) {
    return zone->malloc(zone, size);
}

void* malloc_zone_calloc(malloc_zone_t* zone, size_t num, size_t size) {
    return zone->calloc(zone, num, size);
}

void* malloc_zone_valloc(malloc_zone_t* zone, size_t size) {
    return zone->valloc(zone, size);
}

void* malloc_zone_realloc(malloc_zone_t* zone, void* ptr, size_t size) {
    return zone->realloc(zone, ptr, size);
}

void* malloc_zone_memalign(malloc_zone_t* zone, size_t align, size_t size) {
    if (zone->version < MALLOC_ZONE_VERSION_MEMALIGN) {
        return NULL;
    }
    return zone->memalign(zone, align, size);
}

void malloc_zone_free(malloc_zone_t* zone, void* ptr) {
    zone->free(zone, ptr);
}

void malloc_set_zone_name(malloc_zone_t* zone, const char* name) {
    /* noop */
}

const char* malloc_get_zone_name(malloc_zone_t* zone) {
    return zone->zone_name;
}
