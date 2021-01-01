Facilities Web App
==================

An internal web mapping application built on
[leaflet](https://leafletjs.com/)
(not [NPMap.js](https://github.com/AKROGIS/npmap.js))
and featuring Alaskan NPS facilities managed by the facilities
managers (in FMSS) and spatial data and photos data managed
by the regional GIS team of the National Park Service.

## Build

There is no build step required for this app to work. However it
does require five data files (not included in the repo) in order
to be useful. The code in this app is sensitive to the schema
(structure) of the data files and changes to one or the other will
need to be coordinated and tested. The five data files are how to
build them follows:
### /fmss/photos.json

Built with the
[`make_photos_json.py`](https://github.com/AKROGIS/Facility-Processing/blob/master/Photo%20Processing/scripts/make_photos_json.py)
script from the
[Facility-Processing](https://github.com/AKROGIS/Facility-Processing)
repo. See the
[photo processing workflow](https://github.com/AKROGIS/Facility-Processing/blob/master/Photo%20Processing/workflow.md)
for details.

### data/facilities.csv

Run all the code in
[facilities.sql](https://github.com/AKROGIS/Facility-Processing/blob/master/facilities-website-tools/facilities.sql)
from the
[Facility-Processing](https://github.com/AKROGIS/Facility-Processing)
repo and export the first select query as `facilities.csv`.
### data/assets.csv

Export the second select query from `facilities.sql` (above)
as `assets.csv`.
### data/children.json

Export the third select query from `facilities.sql` (above)
as `parents.csv` and the fourth select query as `all_assets.csv`.
Then run
[`make_children.py`](https://github.com/AKROGIS/Facility-Processing/blob/master/facilities-website-tools/make_children.py)
which will create `children.json` and `assets.json`.
Delete `parents.csv` and `all_assets.csv`

### data/assets.json

This file is created when `make_children.py` is run to
create `children.json` above.

## Deploy

Copy this repo and the data files built above to any published
folder on a web server.  The following files are not required
on the web server and do not need to be copied (although they
wont hurt the app if left on the web server).

* `.git`
* `.gitignore`
* `README.md`
* `Presentation notes.md`
* `to_do.md`

The file `photos.json` (built above) needs to be deployed
to a published web folder called `fmss` the folder must contain
the facility photos at paths that match the URLs in the
`photos.json` file.  See
[Photo Update Process](https://github.com/AKROGIS/Facility-Processing/blob/master/Photo%20Processing/workflow.md)
for details on populating the `fmss` web folder.

Once the web app is deployed, the data files can be updated
as often as needed without redeploying the app (provided
there are no structural changes to the data files).

The data files should be rebuilt (see above) and redeployed
whenever there are changes to the DEFAULT version of the
facilities SDE database, or whenever the
[FMSS Export process](https://github.com/AKROGIS/Enterprise-QC/blob/master/FMSSExport/FMSS%20Export%20Instructions.md)
is completed.

## Using

Point your browser to the published web server folder.
The app is a fairly intuitive web mapping application.
feel free to click at random to see what it can do.
Until there is a help document, see these
[presentation notes](https://github.com/AKROGIS/Facilities-Website/blob/master/Presentation%20notes.md)
for some pointers.
