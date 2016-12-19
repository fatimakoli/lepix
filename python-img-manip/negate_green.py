"""
negate_green.py
by Jackie Lin (jl4162)
March 10, 2014

Changes the green values in a picture to their negatives
"""

from math import fabs

def negate_green(buffer, max_intensity):
    '''changes the green values in a picture to their negatives:
    buffer = image RGB values, max_intensity = maximum color value'''
    for i in range(0,len(buffer)):
        if i%3 == 1: # determines if value is green
            buffer[i] = fabs(buffer[i] - int(max_intensity)) # if green, finds negative
    return buffer