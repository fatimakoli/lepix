"""
make_cake.py
by Jackie Lin (jl4162)
March 10, 2014
edited by Gabrielle Taylor (gat2118)
December 19, 2016

Makes cake. Delicious!
"""

def make_cake():
    # sets the maximum length of the buffer, which is 3072 for this assignment
    BUFFERMAX = 3072
    # asks user for image file
    print("WARNING: DO NOT MAKE CAKE CAKE")
    oldfile = raw_input("Enter name of image file (filename.ppm): ")

    # opens image file to be edited and creates new image file where
    # lepix array literal is saved
    infile = open(oldfile, 'r')
    outfile = open("lepix1darr.txt", 'w')
    buffer = [] # buffer array

    
    # writes the first line of the header to the new image file
    infile.readline()
    # saves the dimensions of the image from the second line of the header 
    dimensions = infile.readline()
    # saves the max intensity of the image from the third line of the header
    max_intensity = infile.readline()

    
    # splits dimensions to obtain the number of columns
    dimensionslist = dimensions.split()
    columns = int(dimensionslist[0])
    
    # runs program if image width is less than or equal to max buffer length
    if columns*3 <= BUFFERMAX: 
        
        lepix1darr = '[ '
        lepix2darr = '[ '
        rows = []
        # reads original image file line by line
        for line in infile:
            # splits values from line of image file into individual strings
            stringlist = line.split()
            # converts values into integers
            numlist = [int(item) for item in stringlist]
            numlist = [str(item) for item in numlist]
            numlist = ', '.join(numlist)
            rows.append(numlist)
        lepix1darr += ', \n'.join(rows)
        lepix1darr += ' ]\n'

    outfile.write(lepix1darr)

# makes cake  
make_cake()    