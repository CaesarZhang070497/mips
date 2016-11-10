/***************************************************************************
 * *    Inf2C-CS Coursework 2: Cache Simulation
 * *    
 * *    Boris Grot, Priyank Faldu
 * *
 * *    Deadline: Wed 23 Nov (Week 10) 16:00
***************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <inttypes.h>
#include <math.h>

/* Do not add any more header files */

typedef enum {
    dm, fa
} cache_map_t;
typedef enum {
    fifo, lru, none
} cache_replacement_t;
typedef enum {
    instruction, data
} access_t;

typedef struct {
    uint32_t address;
    access_t accesstype;
} mem_access_t;

typedef struct {
    uint32_t instruction_accesses;
    uint32_t instruction_hits;
    uint32_t data_accesses;
    uint32_t data_hits;
} result_t;

/* Cache Parameters */
uint32_t cache_size = 2048;
uint32_t block_size = 64;
cache_map_t cache_mapping = dm;
cache_replacement_t cache_replacement = none;


/* Reads a memory access from the trace file and returns
 * 1) access type (instruction or data access)
 * 2) memory address
 */
mem_access_t read_transaction(FILE *ptr_file) {
    char buf[1002];
    char *token = NULL;
    char *string = buf;
    mem_access_t access;

    if (fgets(buf, 1000, ptr_file) != NULL) {

        /* Get the access type */
        token = strsep(&string, " \n");
        if (strcmp(token, "I") == 0) {
            access.accesstype = instruction;
        } else if (strcmp(token, "D") == 0) {
            access.accesstype = data;
        } else {
            printf("Unkown access type\n");
            exit(-1);
        }

        /* Get the address */
        token = strsep(&string, " \n");
        access.address = (uint32_t) strtol(token, NULL, 16);

        return access;
    }

    /* If there are no more entries in the file return an address 0 */
    access.address = 0;
    return access;
}

void print_statistics(uint32_t num_blocks, uint32_t bits_offset, uint32_t bits_index, uint32_t bits_tag, result_t r) {
    /* Do Not Modify This Function */
    printf("Num_Blocks:%u\n", num_blocks);
    printf("Bits_BlockOffset:%u\n", bits_offset);
    printf("Bits_Index:%u\n", bits_index);
    printf("Bits_Tag:%u\n", bits_tag);
    if ((r.instruction_accesses == 0) || (r.data_accesses == 0)) {
        /*
         * Just a protection over divide by zero.
         * Ideally, it should never reach here.
         */
        return;
    }
    printf("Total_Accesses:%u\n", r.instruction_accesses + r.data_accesses);
    printf("Total_Hits:%u\n", r.instruction_hits + r.data_hits);
    printf("Total_HitRate:%2.2f%%\n",
           (r.instruction_hits + r.data_hits) / ((float) (r.instruction_accesses + r.data_accesses)) * 100.0);
    printf("Instruction_Accesses:%u\n", r.instruction_accesses);
    printf("Instruction_Hits:%u\n", r.instruction_hits);
    printf("Instruction_HitRate:%2.2f%%\n", r.instruction_hits / ((float) (r.instruction_accesses)) * 100.0);
    printf("Data_Accesses:%u\n", r.data_accesses);
    printf("Data_Hits:%u\n", r.data_hits);
    printf("Data_HitRate:%2.2f%%\n", r.data_hits / ((float) (r.data_accesses)) * 100.0);
}

/*
 * Global variables
 * These variables must be populated before call to print_statistics(...) is made.
 */
uint32_t num_bits_for_block_offset = 0;
uint32_t num_bits_for_index = 0;
uint32_t num_bits_for_tag = 0;
uint32_t num_blocks = 0;
result_t result;

/* Add more global variables and/or functions as needed */
/* rudimentary boolean wrapper */
typedef enum {
    false, true = !false
}
bool;
typedef struct Node {
    int val;
    struct Node *prev;
    struct Node *next;
} Node;

Node *createNode(int val);

typedef struct Cache {
    Node *head;
    Node *tail;
    int filledBlocks;
    int maxBlocks;

    bool (*access)(struct Cache *, int);
} Cache;

Cache *createCache(int maxBlocks, cache_replacement_t replacement_type);

bool accessFIFO(Cache *self, int tag) {
    bool hit = false;
    Node *head;
    if (self->head != NULL) {
        head = self->head;
        while (!(hit = (head->val == tag)))
            if (head->next != NULL)
                head = head->next;
            else break;
    }
    if (hit) return true;
    else {
        Node *node = createNode(tag);
        if (self->head != NULL) {
            node->next = self->head;
            self->head->prev = node;
        }
        self->head = node;
        if (self->filledBlocks >= self->maxBlocks) {
            Node *prev = self->tail->prev;
            prev->next = NULL;
            free(self->tail);
            self->tail = prev;
        } else if (self->filledBlocks == 0) {
            self->tail = node;
            self->filledBlocks++;
        } else {
            self->filledBlocks++;
        }
    }
    return false;
}

bool accessLRU(Cache *self, int tag) {

}

Node *createNode(int val) {
    Node *node = malloc(sizeof(Node));
    node->val = val;
    node->prev = NULL;
    node->next = NULL;
    return node;
}

Cache *createCache(int maxBlocks, cache_replacement_t replacement_type) {
    Cache *cache = malloc(sizeof(Cache));
    cache->filledBlocks = 0;
    cache->maxBlocks = maxBlocks;
    cache->head = NULL;
    cache->tail = NULL;
    if (replacement_type == fifo)
        cache->access = &accessFIFO;
    else if (replacement_type == lru)
        cache->access = &accessLRU;
    return cache;
}


/**
 * Increments in result memory access and hits
 *
 * @param access memory access
 * @param hit whether cache hit
 * @return hit same value as argument passed in
 */
bool increment_access_count(mem_access_t access, bool hit) {
    switch (access.accesstype) {
        case instruction:
            result.instruction_accesses++;
            if (hit) result.instruction_hits++;
            break;
        case data:
            result.data_accesses++;
            if (hit) result.data_hits++;
            break;
    }
    return hit;
}

int main(int argc, char **argv) {

    /*
     * Read command-line parameters and initialize:
     * cache_size, block_size, cache_mapping and cache_replacement variables
     */
    if (argc != 4) { /* argc should be 4 for correct execution */
        printf("Usage: ./cache_sim [cache size: 64-8192] [cache block size: 32/64/128] [cache mapping: DM/FIFO/LRU]\n");
        exit(-1);
    } else {
        /* argv[0] is program name, parameters start with argv[1] */

        /* Set block and cache size in bytes */
        cache_size = atoi(argv[1]);
        block_size = atoi(argv[2]);
        assert(cache_size >= 256 && cache_size <= 8192);
        /* cache_size must be power of 2 */
        assert(!(cache_size & (cache_size - 1)));
        assert(block_size >= 16 && block_size <= 256);
        /* block_size must be power of 2 */
        assert(!(block_size & (block_size - 1)));
        assert(block_size <= cache_size);

        /* Set Cache Mapping */
        if (strcmp(argv[3], "DM") == 0) {
            cache_mapping = dm;
            cache_replacement = none;
        } else if (strcmp(argv[3], "FIFO") == 0) {
            cache_mapping = fa;
            cache_replacement = fifo;
        } else if (strcmp(argv[3], "LRU") == 0) {
            cache_mapping = fa;
            cache_replacement = lru;
        } else {
            printf("Unknown cache mapping: %s\n", argv[3]);
            exit(-1);
        }

    }
    uint32_t *dm_cache;
    Cache *cache;
    num_blocks = cache_size / block_size;
    num_bits_for_block_offset = log2(block_size);
    if (cache_mapping == dm) {
        num_bits_for_index = log2(num_blocks);
        dm_cache = malloc(sizeof(uint32_t) * num_blocks);
    } else {
        cache = createCache(num_blocks, cache_replacement);
    }
    num_bits_for_tag = 32 - num_bits_for_block_offset - num_bits_for_index;


    /* Open the file mem_trace.txt to read memory accesses */
    FILE *ptr_file;
    ptr_file = fopen("mem_trace.txt", "r");
    if (!ptr_file) {
        printf("Unable to open the trace file\n");
        exit(-1);
    }

    /* Reset the result structure */
    memset(&result, 0, sizeof(result));
    /* Do not delete any of the lines below.
     * Use the following snippet and add your code to finish the task */

    /* Loop until whole trace file has been read */
    mem_access_t access;
    while (1) {
        access = read_transaction(ptr_file);
        //If no transactions left, break out of loop
        if (access.address == 0)
            break;
        /* Add your code here */
        int tag = access.address >> (32 - num_bits_for_tag);
        if (cache_mapping == dm) {
            int index = (access.address >> num_bits_for_block_offset) % (1 << num_bits_for_index);
            if (!increment_access_count(access, dm_cache[index] == tag)) {
                dm_cache[index] = tag;
            }
        } else if (cache_mapping == fa) {
            increment_access_count(access, cache->access(cache, tag));
        }
    }


    /* Do not modify code below */
    /* Make sure that all the parameters are appropriately populated */
    print_statistics(num_blocks, num_bits_for_block_offset, num_bits_for_index, num_bits_for_tag, result);

    /* Close the trace file */
    fclose(ptr_file);

    return 0;
}