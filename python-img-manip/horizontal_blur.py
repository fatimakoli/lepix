"""
horizontal_blur.py
by Jackie Lin (jl4162)
March 10, 2014

Horizontally blurs an image
"""

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
    return buffer