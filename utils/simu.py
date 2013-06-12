#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# $File: simu.py
# $Date: Wed Jun 12 13:39:50 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

from simulib import GLDrawer, RotatedPlane, PI

import sys
import json

def main():
    if len(sys.argv) != 2:
        sys.exit('usage: {} <data file>'.format(sys.argv[0]))
    frames = []
    with open(sys.argv[1]) as f:
        for l in f.readlines():
            frames.append(json.loads(l))
    points = build_frame_points(frames)

    gl = GLDrawer('blxlrsmb simulation', points)
    gl.start()

def build_frame_points(frames):
    points = []
    for fnum in range(len(frames)):
        plane = RotatedPlane(PI * 2 * fnum / len(frames))
        for p in frames[fnum]:
            points.append(plane.get_coord(p & 0xF, p >> 4).tolist())
    return points


if __name__ == '__main__':
    main()

