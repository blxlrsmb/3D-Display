// File: common.hh
// Date: Tue Jun 04 13:03:25 2013 +0800
// Author: Yuxin Wu <ppwwyyxxc@gmail.com>

#ifndef __HEAD__COMMON
#define __HEAD__COMMON

#include <cmath>
#include <vector>
#include <iostream>
#include <utility>

#define COLOR_BLACK Color(0.0, 0.0, 0.0)
#define COLOR_WHITE Color(1.0, 1.0, 1.0)

typedef double real_t;
const real_t EPS = 1e-6;

static inline real_t sqr(real_t x)
{ return x * x; }

static inline int sign(real_t x) {
	if (fabs(x) < EPS)
		return 0;
	return x < 0 ? -1 : 1;
}

template<typename T>
bool update_min(T &dest, const T &val) {
	if (val < dest) {
		dest = val; return true;
	}
	return false;
}

template<typename T>
bool update_max(T &dest, const T &val) {
	if (dest < val) {
		dest = val; return true;
	}
	return false;
}


#endif //HEAD
