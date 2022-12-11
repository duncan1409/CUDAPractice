#include <stdio.h>
__global__ void addKernel(int *a, int *b, int *c)
{

	int x = threadIdx.x;
	int y = threadIdx.y;
	int i = y * (blockDim.x) + x; // index = y * WIDTH + x
	c[i] = a[i] + b[i];
}

int main()
{
	const int WIDTH = 5;
	int a[WIDTH][WIDTH];
	int b[WIDTH][WIDTH];
	int c[WIDTH][WIDTH] = {0};

	// Host에서 배열 'a'와 'b'를 채운다.
	for (int y = 0; y < WIDTH; y++)
	{
		for (int x = 0; x < WIDTH; x++)
		{
			a[y][x] = y * 10 + x;
			b[y][x] = (y * 10 + x) * 100;
		}
	}

	int *dev_a, *dev_b, *dev_c = 0; // GPU does not know the array structure of dev_a, dev_b, dev_c

	cudaMalloc((void **)&dev_a, WIDTH * WIDTH * sizeof(int));
	cudaMalloc((void **)&dev_b, WIDTH * WIDTH * sizeof(int));
	cudaMalloc((void **)&dev_c, WIDTH * WIDTH * sizeof(int));

	cudaMemcpy(dev_a, a, WIDTH * WIDTH * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(dev_b, b, WIDTH * WIDTH * sizeof(int), cudaMemcpyHostToDevice);

	dim3 DimBlock(WIDTH, WIDTH);
	addKernel<<<1, DimBlock>>>(dev_a, dev_b, dev_c);

	// 배열 'c'를 Device에서 다시 Host로 복사
	cudaMemcpy(c, dev_c, WIDTH * WIDTH * sizeof(int), cudaMemcpyDeviceToHost);

	for (int y = 0; y < WIDTH; y++)
	{
		for (int x = 0; x < WIDTH; x++)
		{
			printf("%5d", c[y][x]);
		}
		printf("\n");
	}

	return 0;
}