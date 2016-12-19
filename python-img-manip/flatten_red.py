"""
flatten_red.py
by Jackie Lin (jl4162)
March 10, 2014

Changes the red values in a picture to 0
"""

def flatten_red(buffer):
    '''changes the red values in a picture to 0: buffer = image RGB values'''
    for i in range(0,len(buffer)):       
        if i%3 == 0: # determines if value is red
            buffer[i] = 0 # if red, sets value to 0
    return buffer
