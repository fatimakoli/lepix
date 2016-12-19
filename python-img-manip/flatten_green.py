"""
flatten_green.py
by Jackie Lin (jl4162)
March 10, 2014

Changes the green values in a picture to 0
"""

def flatten_green(buffer):
    '''changes the green values in a picture to 0: buffer = image RGB values'''
    for i in range(0,len(buffer)):    
        if i%3 == 1: # determines if value is green
            buffer[i] = 0 # if green, sets value to 0
    return buffer