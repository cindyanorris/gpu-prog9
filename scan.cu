#include <stdio.h>
#include <stdlib.h>
#include "h_scan.h"
#include "d_scan.h"
#include "wrappers.h"
//config.h defines the number of threads in a block (THREADSPERBLOCK), 
//and the maximum size of shared memory in ints (MAXSHARED) 
#include "config.h"     

//prototypes for functions in this file
void initVector(int * array, int length);
void parseArgs(int argc, char * argv[], int *);
void compare(int * result1, int * result2, int n);
void printUsage();
void printVector(int * vector, int vectorLen);

/*
   driver for the inclusive scan program.  
*/
int main(int argc, char * argv[])
{
    int vectorLen;
    //get the length of the vector
    parseArgs(argc, argv, &vectorLen);
    int * h_vector = (int *) Malloc(sizeof(int) * vectorLen);
    int * h_result = (int *) Malloc(sizeof(int) * vectorLen);
    int * d_result = (int *) Malloc(sizeof(int) * vectorLen);
    float h_time, d_time, speedup;

    //initialize vector 
    initVector(h_vector, vectorLen);
    //printVector(h_vector, vectorLen);
   
    //perform the scan on the CPU
    h_time = h_scan(h_result, h_vector, vectorLen);
    //printVector(h_result, vectorLen);
    printf("\nTiming\n");
    printf("------\n");
    printf("CPU: \t\t%f msec\n", h_time);

    //perform the scan on the GPU 
    d_time = d_scan(d_result, h_vector, vectorLen);
    //printVector(d_result, vectorLen);

    //compare GPU and CPU results 
    compare(h_result, d_result, vectorLen);
    printf("GPU: \t\t%f msec\n", d_time);
    speedup = h_time/d_time;
    printf("Speedup: \t%f\n", speedup);

    free(h_result);
    free(d_result);
    free(h_vector);
}    

/* 
    parseArgs
    This function parses the command line arguments to get
    the vector length.  If the vector length is invalid, 
    it prints usage information and exits.
    Inputs:
    argc - count of the number of command line arguments
    argv - array of command line arguments
    vectorLen - pointer to an int to be set to the vector length
*/
void parseArgs(int argc, char * argv[], int * vectorLen)
{
    int vlen;
    if (argc != 2) printUsage();
    vlen = atoi(argv[1]);        
    if (vlen <= 0 || vlen > (MAXSHARED - THREADSPERBLOCK)) 
       printUsage();
    (*vectorLen) = vlen;
}

/*
    printUsage
    prints usage information and exits
*/
void printUsage()
{
    printf("\nThis program performs an inclusive scan of a vector.\n"); 
    printf("The length of vector to scan is provided as an argument.\n");
    printf("The scan is performed on the CPU and the GPU. The program\n");
    printf("verifies the GPU results by comparing them  to the CPU\n");
    printf("results and outputs the times it takes to perform the scan.\n");
    printf("usage: scan <vector size>\n");
    printf("       <vector size> size of the randomly generated vector to scan\n");
    printf("       <vector size> must not be greater than %d because of the\n", 
                        (MAXSHARED - THREADSPERBLOCK));
    printf("       limited amount of shared memory.\n");
    exit(EXIT_FAILURE);
}

/* 
    initVector
    Initializes an array of ints of size
    length to random values between 0 and 5. 
    Inputs:
    array - pointer to the array to initialize
    length - length of array
*/
void initVector(int * array, int length)
{
    int i;
    for (i = 0; i < length; i++)
    {
        array[i] = (rand() % 5);
    }
}

/*
    compare
    Compares the values in two vectors and outputs an
    error message and exits if the values do not match.
    result1, result2 - int vectors
    n - length of each vector
*/
void compare(int * result1, int * result2, int n)
{
    int i;
    for (i = 0; i < n; i++)
    {
        int diff = abs(result1[i] - result2[i]);
        if (diff != 0) // 
        {
            printf("GPU scan does not match CPU scan.\n");
            printf("cpu result[%d]: %d, gpu: result[%d]: %d\n", 
                   i, result1[i], i, result2[i]);
            exit(EXIT_FAILURE);
        }
    }
}

/*
    printVector
    prints the contents of a vector, 10 elements per line
    vector - pointer to the vector
    vectorLen - length of vector
*/
void printVector(int * vector, int vectorLen)
{
    for (int i = 0; i < vectorLen; i++)
    {
        if ((i % 10) == 0)printf("\n%4d: ", i);
        printf("%3d ", vector[i]);
    }
    printf("\n");
}
