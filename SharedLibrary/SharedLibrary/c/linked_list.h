//  Copyright © 2018 Tiago Bras. All rights reserved.
#ifndef linked_list_h
#define linked_list_h

#include <stdio.h>
#include <stdbool.h>

typedef struct Node {
    struct Node *prev;
    struct Node *next;
    void *data;
} Node;

typedef struct {
    Node *head;
    void (*errorCallback)(int, char[]);
} LinkedList;

void add_node_tail(LinkedList *list, void *data);
void remove_node(LinkedList *list, Node *node, bool freeData);

#endif /* linked_list_h */
