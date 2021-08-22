import csv
import itertools

with open('freqrnc2011.csv') as f, open('words.txt', 'x') as o:
    reader = csv.reader(f, delimiter='\t')
    for i in itertools.dropwhile(lambda x: x[0] != 'абажур', reader):
        o.write(i[0] + '\n')
