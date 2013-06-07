// File: main.cc
// Date: Wed Jun 05 00:11:58 2013 +0800
// Author: Yuxin Wu <ppwwyyxxc@gmail.com>
#include "planedrawer.hh"
#include "opencv.hh"
#include <iostream>
#include <limits>

using namespace std;
typedef Coor2D Coor;
#define BIG 99999999
#define err(x) abs(x.sqr() - r * r)

Coor next_point(Coor now, int r) {
	int y = now.y, x = now.x;


	int min = BIG;
	Coor mincoor;
	if (x >= 0 && y >= 0) {
		for (auto diff : {Coor(1, 0), Coor(1, -1), Coor(0, -1)}) {
			Coor new_p = now + diff;
			int err = err(new_p);
			if (update_min(min, err))
				mincoor = new_p;
		}
		return mincoor;
	}

	if (x >= 0 && y < 0) {
		for (auto diff : {Coor(-1, 0), Coor(-1, -1), Coor(0, -1)}) {
			Coor new_p = now + diff;
			int err = err(new_p);
			if (update_min(min, err))
				mincoor = new_p;
		}
		return mincoor;
	}

	if (x < 0 && y < 0) {
		for (auto diff : {Coor(-1, 0), Coor(-1, 1), Coor(0, 1)}) {
			Coor new_p = now + diff;
			int err = err(new_p);
			if (update_min(min, err))
				mincoor = new_p;
		}
		return mincoor;
	}

	if (x < 0 && y >= 0) {
		for (auto diff : {Coor(1, 0), Coor(1, 1), Coor(0, 1)}) {
			Coor new_p = now + diff;
			int err = err(new_p);
			if (update_min(min, err))
				mincoor = new_p;
		}
		return mincoor;
	}
}

Coor next_point_2(Coor now, int r) {
	Coor rot(now.y, -now.x);
	Coor c1(0, rot.y > 0 ? 1 : -1);
	Coor c2(rot.x > 0 ? 1 : -1, 0);
	Coor c3(rot.x > 0 ? 1 : -1, rot.y > 0 ? 1 : -1);

	int min = BIG;
	Coor mincoor;
	for (auto diff : {c1, c2, c3}) {
		Coor new_p = now + diff;
		int err = err(new_p);
		if (update_min(min, err))
			mincoor = new_p;
	}
	return mincoor;
}

void test_line_circle() {
	RenderBase* r = new CVRender(Geometry(800, 700));
	PlaneDrawer d(r);
	d.circle(Coor(400, 300), 3);
	Coor start(0, 200);
	for (int i = 0; i < 5000; i ++) {
		Coor p = next_point_2(start, 200);
		d.point(Coor(start.x, 700 - start.y) + Coor(400, -400));
		start = p;
	}
	d.finish();
	delete r;
}

int main(int argc, char* argv[]) {
	test_line_circle();
}
