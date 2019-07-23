#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#include "CHECK.h"
#include "h_scan.h"

//prototype for function local to this file
void scanOnCPU(int * h_result, int * h_vector, int vectorLen);

/*  h_scan
    This function returns the amount of time it takes to perform
    a vector scan on the CPU.
    Inputs:
    h_result - points to the vector to hold the result
    h_vector - points to the vector to scan
    vectorLen - length of the vector to scan

    returns the amount of time it takes to perform the
    convolution
*/
float h_scan(int * h_result, int * h_vector, int vectorLen)
{
    cudaEvent_t start_cpu, stop_cpu;
    float cpuMsecTime = -1;

    //Use CUDA functions to do the timing 
    //create event objects
    CHECK(cudaEventCreate(&start_cpu));  
    CHECK(cudaEventCreate(&stop_cpu));
    //record the starting time
    CHECK(cudaEventRecord(start_cpu));   
    
    //call function that does the actual work
    scanOnCPU(h_result, h_vector, vectorLen);
   
    //record the ending time and wait for event to complete
    CHECK(cudaEventRecord(stop_cpu));
    CHECK(cudaEventSynchronize(stop_cpu)); 

    //calculate the elapsed time between the two events 
    CHECK(cudaEventElapsedTime(&cpuMsecTime, start_cpu, stop_cpu));
    return cpuMsecTime;
}

/*  h_scan
    This function performs the vector scan on the CPU.  
    Inputs:
    h_result - points to the vector to hold the result
    h_vector - points to the vector to scan
    vectorLen - length of the vector to scan

    modifies the h_result vector
*/
void scanOnCPU(int * h_result, int * h_vector, int vectorLen)
{
    int i, accumulator = 0;

    for (i = 0; i < vectorLen; i++)
    {
        accumulator += h_vector[i];
        h_result[i] = accumulator;
    }
}
