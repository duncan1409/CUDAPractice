#include <stdio.h>

__global__ void kernel()
{
	printf("Hello World!! in GPU\n");
}
int main()
{
	kernel<<<1, 1>>>();
	printf("Hello World!! in CPU\n");
	return 0;
}