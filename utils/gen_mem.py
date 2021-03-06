#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# $File: gen_mem.py
# $Date: Fri Jun 14 22:22:24 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

import sys
import os
import os.path
import json
from copy import deepcopy

class Frame(object):
    addr = None     # byte offset
    content = None  # list of bytes
    
    def __init__(self, content):
        self.content = [int(i) for i in content]
        content = self.content
        content.sort()
        if content:
            assert content[0] >= 0 and content[-1] < 256

        if len(content) & 1:
            content.append(content[-1])

    @classmethod
    def _regularize(cls, frames):
        addr = len(frames) + 1
        if addr & 1:
            addr += 1
        for i in frames:
            i.addr = addr
            addr += len(i.content)
        frames.append(Frame([0] * (1024 - addr)))
        frames[-1].addr = addr

    @classmethod
    def gen_mem_data(cls, frames):
        """:return: (memdata, starting frame number of higher part)"""
        frames = deepcopy(frames)
        cls._regularize(frames)
        data = [0] * 1024
        for i in range(len(frames)):
            data[i] = (frames[i].addr >> 1) & 0xFF

        for i in frames:
            d = i.addr
            for j in i.content:
                data[d] = j
                d += 1

        start = len(frames)
        for i in range(len(frames)):
            if frames[i].addr >> 9:
                start = i
                break

        with open('../hdl/gen/frame_data.txt', 'w') as fout:
            for i in range(len(frames)):
                f = frames[i]
                print >>fout, i, f.addr, f.content
        return [(data[i] << 8) | data[i + 1] for i in range(0, 1024, 2)], start


def gen(frames, fout):
    """:return: starting frame number of higher part"""

    print >> fout, """
    WIDTH=16;
    DEPTH=512;

    ADDRESS_RADIX=DEC;
    DATA_RADIX=DEC;

    CONTENT BEGIN
    """

    data, start = Frame.gen_mem_data(frames)
    for i in range(len(data)):
        print >> fout, ' {0}: {1};'.format(i, data[i])

    print >> fout, "END;"
    return start


if __name__ == '__main__':
    if len(sys.argv) != 2:
        sys.exit('usage: {} <data file>'.format(sys.argv[0]))
    frames = list()
    with open(sys.argv[1]) as f:
        for l in f.readlines():
            frames.append(Frame(list(json.loads(l))))

    os.chdir(os.path.dirname(__file__))
    with open('../hdl/gen/mem.mif', 'w') as f:
        start = gen(frames, f)
    
    with open('../hdl/src/frame_reader_fh.inc.v', 'w') as f:
        print >> f, "`define FRAME_HIGHERPART 8'd{}".format(start)
        print >> f, "`define FB_SIZE 8'd{}".format(len(frames))
        print >> f, "`define FB_SIZE_M1 8'd{}".format(len(frames) - 1)
    print '{} frames'.format(len(frames))


