***************************************
image_editor.py and image_functions.py ReadMe
by Jackie Lin (jl4162)
March 10, 2014

***************************************
=======================================
image_editor.py and image_functions.py

image_functions.py contains functions which image_editor.py uses to edit
pictures.

image_editor() prompts the user to input names, with .ppm extensions, for a
file with an image they wish to edit and for a new image file. The program 
writes the header from the old image file to the new image file, while saving
the values for the dimensions of the image and the maximum color value from
the second and third lines, respectively. Using the dimensions of the image,
the program determines if the image is wider than the buffer used to process 
the image, in this case 3072 values. If this is the case the program alerts 
the user of this fact and aborts.

If the image is an appropriate size for the buffer, the program then displays a
menu of options for the user to select from and then prompts the user to input
their selections in the form of yes, y, or no, n, inputs in response to a
series of questions. The program then edits the image based on these user
inputs.

image_editor() processes the images one row at a time, adding RGV values from
the original image file until the buffer holds one row from the image,
determined using the dimensions of the image from the second line of the
header. The buffer is then passed through the different editing functions
from image_functions.py.

grey_scale() converts one line of the image to greyscale and takes as input a
line of RGB values, buffer.

flip_horizontal() horizontally flips one line of the image and takes as input
a line of RGB values, buffer.

The negate functions (negate_red(), negate_green(), negate_blue()) negate their
respective color values of one line of the image by setting them to their
negatives and all take as inputs a line of RGB values, buffer, and the maximum
color value from the third line of the image header.

The flatten functions (flatten_red(), flatten_green(), flatten_blue()) flatten
their respective color values of one line of the image by setting them to 0 and
all take as input a line of RGB values, buffer. These functions are used to 
edit the image so that only one color value, either red, green, or blue, is
present in the image.

extreme_contrast() increases the contrast in the image so that the color
values are either completely saturated or 0 and takes as inputs a line of RGB
values, buffer, and the maximum color value from the third line of the image
header.

horizontal_blur() horizontally blurs the image by averaging the same-color 
values across three pixels (i.e. all three red values are averaged, all three
green values, and all three blue values). If the number of pixels in a row of
the image is not divisible by 3, the function sets the remaining pixels in the
row to the average of the final three pixels in the row. It takes as input a 
line of RGB values, buffer.

After passing the row or RGB values through these functions, image_editor()
then writes this line to the new image file, clears the buffer, and repeats
with the next row of the image. 

In the event that the image file being edited
is corrupted and there are values remaining in the buffer that do not make a 
full row of the image, there is code at the end of the program to process
these values as well and to write them to the new image file so that no values
are lost between the original and edited images.
=======================================
