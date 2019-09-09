Facilities Web App - To Do List
===============================

Pending Features
----------------
* Popup Improvements
  - Expandable and clickable (if we have a marker) list of child Locations
  - Expandable and clickable (if we have a marker) list of Location's Assets
  - Add 'More...' button to open table with additional FMSS Location Attributes (we do not collect everything)
  - Improve Park ID to include Number and Name FMSS attributes (some info seems to be missing)
  - if FMSS.Yearblt is not a 4 digit integer display text (could be 'Planned', or 'm/d/yr', or 'NA'); change label to 'Year Built'
* Enhance search to deal with multiple solutions
  - Examples:
    - Roads and trails have at least two markers, and often more
    - Culverts may have one FMSS record, but multiple GIS locations
  - Currently search just zooms to one (randomly selected) solution
  - What behavior do we want?
    - zoom to extent of all and highlight finds
    - sidebar with clickable list of found items
    - ??? 
* _Improve me_ button (email GIS helpdesk)
* _Zoom to previous extents_ button
* _Reports_ Button
  - Trail assets sorted by distance from trailhead with photos
  - Locations/Assets without a location
  - Differences between GIS and FMSS
  - ???
* Search on more than ID #
  - Description, Park Name/Number, ??
* Style the Search button to match others
* Improve aesthetic, clarity, and intuitiveness of map symbology and markers


Known Bugs
----------
* Popups only work on first layer of an ESRI map service
  - E.g. the Facilities Background Layer only shows popup (extended GIS information) for trails (the top layer)
* Tool tip tends to accumulate
* Marker click does not find all features at click point.
  - Assets and Locations can overlap and hide one another (e.g. trail material is at the trail head)
* Search widget does not always respond correctly when clicking on Location/Asset links in popup.
* Some of the watermarks need refreshing (see Kennecott bridge)


Major Data Editing Tasks
------------------------
* Finish assigning assest ID # to 2015 DENA trail survey
* 2015 DENA trail survey QC issues
* Add 2019 Chilkoot Trail features
* Add Bartlet Cove assets
* Add 2019 WRST Trail survey
* Add support for road side features
* Add 2019 DENA Culvert survey
* Populate missing map labels -- mostly buildings (Can grab from POI)
* Add maintained landscapes and locations for other asset codes
  - Focus on those that are parents to existing items
* Add feature at trail head for trails with a single surface material asset
* Add building assets (when we have photos)
* Fuel storage tanks?
* General review and cleanup of misc issue


Optional Enhancements
---------------------
* Improve sync time with Maximo
* Explore additional solution for markers on linear features (roads, trails)
  - current locations are not very convenient, and can be confusing (trail network).
