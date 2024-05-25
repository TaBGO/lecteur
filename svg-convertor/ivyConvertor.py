#!/usr/bin/env python
# coding: utf-8

from ivy.std_api import *
import convertor as c
import patternMatching as pm

stop = False

IvyInit("agent_convertisseur")
IvyStart()

def on_tabgo(agent):
    print("Agent %r sent tabgo"%agent)
    c.convert("tabgo", False, 0, 0, 0)

def on_tabgo_printable(agent, text):
    print("Agent %r sent on_tabgo_printable"%agent)
    scale = pm.get_scale(text)
    x = pm.get_x(text)
    y = pm.get_y(text)
    c.convert("tabgo", True, scale, x, y)

def print_given(agent, text):
    print("Agent %r sent json"%agent)
    location = pm.get_location(text)
    scale = pm.get_scale(text)
    x = pm.get_x(text)
    y = pm.get_y(text)
    c.convert(location, True, scale, x, y)


def on_given(agent, text):
    print("Agent %r sent json"%agent)
    location = pm.get_location(text)
    c.convert(location, False, 0, 0, 0)

IvyBindMsg(on_tabgo, "^tabgo: .*")
IvyBindMsg(on_tabgo_printable, "^print tabgo: .*")
IvyBindMsg(on_given, "^convert: .*")
IvyBindMsg(print_given, "^print convert: .*")

IvyMainLoop()









