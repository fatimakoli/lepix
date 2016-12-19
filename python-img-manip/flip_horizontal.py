"""
flip_horizontal.py
by Jackie Lin (jl4162)
March 10, 2014

Flips a picture horizontally
"""

def flip_horizontal(buffer):
    '''flips an image horizontally: buffer = image RGB values'''
    pixel = [] # array to store RGB values of one pixel
    for i in range(0,len(buffer),3):
        pixel.append(buffer.pop()) # stores blue value of pixel at end
        pixel.append(buffer.pop()) # stores green value of pixel at end
        pixel.append(buffer.pop()) # stores red value of pixel at end
        # inserts RGB values of end pixel in corresponding position at front
        # i.e. if it's the second to last pixel, it's inserted as the second
        # pixel in the front
        for num in pixel:
            buffer.insert(i,num)
        # clears pixel array
        pixel = []
    return buffer