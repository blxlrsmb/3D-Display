// File: opencv_render.hh
// Date: Sat Mar 23 17:13:16 2013 +0800
// Author: Yuxin Wu <ppwwyyxxc@gmail.com>

#ifndef __HEAD__OPENCV_RENDER
#define __HEAD__OPENCV_RENDER

#include "render.hh"
#include <opencv2/opencv.hpp>
using namespace cv;


class CVRender: public RenderBase {
	Mat img;

	public:
		void finish();

		CVRender(const Geometry &m_g);

		~CVRender() {}

	protected:
		void _write(int x, int y, const Color& c);
};

#endif //HEAD
