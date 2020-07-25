#!/usr/bin/python

import argparse
import sys
import struct
import zlib

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Unpacker for new Shim database (SDB) format')
    parser.add_argument('--input', '-i', required=True)
    parser.add_argument('--output', '-o', required=True)

    args = parser.parse_args()
    try:
        with open(args.input, "rb") as fin:
            in_data = fin.read()
            if len(in_data) < 20:
                print ("Input file is too small")
                sys.exit(1)

            d = struct.unpack("<LLLLL", in_data[0 : 20])
    except:
        print ("Error reading input file")
        sys.exit(1)

    if (d[2] != 0x6662647a):
        print ("Bad magic - not a compressed file")
        sys.exit(1)

    try:
        decompressed = zlib.decompress(in_data[20:])
    except:
        decompressed = None

    if (decompressed == None or len(decompressed) != d[4]):
        print ("Error decompressing stream")
        sys.exit(1)

    try:
        with open(args.output, "wb") as fout:
            fout.write(decompressed)
    except:
        print ("Error writing to output file")
        sys.exit(1)

    print ("Done!")

