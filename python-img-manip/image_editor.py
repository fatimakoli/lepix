"""
image_editor.py
by Jackie Lin (jl4162)
March 10, 2014

Presents user with a menu of options to edit a picture.
Edits picture using functions from image_functions.py
"""
import image_functions as f

def image_editor():
    '''presents user with a menu of options to edit a picture
    requires image_functions.py'''
    # sets the maximum length of the buffer, which is 3072 for this assignment
    BUFFERMAX = 3072
    # asks user for image file and output file name
    oldfile = raw_input("Enter name of image file (filename.ppm): ")
    newfile = raw_input("Enter name of output file (filename.ppm): ")
    
    # opens image file to be edited and creates new/rewrites image file where
    # changes are to be saved
    infile = open(oldfile, 'r')
    outfile = open(newfile, 'w')
    buffer = [] # buffer array

    
    # writes the first line of the header to the new image file
    outfile.write(infile.readline())
    # saves the dimensions of the image from the second line of the header 
    dimensions = infile.readline()
    # writes the dimensions of the image to the new image file
    outfile.write(dimensions)
    # saves the max intensity of the image from the third line of the header
    max_intensity = infile.readline()
    # writes the max intensity of the image to the new image file
    outfile.write(max_intensity)
    
    # splits dimensions to obtain the number of columns
    dimensionslist = dimensions.split()
    columns = int(dimensionslist[0])
    
    # runs program if image width is less than or equal to max buffer length
    if columns*3 <= BUFFERMAX: 
        # presents user with image editing options
        print "Here are your choices:"
        print "[1]  convert to greyscale [2]  flip horizontally"
        print "[3]  negative of red [4]  negative of green"\
            " [5]  negative of blue"
        print "[6]  just the reds   [7]  just the greens   [8]  just the blues"
        print "[9]  extreme contrast   [10]  horizontal blur"
        
        # asks user to choose from editing option(s)
        grey = raw_input("Do you want [1]? (y/n) ")
        flip = raw_input("Do you want [2]? (y/n) ")
        neg_red = raw_input("Do you want [3]? (y/n) ")
        neg_green = raw_input("Do you want [4]? (y/n) ")
        neg_blue = raw_input("Do you want [5]? (y/n) ")
        red_only = raw_input("Do you want [6]? (y/n) ")
        green_only = raw_input("Do you want [7]? (y/n) ")
        blue_only = raw_input("Do you want [8]? (y/n) ")
        contrast = raw_input("Do you want [9]? (y/n) ")
        blur = raw_input("Do you want [10]? (y/n) ")
        
        # reads original image file line by line
        for line in infile:
            # splits values from line of image file into individual strings
            stringlist = line.split()
            # converts values into integers
            numlist = [int(item) for item in stringlist]
            for num in numlist:
                buffer.append(num)
                # begins editing once buffer holds one row of the image
                if len(buffer) == columns*3:
                    # edits image based on user choices
                    if grey == "y":
                        f.grey_scale(buffer)
                    if flip == "y":
                        f.flip_horizontal(buffer)    
                    if neg_red == "y":
                        f.negate_red(buffer, max_intensity)
                    if neg_green == "y":
                        f.negate_green(buffer, max_intensity)
                    if neg_blue == "y":
                        f.negate_blue(buffer, max_intensity)
                    if red_only == "y":
                        f.flatten_green(buffer)
                        f.flatten_blue(buffer)
                    if green_only == "y":
                        f.flatten_red(buffer)
                        f.flatten_blue(buffer)
                    if blue_only == "y":
                        f.flatten_red(buffer)
                        f.flatten_green(buffer)
                    if contrast == "y":
                        f.extreme_contrast(buffer, max_intensity)
                    if blur == "y":
                        f.horizontal_blur(buffer)
                    # writes edited row of image from buffer to new file
                    for i in range(0,len(buffer)):
                        outfile.write(str(buffer[i]) + " ")
                    outfile.write("\n")
                    # clears buffer
                    buffer = []
       
        # in event of a corrupted image file producing a final row that isn't
        # the same number of columns as the image
        if buffer != []:
            # edits image based on user choices
            if grey == "y":
                f.grey_scale(buffer)
            if flip == "y":
                f.flip_horizontal(buffer)
            if neg_red == "y":
                f.negate_red(buffer, max_intensity)
            if neg_green == "y":
                f.negate_green(buffer, max_intensity)
            if neg_blue == "y":
                f.negate_blue(buffer, max_intensity)
            if red_only == "y":
                f.flatten_green(buffer)
                f.flatten_blue(buffer)
            if green_only == "y":
                f.flatten_red(buffer)
                f.flatten_blue(buffer)
            if blue_only == "y":
                f.flatten_red(buffer)
                f.flatten_green(buffer)
            if contrast == "y":
                f.extreme_contrast(buffer, max_intensity)
            if blur == "y":
                f.horizontal_blur(buffer)
            # writes edited row of image from buffer to new file
            for i in range(0,len(buffer)):
                outfile.write(str(buffer[i]) + " ")
            outfile.write("\n")
        print newfile, "created."
        
    # aborts program if image width is greater than max buffer length
    else:
        print "I'm sorry, your image's width exceeds buffering capacity."
        print "Aborting program..."

    # closes files
    infile.close()
    outfile.close()

# runs image editor    
image_editor()    