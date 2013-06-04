// File: color.hh
// Date: Tue Jun 04 13:04:46 2013 +0800
// Author: Yuxin Wu <ppwwyyxxc@gmail.com>

#ifndef __HEAD__COLOR
#define __HEAD__COLOR

#include "geometry.hh"

#include <cmath>

class Color: public Vector {
	public:
		Color(real_t r = 0, real_t g = 0, real_t b = 0):
			Vector(r, g, b){}
		static constexpr real_t C_EPS = 1e-4;

		bool black() const {
			return zero(C_EPS);
		}

		void check() const {
		}
};

#endif //HEAD
