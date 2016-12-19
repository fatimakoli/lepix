"""
grey_scale.py
by Jackie Lin (jl4162)
March 10, 2014

Changes a picture to grey scale
"""

def grey_scale(buffer):
    '''changes a picture to greyscale: buffer = image values'''
    for i in range(0,len(buffer),3):
        average = (buffer[i] + buffer[i+1] + buffer[i+2])/3
        buffer[i] = average
        buffer[i+1] = average
        buffer[i+2] = average
    return buffer