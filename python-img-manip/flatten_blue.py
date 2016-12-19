"""
flatten_blue.py
by Jackie Lin (jl4162)
March 10, 2014

Changes the blue values in a picture to 0
"""

def flatten_blue(buffer):
    '''changes the blue values in a picture to 0: buffer = image RGB values'''
    for i in range(0,len(buffer)):    
        if i%3 == 2: # determines if value is blue
            buffer[i] = 0 # if blue, sets value to 0
    return buffer