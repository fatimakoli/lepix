"""
negate_blue.py
by Jackie Lin (jl4162)
March 10, 2014

Changes the blue values in a picture to their negatives
"""

from math import fabs

def negate_blue(buffer, max_intensity):
    '''changes the blue values in a picture to their negatives:    
    buffer = image RGB values, max_intensity = maximum color value'''
    for i in range(0,len(buffer)):
        if i%3 == 2: # determines if value is blue
            buffer[i] = fabs(buffer[i] - int(max_intensity)) # if blue, finds negative
    return buffer