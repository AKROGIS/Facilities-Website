Facilities Web App - To Do List
===============================

Pending Features
----------------
* Popup Improvements
  - Expandable list of child LOCATIONs;  Clickable if we have a marker.
  - Expandable list of LOCATION's Assets;  Clickable if we have a marker.
  - Add a 'More...' button to open table with additional attributes for LOCATION (Note: we do not import everything)
  - See **Known Bugs** below for more
* Enhance search to deal with multiple solutions
  - Examples:
    - Roads and trails have at least two markers, and often more
    - Culverts may have one FMSS record, but multiple locations
  - Currently search just zooms to one (randomly selected) solution
  - What behavior do we want?
    - hightlight all and zoom to extent of all
    - sidebar with clickable list of found items
    - expand filter list to show all options
      - How would these be distinguish if they only differ by location? 
    - ??? 
* _Improve me_ button (email GIS helpdesk)
* _Zoom to previous extents_ button
* _Reports_ Button
  - Trail assets sorted by distance from trailhead with photos
  - LOCATIONs/Assets without a location
  - Differences between GIS and FMSS
  - ???
* Search on more than ID #
  - Description, Park Name/Number, ??
* Style the Search button to match other buttons
* Improve aesthetic, clarity, and intuitiveness of map symbology and markers


Known Bugs
----------
* Park ID in LOCATION popup seems to be missing information
  - Include both LOCATION attributes for Name **and** Number
* Age in LOCATION popup is sometimes missing or negative
  - if LOCATION.Yearblt is not always a 4 digit integer (less than current year).
    It could be 'Planned', or 'm/d/yr', or 'NA'.
    Change label to 'Year Built' and display as is when not a 4 digit integer.
* Popups only work on first layer of an ESRI map service
  - E.g. the facilities background layer only shows GIS information for trails (the top layer)
* Tool tips tends to accumulate
* Clicking on a marker does not find all features, only the "top" one
  - Assets and LOCATIONs can overlap and hide one another (e.g. trail material is at the trail head)
* Search widget does not always respond correctly when clicking on LOCATION/Asset links in popup.
* Some of the watermarks need refreshing (see Kennecott bridge)


Major Data Editing Tasks
------------------------
* Finish assigning asset IDs to 2015 DENA trail survey
* 2015 DENA trail survey QC issues
* Add 2019 Chilkoot Trail features
* Add Bartlet Cove assets
* Add 2019 WRST Trail survey
* Add support for road side features
* Add 2019 DENA Culvert survey
* Populate missing map labels (Name in LOCATION popup) -- mostly buildings (Can grab from POI)
* Support additional asset codes (e.g. maintained landscapes) from LOCATIONS
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
