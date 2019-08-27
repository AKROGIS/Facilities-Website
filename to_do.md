Facilities Web App - To Do List
===============================

* Choose better markers/names
* Improve Symbology
  - Thicken trails lines? (they are hard to see in some cases)
  - Parking lots should be transparently filled
  - Other improvements?
* Add Denali Trail Asset Photos (many photos do not have FACASSETID)
  - Generalize the photo lookup algorithm (look at GEOMETRYID, etc, not just FACLOCID)
  - Add all facilities with photos (even when FACLOCID/FACASSSETID are null)?
* Cleanup the popup:
  - if the location has children (location with parent == ID), then create an expandable/clickable list of children
  - if the location has assets (asset.location == ID), then create an expandable list of children
  - Add 'More...' button to open table with all FMSS Attributes (that we collect in our export)
  - Expand Park ID to include Number and Name (some info seems to be missing)
  - if FMSS.Yearblt is not a 4 digit integer display text (could be 'Planned', or 'm/d/yr', or 'NA'); change label to 'Year Built'
  - (Optional) If there is no Park Id, then remove it from the table;
* Button to submit issues to GIS helpdesk
* BUG: Popups only work on first layer of an ESRI map service
  - E.g. the Facilities Background Layer only shows popup (extended GIS information) for trails (the top layer)
* BUG: the tool tip tends to accumulate
* BUG: Popup does not find all features at click point.
  - Assets and Locations can overlap and hide one another (e.g. trail material is at the trail head)
* BUG: Search widget does not always respond correctly when clicking on Location/Asset links in popup.
* Data Editing:
  - Populate missing map labels -- mostly buildings (Can grab from POI)
  - Add other location types (landscape, sites, etc), particularly those that are parents to current facilities
  - Add Building Assets (with photos)
* Enhance search to deal with multiple solutions
  - There are multiple trail points that have the same ID
  - Some Assets have multiple locations
  - Currently search just returns one (randomly selected) feature when multiple are found
* Assets do not cluster with locations. ok?
* Add button for Trail Asset Inventory Report
  - How do I know the order of the assets along the trail?
* Re-watermark all photos on website (see Kennecott bridge)
* Search on Name, Description, Park ID, ...
* Set styling of the Search widget to match npmap styling
