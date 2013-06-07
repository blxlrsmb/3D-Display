// File: render.hh
// Date: Tue Jun 04 13:05:02 2013 +0800
// Author: Yuxin Wu <ppwwyyxxc@gmail.com>
//
#ifndef __HEAD__RENDER
#define __HEAD__RENDER

#include "common.hh"
#include "color.hh"
#include <algorithm>
#include <vector>
#include <cassert>

class Geometry {
	public:
		int w, h;

		Geometry(int m_w = 0, int m_h = 0):
			w(m_w), h(m_h) {}

		inline int area() const {
			return w * h;
		}

		real_t ratio() const {
			return (real_t)std::max(w, h) / std::min(w, h);
		}

		inline bool contain(int x, int y) {
			return (x >= 0 && x < w && y >= 0 && y < h);
		}

		std::vector<Coor2D> border() {
			std::vector<Coor2D> ret;
			for (int i = 0; i < w; i ++) {
				ret.push_back(Coor2D(i, 0));
				ret.push_back(Coor2D(i, h - 1));
			}
			for (int j = 1; j < h - 1; j ++) {
				ret.push_back(Coor2D(0, j));
				ret.push_back(Coor2D(w - 1, j));
			}
			return ret;
		}

};

class RenderBase {
	public:
		RenderBase(const Geometry &m_g):
			geo(m_g){}

		virtual ~RenderBase(){};

		virtual void init() {}
		// execute before write

		virtual void finish() {}
		// execute after write

		void write(int x, int y, const Color &c) {
			if (Vec2D(x, y) == INFINITY_POINT)
				return;
			assert(x >= 0 && x < geo.w && y >= 0 && y < geo.h);
			c.check();

			_write(x, y, c);
			render_cnt ++;
		}

		const Geometry& get_geo() const {
			return geo;
		}

		int get_cnt() const {
			return render_cnt;
		}

	private:
		int render_cnt = 0;

	protected:
		Geometry geo;
		virtual void _write(int x, int y, const Color &c) = 0;

};


#endif //HEAD
