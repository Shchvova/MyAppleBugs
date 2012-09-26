#ifndef SOUNDDECODER_INTERNAL_H
#define SOUNDDECODER_INTERNAL_H

#include <stdio.h>
#include "al.h" /* OpenAL */
#include "ALmixer_RWops.h"

#ifdef __cplusplus
extern "C" {
#endif
	

typedef struct SoundDecoder_DecoderFunctions
{
    const SoundDecoder_DecoderInfo info;
    int (*init)(void);
    void (*quit)(void);
    int (*open)(SoundDecoder_Sample *sample, const char *ext);
    void (*close)(SoundDecoder_Sample *sample);
    size_t (*read)(SoundDecoder_Sample *sample);
    int (*rewind)(SoundDecoder_Sample *sample);
    int (*seek)(SoundDecoder_Sample *sample, size_t ms);
} SoundDecoder_DecoderFunctions;

typedef struct SoundDecoder_DecoderFunctions Sound_DecoderFunctions;



typedef struct SoundDecoder_SampleInternal
{
    SoundDecoder_Sample *next;
    SoundDecoder_Sample *prev;
    ALmixer_RWops *rw;
    const SoundDecoder_DecoderFunctions *funcs;
    void *buffer;
    size_t buffer_size;
    void *decoder_private;
    ptrdiff_t total_time;
} SoundDecoder_SampleInternal;

typedef struct SoundDecoder_SampleInternal Sound_SampleInternal;


#define BAIL_MACRO(e, r) { SoundDecoder_SetError(e); return r; }
#define BAIL_IF_MACRO(c, e, r) if (c) { SoundDecoder_SetError(e); return r; }
#define ERR_OUT_OF_MEMORY "Out of memory"
#define ERR_NOT_INITIALIZED "SoundDecoder not initialized"
#define ERR_UNSUPPORTED_FORMAT "Unsupported codec"
#define ERR_NULL_SAMPLE "Sound sample is NULL"
#define ERR_PREVIOUS_SAMPLE_ERROR "Cannot operate on sample due to previous error"
#define ERR_ALREADY_AT_EOF_ERROR "Cannot operate on sample because already at EOF"

#ifdef ANDROID_NDK

#include <android/log.h>
#define SNDDBG(x) __android_log_print(ANDROID_LOG_INFO, "Corona", x);

#else

#if (defined DEBUG_CHATTER)
#define SNDDBG(x) printf x
#else
#define SNDDBG(x)
#endif

#endif

void SoundDecoder_SetError(const char* err_str, ...);
int SoundDecoder_strcasecmp(const char *x, const char *y);
#define __Sound_strcasecmp SoundDecoder_strcasecmp

/* Ends C function definitions when using C++ */
#ifdef __cplusplus
}
#endif


#endif

