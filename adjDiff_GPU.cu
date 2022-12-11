#include <stdio.h>
#include <stdlib.h> //for rand(), malloc(), free()
#include <sys/stat.h>
#include <windows.h>

#define GRIDSIZE 8 * 1024				 // 8K
#define BLOCKSIZE 1024					 // 1K
#define TOTALSIZE (GRIDSIZE * BLOCKSIZE) // 8M

__global__ void adjDiff(float *result, float *input)
{
	unsigned int i = blockIdx.x * blockDim.x + threadIdx.x;
	if (i > 0)
	{
		float x_i = input[i];
		float x_i_m1 = input[i - 1];
		result[i] = x_i - x_i_m1;
	}
}
void genData(float *ptr, unsigned int size)
{
	while (size--)
		*ptr++ = (float)(rand() % 1000) / 1000.0F;
}
int main()
{
	float *pSource = NULL;
	float *pResult = NULL;
	int i;
	long long cntStart, cntEnd, freq = 0LL;
	QueryPerformanceFrequency((LARGE_INTEGER *)(&freq));
	pSource = (float *)malloc(TOTALSIZE * sizeof(float));
	pResult = (float *)malloc(TOTALSIZE * sizeof(float));

	// generate input source data
	genData(pSource, TOTALSIZE);

	float *pResultDev = NULL;
	float *pSourceDev = NULL;
	// calculate the adjacent difference
	pResult[0] = 0.0F;
	cudaMalloc((void **)&pSourceDev, TOTALSIZE * sizeof(float));
	cudaMalloc((void **)&pResultDev, TOTALSIZE * sizeof(float));
	//CUDA mem cpy from host to device
	cudaMemcpy(pSourceDev, pSource, TOTALSIZE * sizeof(float), cudaMemcpyHostToDevice);
	// start the timer
	QueryPerformanceCounter((LARGE_INTEGER *)(&cntStart));
	//CUDA launch the kernel adjDiff
	dim3 dimGrid(GRIDSIZE, 1, 1);
	dim3 dimBlock(BLOCKSIZE, 1, 1);
	adjDiff<<<dimGrid, dimBlock>>>(pResultDev, pSourceDev);
	QueryPerformanceCounter((LARGE_INTEGER *)(&cntEnd));
	//CUDA memcpy from device to host
	cudaMemcpy(pResult, pResultDev, TOTALSIZE * sizeof(float), cudaMemcpyDeviceToHost);
	printf("elapsed time = %f usec\n", (double)(cntEnd - cntStart) * 1000000.0 / (double)(freq));

	// print sample cases
	i = 1;
	printf("i = %7d: %f = %f - %f\n", i, pResult[i], pSource[i], pSource[i - 1]);
	i = TOTALSIZE - 1;
	printf("i = %7d: %f = %f - %f\n", i, pResult[i], pSource[i], pSource[i - 1]);
	i = TOTALSIZE / 2;
	printf("i = %7d: %f = %f - %f\n", i, pResult[i], pSource[i], pSource[i - 1]);

	//	free the memory
	free(pResult);
	free(pSource);
}