"""
extreme_contrast.py
by Jackie Lin (jl4162)
March 10, 2014

Changes the values in a picture to either their least or most saturated
"""

def extreme_contrast(buffer, max_intensity):
    '''changes the values in a picture to either their least or most saturated:
    buffer = image RGB values, max_intensity = maximum color value'''
    for i in range(0,len(buffer)):
        # if the RGB value is less than half the maximum color value, the value
        # is changed to 0
        if buffer[i] < int(int(max_intensity)/2.0):
            buffer[i] = 0
        # otherwaise the RGB value, which is greater than half the maximum
        # color value, is changed to the maximum color value
        else:
            buffer[i] = int(max_intensity)
    return buffer