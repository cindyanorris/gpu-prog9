#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#include "CHECK.h"
//config.h defines the number of threads in a block (THREADSPERBLOCK), 
//and the maximum size of shared memory in ints (MAXSHARED) 
#include "config.h" 
#include "d_scan.h"

//prototypes for functions just used in this file
__global__ void d_3PhaseScanKernel(int * d_result, int * d_vector, int vectorLen); 
__device__ void printV(int * vector, int vectorLen);

/*  d_scan
    This function prepares and invokes a kernel to perform
    a vector scan on the GPU.  
    Inputs:
    result - points to the vector to hold the result
    vector - points to the vector to scan
    vectorLen - length of the vector to scan
*/
float d_scan(int * result, int * vector, int vectorLen)
{
    cudaEvent_t start_gpu, stop_gpu;
    float gpuMsecTime = -1;

    //time the scan
    CHECK(cudaEventCreate(&start_gpu));
    CHECK(cudaEventCreate(&stop_gpu));
    CHECK(cudaEventRecord(start_gpu));

    //your code goes here

    CHECK(cudaEventRecord(stop_gpu));
    CHECK(cudaEventSynchronize(stop_gpu));
    CHECK(cudaEventElapsedTime(&gpuMsecTime, start_gpu, stop_gpu));
    return gpuMsecTime;
}

/*  
    d_3PhaseScanKernel
    Kernel code for 3 phase scan.  This kernel will only work
    if the entire vector can fit in the shared memory. Only
    one block is generated by the kernel launch so it has
    limited parallelism.
    Inputs:
    d_result - pointer to the array in the global memory to hold the result
    d_vector - pointer to the array in the global memory that holds the 
               vector to scan
    vectorLen - length of the vector
*/
__global__ void d_3PhaseScanKernel(int * d_result, int * d_vector, int vectorLen) 
{
    //shared memory array to hold the vector that is being scanned
    __shared__ int shVector[MAXSHARED - THREADSPERBLOCK];
    //shared memory to hold the last element of each section
    __shared__ int lastElems[THREADSPERBLOCK];

    //In addition to this kernel code, you need to add three device functions.
    //Steps:

    //1) Add code for threads to cooperate in loading the shared vector

    //2) Call a function to perform a sequential scan. Each thread will
    //   call the function perform a sequential scan on its small section. 
    
    //3) Call a Kogge-Stone or Brent-Kung function to perform a parallel
    //   scan on the last elements of each section.  You can fill that
    //   lastElems array before call or have the function fill it

    //4) Call a function that allows a thread to add the appropriate 
    //   element in the scan of lastElems to its chunk

    //5) All threads cooperate in loading the scan that is in shVector
    //   into d_result
}

//add three more functions 

//Here's a helper function if you want to use it
__device__ void printV(int * vector, int vectorLen)
{
    for (int i = 0; i < vectorLen; i++)
    {
        if ((i % 10) == 0)printf("\n%4d: ", i);
        printf("%3d ", vector[i]);
    }
    printf("\n");

}
