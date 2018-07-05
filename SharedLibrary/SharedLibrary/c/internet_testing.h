//  Copyright © 2018 Tiago Bras. All rights reserved.
#ifndef internet_testing_h
#define internet_testing_h

#include <stdio.h>

typedef enum {
    CTT_Download    = (0x1 << 1),
    CTT_Upload      = (0x1 << 2),
    CTT_Latency     = (0x1 << 3),
    CTT_Jitter      = (0x1 << 4),
    CTT_PacketLoss  = (0x1 << 5),
    CTT_Youtube     = (0x1 << 6),
    CTT_WebBrowsing = (0x1 << 7),
} CTestType;

typedef enum {
    CTE_OutOfMemory             = (0x1 << 1),
    CTE_CouldNotCreateThread    = (0x1 << 2),
    CTE_ThreadCancelled         = (0x1 << 3),
} CTestError;

typedef struct {
    CTestType testType;
} CTestConfiguration;

typedef struct {
    double downloadSpeed;
    double uploadSpeed;
    double latency;
    double jitter;
    double packetLoss;
    double youtube;
    double webBrowsing;
} CTestResults;

typedef void (*PartialResultCallback)(void *, double);

// In case of error, CTestError will be different than 0
typedef void (*Callback)(void *, double, CTestError);

void run_test(CTestConfiguration config, void *classPtr, Callback callback, PartialResultCallback partialCallback);
void cancel_test(void *classPtr);

#endif /* internet_testing_h */
