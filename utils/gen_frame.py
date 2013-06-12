#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# $File: gen_frame.py
# $Date: Wed Jun 12 15:03:15 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

from simulib import Vector, RotatedPlane, PI

import json
import sys
from math import sqrt

EPS = 1e-6
THRES = 1.25

class Segment(object):
    start = None
    end = None
    dir_unit = None
    mod = None

    def __init__(self, start, end):
        self.start = start
        self.end = end
        self.dir_unit = (end - start).normalize()
        self.mod = (end - start).mod()

    def get_dist(self, pt):
        dot = self.dir_unit.dot(pt - self.start)
        if dot < 0:
            return (pt - self.start).mod()
        if dot > self.mod:
            return (pt - self.end).mod()
        return self.dir_unit.cross(pt - self.start).mod()

    def __str__(self):
        return str(self.start) + ' -> ' + str(self.end)

    __repr__ = __str__


def calc_min_dist(x, y, agl0, agl1, seg):
    rst = 1e100
    while agl1 - agl0 > EPS:
        m0 = (agl0 * 2 + agl1) / 3.0
        m1 = (agl0 + agl1 * 2) / 3.0
        d0 = seg.get_dist(RotatedPlane(m0).get_coord(x, y))
        d1 = seg.get_dist(RotatedPlane(m1).get_coord(x, y))
        rst = min(rst, d0, d1)
        if d0 < d1:
            agl1 = m1
        else:
            agl0 = m0
    return rst

def gen_frame(agl0, agl1, segs):
    rst = []
    for x in range(16):
        for y in range(16):
            for s in segs:
                if calc_min_dist(x, y, agl0, agl1, s) < THRES:
                    rst.append(y * 16 + x)
                    break
    return rst

def main():
    if len(sys.argv) != 4:
        sys.exit('usage: {} <seg input> <frame output> <number of frames>'
                .format(sys.argv[0]))

    segs = []
    with open(sys.argv[1]) as f:
        for l in f.readlines():
            if l[0] == '#':
                continue
            coord = map(float, l.split())
            segs.append(Segment(Vector(*coord[:3]), Vector(*coord[3:])))

    nrframe = int(sys.argv[3])

    with open(sys.argv[2], 'w') as f:
        d = PI * 2 / nrframe
        for i in range(nrframe):
            print i
            print >> f, json.dumps(gen_frame(i * d, (i + 1) * d, segs))


if __name__ == '__main__':
    main()

