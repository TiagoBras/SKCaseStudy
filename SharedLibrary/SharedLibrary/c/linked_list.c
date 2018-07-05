//  Copyright © 2018 Tiago Bras. All rights reserved.
#include "linked_list.h"
#include <stdlib.h>

static int OUT_OF_MEMORY_CODE = -1;
static char OUT_OF_MEMORY[] = "Out Of Memory";

void add_node_tail(LinkedList *list, void *data) {
    Node *newNode = NULL;
    
    if ((newNode = malloc(sizeof(Node))) == NULL) {
        if (list->errorCallback != NULL) {
            list->errorCallback(OUT_OF_MEMORY_CODE, OUT_OF_MEMORY);
        }
        
        return;
    }
    
    newNode->data = data;
    newNode->next = NULL;
    
    if (list->head == NULL) {
        newNode->prev = NULL;
        list->head = newNode;
    } else {
        Node *p = list->head;
        
        while (p->next != NULL) {
            p = p->next;
        }
        
        newNode->prev = p;
        p->next = newNode;
    }
}

void remove_node(LinkedList *list, Node *node, bool freeData) {
    if (freeData) {
        free(node->data);
    }
    
    // If prev node is NULL it means it's the head of the list
    if (node->prev == NULL) {
        list->head = node->next;
    } else {
        node->prev->next = node->next;
    }
    
    if (node->next != NULL) {
        node->next->prev = node->prev;
    }
}
