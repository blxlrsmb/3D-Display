// File: planedrawer.cc
// Date: Tue Jun 04 13:03:47 2013 +0800
// Author: Yuxin Wu <ppwwyyxxc@gmail.com>

#include <vector>
#include <utility>
#include <queue>
using namespace std;

#include "planedrawer.hh"

std::ostream& operator << (std::ostream& os, const Line2D& l) {
	os << l.first << "->" << l.second;
	return os;
}

void PlaneDrawer::circle(Coor2D o, int r) {
	int x = 0, y = r,
		d = 1 - r;
	// 1.25 is the same as 1
	while (x <= y) {
		Coor2D dd(x, y);
		point(o + dd); point(o - dd);
		point(o + !dd); point(o - !dd);
		point(o + ~dd); point(o - ~dd);
		point(o + !~dd); point(o - !~dd);
		if (d < 0) d += x + x + 3;
		else d += x + x - y - y + 5, y --;
		x ++;
	}
}

