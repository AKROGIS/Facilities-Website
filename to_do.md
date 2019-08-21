To Do List
==========

* Do not show a pop up for background image layer
* BUG: the tool tip tends to accumulate
* Choose better markers
* Centroids are not always within the feature (DENA dog kennal parking lot)
* Add ability to search the asset layer
* Generalize the photo lookup algorithm (look at GEOMETRYID, etc, not just FACLOCID)
* Cleanup the popup programatically:
  - if there is no Park Id, then remove it from the table
  - if the location has children (location with parent == ID), then create an expandable list of children
  - if the location has assets (asset.location == ID), then create an expandable list of children
* Data Editing:
  - Populate missing map labels -- mostly buildings
  - Add other location types (landscape, sites, etc), particularly those that are parents to current facilities
* How to handle assets that have more than one location?
* Enhance search to deal with multiple solutions (e.g. there are multiple trail points that have the same ID)
