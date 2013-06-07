// File: a.cpp
// Date: Fri May 31 22:41:29 2013 +0800
// Author: Yuxin Wu <ppwwyyxxc@gmail.com>

#include <iostream>
#include <cstdlib>
#include <cstring>
#include <cstdio>
#include <limits>
#include <ctype.h>
#include <Magick++.h>
using namespace std;
using namespace Magick;
const int n = 16;
int mat[n][n];

char to16(int x, int y) {
	int ret = mat[x][y] * 8 + mat[x][y + 1] * 4 + mat[x][y + 2] * 2 + mat[x][y + 3];
	if (ret < 10) return '0' + ret;
	return 'A' + (ret - 10);
}

int main(int argc, char **argv) {
	if (argc != 2) {
		fprintf(stderr, "usage: %s <image file>\n", argv[0]);
		return -1;
	}
	Image img(argv[1]);
	Geometry size = img.size();

	const PixelPacket* src = img.getConstPixels(0, 0, n, n);
	for (int i = 0; i < n; i ++)
		for (int j = 0; j < n; j ++) {
			mat[i][j] = (src->red <= numeric_limits<__typeof__(src->red)>::max() / 2);
			cout << mat[i][j] << ' ';
			src ++;
			if (j == n - 1)
				cout << endl;
		}

	for (int i = n - 1; i >= 0; i --) {
		for (int j = 0; j < 4; j ++)
			cout << to16(i, j * 4);
	}
	cout << endl;
}


