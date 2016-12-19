"""
image_functions.py
by Jackie Lin (jl4162)
March 10, 2014

Contains image editing functions to be used in image_editor.py
"""
from math import fabs

def grey_scale(buffer):
    '''changes a picture to greyscale: buffer = image RGB values'''
    # averages RGB values of one pixel at a time
    for i in range(0,len(buffer),3):
        # finds average of RGB values
        average = (buffer[i] + buffer[i+1] + buffer[i+2])/3
        # sets RGB values to average
        buffer[i] = average
        buffer[i+1] = average
        buffer[i+2] = average
    
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

def negate_red(buffer, max_intensity):
    '''changes the red values in a picture to their negatives:
    buffer = image RGB values, max_intensity = maximum color value'''
    for i in range(0,len(buffer)):
        if i%3 == 0: # determines if value is red
            buffer[i] = fabs(buffer[i] - int(max_intensity)) # if red, finds negative

def negate_green(buffer, max_intensity):
    '''changes the green values in a picture to their negatives:
    buffer = image RGB values, max_intensity = maximum color value'''
    for i in range(0,len(buffer)):
        if i%3 == 1: # determines if value is green
            buffer[i] = fabs(buffer[i] - int(max_intensity)) # if green, finds negative

def negate_blue(buffer, max_intensity):
    '''changes the blue values in a picture to their negatives:    
    buffer = image RGB values, max_intensity = maximum color value'''
    for i in range(0,len(buffer)):
        if i%3 == 2: # determines if value is blue
            buffer[i] = fabs(buffer[i] - int(max_intensity)) # if blue, finds negative

def flatten_red(buffer):
    '''changes the red values in a picture to 0: buffer = image RGB values'''
    for i in range(0,len(buffer)):       
        if i%3 == 0: # determines if value is red
            buffer[i] = 0 # if red, sets value to 0

def flatten_green(buffer):
    '''changes the green values in a picture to 0: buffer = image RGB values'''
    for i in range(0,len(buffer)):    
        if i%3 == 1: # determines if value is green
            buffer[i] = 0 # if green, sets value to 0
    
def flatten_blue(buffer):
    '''changes the blue values in a picture to 0: buffer = image RGB values'''
    for i in range(0,len(buffer)):    
        if i%3 == 2: # determines if value is blue
            buffer[i] = 0 # if blue, sets value to 0
    
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
    
def horizontal_blur(buffer):
    '''horizontally blurs an image: buffer = image RGB values'''
    # works with groups of three pixels at a time
    for i in range(0,len(buffer),9):
        # if there are at least three pixels remaining
        if len(buffer)-i >= 9:
            # find average RGB values across three pixels
            red_avg = (buffer[i] + buffer[i+3] + buffer[i+6])/3
            green_avg = (buffer[i+1] + buffer[i+4] + buffer[i+7])/3
            blue_avg = (buffer[i+2] + buffer[i+5] + buffer[i+8])/3
            # set the RGB values of these three pixels to these averages
            buffer[i] = red_avg
            buffer[i+3] = red_avg
            buffer[i+6] = red_avg
            buffer[i+1] = green_avg
            buffer[i+4] = green_avg
            buffer[i+7] = green_avg
            buffer[i+2] = blue_avg
            buffer[i+5] = blue_avg
            buffer[i+8] = blue_avg
        # if there is only one pixel remaining, 
        # blur it with the two preceeding pixels
        elif len(buffer)-i == 3:
            # find average RGB values across last three pixels
            red_avg = (buffer[i-6] + buffer[i-3] + buffer[i])/3
            green_avg = (buffer[i-5] + buffer[i-2] + buffer[i+1])/3
            blue_avg = (buffer[i-4] + buffer[i-1] + buffer[i+2])/3
            # set the RGB values of the last pixel to these averages
            buffer[i] = red_avg
            buffer[i+1] = green_avg
            buffer[i+2] = blue_avg
        # if there are only two pixels remaining, 
        # blur it with the preceeding pixel
        elif len(buffer)-i == 6:
            # find average RGB values across last three pixels
            red_avg = (buffer[i-3] + buffer[i] + buffer[i+3])/3
            green_avg = (buffer[i-2] + buffer[i+1] + buffer[i+4])/3
            blue_avg = (buffer[i-1] + buffer[i+2] + buffer[i+5])/3
            # set the RGB values of last two pixels to these averages
            buffer[i] = red_avg
            buffer[i+3] = red_avg
            buffer[i+1] = green_avg
            buffer[i+4] = green_avg
            buffer[i+2] = blue_avg
            buffer[i+5] = blue_avg