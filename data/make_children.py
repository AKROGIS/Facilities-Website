"""
Converts CSV data from a database dump into json files that
the web app can load without manipulation
See facilities.sql for how to create the various input files
"""
import csv
import collections
import json

def main():
    """Create JSON files for web app"""

    with open('facilities.csv', 'r') as csv_fh:
        csv_fh.readline()  # remove header
        reader = csv.reader(csv_fh)
        gis_loc_counts = collections.Counter([row[1] for row in reader])

    with open('assets.csv', 'r') as csv_fh:
        csv_fh.readline()  # remove header
        reader = csv.reader(csv_fh)
        gis_asset_counts = collections.Counter([row[1] for row in reader])

    children = {}
    with open('parents.csv', 'r') as csv_fh:
        csv_fh.readline()  # remove header
        reader = csv.reader(csv_fh)
        for row in [r for r in reader if r[0] in gis_loc_counts]:
            parent = row[0]
            child = {'i':row[1], 'd':row[2], 'c':gis_loc_counts[row[1]]}
            if parent not in children:
                children[parent] = []
            children[parent].append(child)

    with open('children.json', 'w') as json_fh:
        json_fh.write(json.dumps(children, sort_keys=True, indent=2, separators=(',', ':')))

    assets = {}
    with open('all_assets.csv', 'r') as csv_fh:
        csv_fh.readline()  # remove header
        reader = csv.reader(csv_fh)
        for row in [r for r in reader if r[0] in gis_loc_counts]:
            parent = row[0]
            child = {'i':row[1], 'd':row[2], 'c':gis_asset_counts[row[1]]}
            if parent not in assets:
                assets[parent] = []
            assets[parent].append(child)

    with open('assets.json', 'w') as json_fh:
        json_fh.write(json.dumps(assets, sort_keys=True, indent=2, separators=(',', ':')))

if __name__ == '__main__':
    main()
