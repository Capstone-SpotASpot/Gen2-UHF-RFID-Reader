import argparse
import struct
import matplotlib.pyplot as plt

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("filename", type=str, help="Filename of datapoints to plot")
    args = parser.parse_args()

    points = read_points_from_file(args.filename)

    plt.plot(points)
    plt.show()

def read_points_from_file(filename: str) -> list:
    fmt = 'ff'
    in_bytes = []
    with open(filename, 'rb') as infile:
        in_bytes = infile.read()

    out_values = []
    for ii in range(0, len(in_bytes), 8):
        pair = struct.unpack(fmt, in_bytes[ii:ii+8])
        out_values.append(abs(complex(pair[0], pair[1])))

    return out_values



if __name__ == "__main__":
    main()
