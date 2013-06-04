// File: opencv_render.cc
// Date: Tue Mar 26 19:49:18 2013 +0800
// Author: Yuxin Wu <ppwwyyxxc@gmail.com>

#include <opencv2/opencv.hpp>
#include "opencv.hh"

void CVRender::finish() {
	imshow("show", img);
	waitKey(0);
}

void CVRender::_write(int x, int y, const Color& c) {
	// bgr color space
	img.ptr<uchar>(y)[x * 3] = c.z * 255;
	img.ptr<uchar>(y)[x * 3 + 1] = c.y * 255;
	img.ptr<uchar>(y)[x * 3 + 2] = c.x * 255;
}

CVRender::CVRender(const Geometry &m_g):
	RenderBase(m_g) {
		img.create(m_g.h, m_g.w, CV_8UC3);
		img.setTo(Scalar(0, 0, 0));
}
