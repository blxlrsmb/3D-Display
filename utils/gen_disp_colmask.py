#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# $File: gen_disp_colmask.py
# $Date: Fri May 31 22:14:51 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

N = 16
for i in range(N):
    print '(row[{}] & mat[i + {}]) |'.format(i, i * N)
