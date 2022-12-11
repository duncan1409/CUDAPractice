#include <stdio.h>
#include <stdlib.h> //for rand(), malloc(), free()
#include <sys/stat.h>
#include <windows.h>

#define GRIDSIZE 8 * 1024				 // 8K
#define BLOCKSIZE 1024					 // 1K
#define TOTALSIZE (GRIDSIZE * BLOCKSIZE) // 8M

void genData(float *ptr, unsigned int size)
{
	while (size--)
		*ptr++ = (float)(rand() % 1000) / 1000.0F;
}
void adjDiff(float *dst, const float *src, unsigned int size)
{
	for (int i = 1; i < size; ++i)
		dst[i] = src[i] - src[i - 1];
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

	// start the timer
	QueryPerformanceFrequency((LARGE_INTEGER *)(&cntStart));
	adjDiff(pResult, pSource, TOTALSIZE);
	QueryPerformanceCounter((LARGE_INTEGER *)(&cntEnd));
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