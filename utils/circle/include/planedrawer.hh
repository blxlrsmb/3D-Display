// File: planedrawer.hh
// Date: Tue Jun 04 00:19:19 2013 +0800
// Author: Yuxin Wu <ppwwyyxxc@gmail.com>

#pragma once
#include "color.hh"
#include "render.hh"

#define DEFAULT_DRAWCOLOR COLOR_WHITE

class PlaneDrawer {
	public:
		PlaneDrawer(){};

		PlaneDrawer(RenderBase* m_r):
			 render(m_r) {}

		virtual ~PlaneDrawer(){}

		void set_color(Color m_c)
		{ c = m_c; }

		inline void point(int x, int y)
		{ render->write(x, y, c); }

		inline void point(Coor2D v)
		{ render->write(v.x, v.y, c); }

		void circle(Coor2D o, int r);

		void finish()
		{ render->finish(); }

	protected:
		void Bresenham(Coor2D s, Coor2D t);
		RenderBase* render;
		Color c = DEFAULT_DRAWCOLOR;
};
