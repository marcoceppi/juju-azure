#!/usr/bin/python

from xml.dom import minidom
import sys, getopt

def main(argv):
    inputfile = ''
    outputfile = ''
    try:
        opts, args = getopt.getopt(argv,"hi:o:",["ifile=","ofile="])
    except getopt.GetoptError:
        print 'get_cert.py -i <inputfile> -o <outputfile>'
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print 'get_cert.py -i <inputfile> -o <outputfile>'
            sys.exit()
        elif opt in ("-i", "--ifile"):
            inputfile = arg
        elif opt in ("-o", "--ofile"):
            outputfile = arg

    xmldoc = minidom.parse(inputfile)
#    itemlist = xmldoc.getElementsByTagName('PublishProfile')
    itemlist = xmldoc.getElementsByTagName('Subscription')
    certb64=itemlist[0].attributes['ManagementCertificate'].value
    # print certb64.decode("base64")
    f = open(outputfile, 'w')
    f.write(certb64.decode("base64"))
    f.close
    
if __name__ == "__main__":
   main(sys.argv[1:])

