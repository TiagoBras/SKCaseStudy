//  Copyright © 2018 Tiago Bras. All rights reserved.
#include "internet_testing.h"
#include "linked_list.h"
#include <pthread.h>
#include <unistd.h>
#include <stdlib.h>
#include <time.h>
#include <stdbool.h>

typedef struct {
    void *classPtr;
    Callback callback;
    PartialResultCallback partialCallback;
    CTestConfiguration config;
    bool shouldCancel;
} ThreadData;

static LinkedList threadDataList;
static pthread_mutex_t threadDataListMutex = PTHREAD_MUTEX_INITIALIZER;

static Node* find_node(LinkedList *list, void *classPtr);

static int random_int(int min, int max);
static double random_double(double min, double max);
static double simulate_test(CTestConfiguration config, ThreadData *threadData);
static double avg(double values[], size_t size);
static void *RunTest(void *threadData);

// MARK:- Public Interface
void run_test(CTestConfiguration config, void *classPtr, Callback callback, PartialResultCallback partialCallback) {
    ThreadData *p = NULL;
    pthread_t pthreadId;
    
    if ((p = malloc(sizeof(ThreadData))) == NULL) {
        if (p->callback != NULL) {
            return callback(classPtr, -1, CTE_OutOfMemory);
        }
    }
    
    p->classPtr = classPtr;
    p->callback = callback;
    p->partialCallback = partialCallback;
    p->config = config;
    p->shouldCancel = false;
    
    if(pthread_create(&pthreadId, NULL, &RunTest, p) != 0) {
        free(p);
        
        callback(classPtr, -1, CTE_CouldNotCreateThread);
    }
    
    pthread_mutex_lock(&threadDataListMutex);
    add_node_tail(&threadDataList, p);
    pthread_mutex_unlock(&threadDataListMutex);
}

void cancel_test(void *classPtr) {
    pthread_mutex_lock(&threadDataListMutex);
    
    Node *p = NULL;
    
    if ((p = find_node(&threadDataList, classPtr)) == NULL) {
        printf("cancel_test: Could not find node\n");
    } else {
        ((ThreadData *)p->data)->shouldCancel = true;
    }
    
    pthread_mutex_unlock(&threadDataListMutex);
}

// MARK:- Private Interface
static void *RunTest(void *threadData) {
    ThreadData *p = (ThreadData *)threadData;
    
    double result = simulate_test(p->config, p);
    
    p->callback(p->classPtr, result, 0);
    
    pthread_mutex_lock(&threadDataListMutex);
    
    Node *node = find_node(&threadDataList, p->classPtr);
    
    if (node != NULL) {
        remove_node(&threadDataList, node, true);
    }
    
    pthread_mutex_unlock(&threadDataListMutex);
    pthread_exit(NULL);
}

static int random_int(int min, int max) {
    return (rand() % (max - min)) + min;
}

static double random_double(double min, double max) {
    return ((double)rand() / RAND_MAX) * (max - min) + min;
}

static double avg(double values[], size_t size) {
    if (size <= 0) { return 0; }
    
    double total = 0;
    for (int i = 0; i < size; ++i) {
        total += values[i];
    }
    
    return total / size;
}

static double simulate_test(CTestConfiguration config, ThreadData *threadData) {
    // Simulate tests
    srand((unsigned)time(NULL));

    double base = 0;
    double variation = 0;
    int testDuration = 0;
    int updateCount = 1;
    
    // Setup the test simulation parameters
    switch (config.testType) {
        case CTT_Download:
        case CTT_Upload:
            base = random_double(10, 100);
            variation = random_double(10, 30);
            testDuration = random_int(6, 12);
            updateCount = (int)(testDuration / 0.5);
            
            if (updateCount < 0) {
                updateCount = 1;
            }
            break;
        case CTT_Latency:
            base = random_double(10, 100);
            variation = random_double(10, 200);
            testDuration = random_int(4, 10);
            break;
        case CTT_Jitter:
            base = random_double(1, 5);
            variation = random_double(1, 5);
            testDuration = random_int(5, 10);
            break;
        case CTT_PacketLoss:
            base = random_double(0, 1);
            variation = random_double(0, 0);
            testDuration = random_int(3, 7);
            break;
        case CTT_Youtube:
            // SD: 1.5 Mbps, HD: 5.0 Mbps, FHD: 8.0 Mbps, UHD: 12.0 Mbps
            base = random_double(0, 1);
            variation = random_double(0, 0);
            testDuration = random_int(3, 7);
            break;
        case CTT_WebBrowsing:
            base = random_double(100, 500);
            variation = random_double(0, 100);
            testDuration = random_int(3, 6);
    }
    
    double *values = NULL;
    
    if ((values = malloc(sizeof(double) * updateCount)) == NULL) {
        threadData->callback(threadData->classPtr, -1, CTE_OutOfMemory);
        free(threadData);
        pthread_exit(NULL);
    }
    
    const useconds_t iterationDuration = ((float)testDuration / updateCount) * 1000000;
    
    double min, max, average = 0;
    for (int i = 0; i < updateCount; ++i) {
        if (threadData->shouldCancel) {
            free(values);
            
            pthread_mutex_lock(&threadDataListMutex);
            
            threadData->callback(threadData->classPtr, -1, CTE_ThreadCancelled);
            
            Node *node = find_node(&threadDataList, threadData->classPtr);
            
            if (node != NULL) {
                remove_node(&threadDataList, node, true);
            }
            
            pthread_mutex_unlock(&threadDataListMutex);
            
            printf("Thread %u cancelled\n", (short)pthread_self());
            pthread_exit(NULL);
        }
        
        usleep(iterationDuration);
        
        min = base - variation;
        min = min < 0 ? 0 : min;
        max = base + variation;
        max = max < 0 ? 0 : max;
        
        values[i] = random_double(min, max);
        
        average = avg(values, i+1);
        
        if (threadData->partialCallback != NULL) {
            threadData->partialCallback(threadData->classPtr, average);
        }
    }
    
    free(values);
    
    return average;
}

static Node* find_node(LinkedList *list, void *classPtr) {
    Node *p = list->head;
    
    while (p != NULL) {
        ThreadData *data = (ThreadData *)p->data;
        
        if (data->classPtr == classPtr) {
            return p;
        }
        
        p = p->next;
    }
    
    return NULL;
}
