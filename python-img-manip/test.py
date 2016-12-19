from math import fabs

infile = open('cake.ppm', 'r')
outfile = open('cakenew.ppm', 'w')
buffer = []

outfile.write(infile.readline())
outfile.write(infile.readline())
outfile.write(infile.readline())

for line in infile:
    stringlist = line.split()
    numlist = [int(item) for item in stringlist]
    for num in numlist:
        buffer.append(num)
        if len(buffer) == 2160:
            for i in range(0,len(buffer),9):
                if len(buffer)-i >= 9:
                    red_avg = (buffer[i] + buffer[i+3] + buffer[i+6])/3
                    green_avg = (buffer[i+1] + buffer[i+4] + buffer[i+7])/3
                    blue_avg = (buffer[i+2] + buffer[i+5] + buffer[i+8])/3
                    buffer[i] = red_avg
                    buffer[i+3] = red_avg
                    buffer[i+6] = red_avg
                    buffer[i+1] = green_avg
                    buffer[i+4] = green_avg
                    buffer[i+7] = green_avg
                    buffer[i+2] = blue_avg
                    buffer[i+5] = blue_avg
                    buffer[i+8] = blue_avg
                elif len(buffer)-i == 3:
                    red_avg = (buffer[i-6] + buffer[i-3] + buffer[i])/3
                    green_avg = (buffer[i-5] + buffer[i-2] + buffer[i+1])/3
                    blue_avg = (buffer[i-4] + buffer[i-1] + buffer[i+2])/3 
                    buffer[i] = red_avg
                    buffer[i+1] = green_avg
                    buffer[i+2] = blue_avg
                elif len(buffer)-i == 6:
                    red_avg = (buffer[i-3] + buffer[i] + buffer[i+3])/3
                    green_avg = (buffer[i-2] + buffer[i+1] + buffer[i+4])/3
                    blue_avg = (buffer[i-1] + buffer[i+2] + buffer[i+5])/3
                    buffer[i] = red_avg
                    buffer[i+3] = red_avg
                    buffer[i+1] = green_avg
                    buffer[i+4] = green_avg
                    buffer[i+2] = blue_avg
                    buffer[i+5] = blue_avg
            for i in range(0,len(buffer)):
                outfile.write(str(buffer[i]) + " ")
            outfile.write("\n")
            buffer = []
            

    
infile.close()
outfile.close()