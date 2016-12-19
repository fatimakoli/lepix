"""
negate_red.py
by Jackie Lin (jl4162)
March 10, 2014

Changes the red values in a picture to their negatives
"""

from math import fabs

def negate_red(buffer, max_intensity):
    '''changes the red values in a picture to their negatives:
    buffer = image RGB values, max_intensity = maximum color value'''
    for i in range(0,len(buffer)):
        if i%3 == 0: # determines if value is red
            buffer[i] = fabs(buffer[i] - int(max_intensity)) # if red, finds negative
    return buffer