import os
import sys
from PIL import Image

for infile in sys.argv[1:]:
    try:
        im = Image.open(infile) 
        
        # Image size = (ncol x nrow)
        print(infile, im.format, "%dx%d" % im.size, im.mode)
        f, e = os.path.splitext(infile)
        out = f + "_out.txt"
      
        # Image size = (width, height)
        (width, height) = im.size
        print("width =", width)
        print("height =", height)        

        # Create output file
        outfile = open(out, 'w')
        #outfile.write('memory_initialization_radix=2;\n')
        #outfile.write('memory_initialization_vector=\n')

        # Read
        for i in range(3):
            for j in range(width):
                pixel = im.getpixel((j, i))
                #print(pixel)
                outfile.write(str(pixel))
                if j != width-1:
                    outfile.write(' ')
            outfile.write('\n')
                
        
        # Close file
        outfile.close()
          
    except IOError:
        print("Error for file", infile)