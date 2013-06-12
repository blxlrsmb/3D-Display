# -*- coding: utf-8 -*-
# $File: __init__.py
# $Date: Wed Jun 12 14:55:19 2013 +0800
# $Author: jiakai <jia.kai66@gmail.com>

from .camera import Camera
from .vector import Vector

try:
    from OpenGL.GL import *
    from OpenGL.GLU import *
    from OpenGL.GLUT import *
except ImportError:
    print 'Warning: opengl unavailable'
    GLUT_UP = -1

import sys
import math
from time import time

from math import cos, sin
from math import pi as PI

class GLDrawer(object):
    camera = None
    clip_near = 0.1
    clip_far = 10000

    win_width = None
    win_height = None

    move_accel = 0.5
    """acceleration"""
    move_velo = 0
    """current velocity"""
    move_accel_dt = 0.1
    """keypress within this time is treated as one long press"""
    prev_move_time = 0
    """previous move keypress time"""
    prev_move_key = None
    """previous moving key code"""

    sphere_slices = 5

    mouse_left_state = GLUT_UP
    mouse_right_state = GLUT_UP
    mouse_x = 0
    mouse_y = 0
    rotate_factor = 0.00001
    x_rotate_speed = 0
    y_rotate_speed = 0
    wheel_speed = 5
    model_rot_agl_x = 0
    model_rot_agl_y = 0

    _in_fullscreen = False
    points = None   # list of points to be drawn

    def __init__(self, win_title, points, win_width = 640, win_height = 480):
        self.camera = Camera([-22, -22, -22],
                [0, 0, 0],
                [0, 0, 1])
        self.points = points[:]
        self.win_width = win_width
        self.win_height = win_height
        def init_glut():
            glutInit(sys.argv)
            glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE | GLUT_DEPTH)
            glutInitWindowSize(win_width, win_height)
            glutCreateWindow(win_title)

            glutDisplayFunc(self._gl_drawscene)
            def visible(vis):
                if vis == GLUT_VISIBLE:
                    glutIdleFunc(self._gl_drawscene)
                else:
                    glutIdleFunc(None)
            glutVisibilityFunc(visible)
            glutKeyboardFunc(self._on_keyboard)
            glutMouseFunc(self._on_mouse)
            glutMotionFunc(self._on_mouse_motion)
            glutReshapeFunc(self._on_reshape)

        def init_gl():
            glClearColor(0.0, 0.0, 0.0, 0.0)	# This Will Clear The Background Color To Black
            glClearDepth(1.0)					# Enables Clearing Of The Depth Buffer
            glDepthFunc(GL_LESS)				# The Type Of Depth Test To Do
            glEnable(GL_DEPTH_TEST)				# Enables Depth Testing
            glShadeModel(GL_SMOOTH)				# Enables Smooth Color Shading
            
            glMatrixMode(GL_PROJECTION)
            glLoadIdentity()					# Reset The Projection Matrix
            gluPerspective(45.0, float(win_width)/float(win_height),
                    self.clip_near, self.clip_far)

            glMatrixMode(GL_MODELVIEW)

        def init_light():
            glLightfv(GL_LIGHT0, GL_AMBIENT, GLfloat_4(0.5, 0.5, 0.5, 1.0))
            glLightfv(GL_LIGHT0, GL_DIFFUSE, GLfloat_4(1.0, 1.0, 1.0, 1.0))
            glLightfv(GL_LIGHT0, GL_SPECULAR, GLfloat_4(1.0, 1.0, 1.0, 1.0))
            glLightfv(GL_LIGHT0, GL_POSITION, GLfloat_4(1.0, 1.0, 1.0, 0.0));   
            glLightModelfv(GL_LIGHT_MODEL_AMBIENT, GLfloat_4(0.2, 0.2, 0.2, 1.0))
            glEnable(GL_LIGHTING)
            glEnable(GL_LIGHT0)

        init_glut()
        init_gl()
        #init_light()

    def start(self):
        glutMainLoop()

    def _on_keyboard(self, key, x, y):
        if key == 'q':
            sys.exit()
        if key == 'f':
            if not self._in_fullscreen:
                self._orig_w = self.win_width
                self._orig_h = self.win_height
                glutFullScreen()
                self._in_fullscreen = True
            else:
                glutReshapeWindow(self._orig_w, self._orig_h)
                self._in_fullscreen = False
        if key in ('w', 's', 'a', 'd'):
            if time() - self.prev_move_time > self.move_accel_dt or \
                    key != self.prev_move_key:
                self.move_velo = 0
            self.prev_move_time = time()
            self.prev_move_key = key
            self.move_velo += self.move_accel
            if key == 'w':
                self.camera.move_forawrd(self.move_velo)
            elif key == 's':
                self.camera.move_forawrd(-self.move_velo)
            elif key == 'a':
                self.camera.move_right(-self.move_velo)
            else:
                self.camera.move_right(self.move_velo)


    def _on_mouse(self, button, state, x, y):
        self.mouse_x = x
        self.mouse_y = y
        if button == GLUT_LEFT_BUTTON:
            self.mouse_left_state = state
        elif button == GLUT_RIGHT_BUTTON:
            self.mouse_right_state = state
        if state == GLUT_UP:
            self.x_rotate_speed = 0
            self.y_rotate_speed = 0
            if button == 3: 
                self.camera.move_forawrd(self.wheel_speed)
            elif button == 4:
                self.camera.move_forawrd(-self.wheel_speed)

    def _on_mouse_motion(self, x, y):
        def getv(v):
            s = False
            if v < 0:
                s = True
                v = -v
            r = self.rotate_factor * pow(v, 1.5)
            if s:
                r = -r
            return r
        if self.mouse_left_state == GLUT_DOWN or \
                self.mouse_right_state == GLUT_DOWN:
            x -= self.mouse_x
            y -= self.mouse_y
            self.x_rotate_speed = getv(y)
            self.y_rotate_speed = getv(x)

    def _on_reshape(self, w, h):
        self.win_width = w
        self.win_height = h
        glViewport(0, 0, w, h)
        glMatrixMode(GL_PROJECTION)
        glLoadIdentity()
        gluPerspective(45.0, float(w)/float(h), self.clip_near, self.clip_far)
        glMatrixMode(GL_MODELVIEW)


    def _gl_drawscene(self):
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

        # apply rotate
        if self.mouse_right_state == GLUT_DOWN:
            self.camera.rotate_right(-self.x_rotate_speed)
            self.camera.rotate_up(self.y_rotate_speed)
        self.camera.setGL()
        if self.mouse_left_state == GLUT_DOWN:
            self.model_rot_agl_x += self.x_rotate_speed * 180 / math.pi
            self.model_rot_agl_y += self.y_rotate_speed * 180 / math.pi
        glRotatef(self.model_rot_agl_x, 1, 0, 0)
        glRotatef(self.model_rot_agl_y, 0, 1, 0)

        # draw bodies
        for p in self.points:
            glPushMatrix()
            glColor3f(1, 1, 1)
            glTranslatef(p[0], p[1], p[2])
            glutSolidSphere(0.1, self.sphere_slices,
                    self.sphere_slices)
            glPopMatrix()

        # draw axis
        glBegin(GL_LINES)
        for i in range(3):
            lst = [0] * 3
            lst[i] = 1
            glColor3f(*lst)
            lst[i] = 20
            glVertex3f(0, 0, 0)
            glVertex3f(*lst)
        glEnd()

        glutSwapBuffers()

    def _print_str(self, s):
        glDisable(GL_DEPTH_TEST)
        glMatrixMode(GL_PROJECTION)
        glPushMatrix()
        glLoadIdentity()
        glOrtho(0, self.win_width, self.win_height, 0, -1, 1)
        glMatrixMode(GL_MODELVIEW)
        glPushMatrix()
        glLoadIdentity()
        glRasterPos2f(10, 20)
        for i in s:
            glutBitmapCharacter(GLUT_BITMAP_HELVETICA_18, ord(i))

        glPopMatrix()
        glMatrixMode(GL_PROJECTION)
        glPopMatrix()
        glMatrixMode(GL_MODELVIEW)
        glEnable(GL_DEPTH_TEST)


class RotatedPlane(object):
    axis_x = None
    axis_y = None
    center = None

    def __init__(self, agl):
        self.axis_x = Vector(cos(agl + PI / 2), sin(agl + PI / 2), 0) * 2.5
        self.axis_y = Vector(0, 0, 2.5)
        self.center = Vector(4 * cos(agl), 4 * sin(agl), 0)

    def get_coord(self, x, y):
        return self.center + self.axis_x * (x - 7.5) + self.axis_y * (y - 7.5)

