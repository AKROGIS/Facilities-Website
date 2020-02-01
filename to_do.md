Facilities Web App - To Do List
===============================

Pending Features
----------------
* _Legend/Quick Start_ Button
- Fix **Known Bugs** (see list below)
* Improved Styling:
  - Controls and popups should look more like npmap
* Enhance search to deal with multiple solutions
  - Examples:
    - Roads and trails have at least two markers, and often more
    - Culverts may have one FMSS record, but multiple locations
  - Currently search just zooms to one (randomly selected) solution
  - What behavior do we want?
    - highlight all and zoom to extent of all
    - sidebar with clickable list of found items
    - expand filter list to show all options
      - How would these be distinguished if they only differ by location?
    - ???

Potential Features
------------------
* _Zoom to previous extents_ button
* _Reports_ Button
  - Trail assets sorted by distance from trailhead with photos
  - LOCATIONs/Assets without a location
  - Differences between GIS and FMSS
  - ???
* Search on more than ID and Description
  - Add Map Label, Park Name/Number, ??
* Popup Improvements
  - Add a 'More...' button to open table with additional attributes
    for LOCATION (Note: we do not import everything)


Major Data Editing Tasks
------------------------
* Add 2019 Chilkoot Trail features
* Add 2019 WRST Trail survey
* Add Bartlet Cove assets
* Add support for road side features
* Add 2019 DENA Culvert survey
* Populate missing map labels (Name in LOCATION popup) -- mostly buildings (Can grab from POI)
* Support additional asset codes (e.g. maintained landscapes) from LOCATIONS
  - Focus on those that are parents to existing items
* Add building assets (when we have photos)
* Fuel storage tanks?
* General review and cleanup of misc issue


Known Bugs
----------
* Age in LOCATION popup is sometimes missing or negative
  - if LOCATION.Yearblt is not always a 4 digit integer (less than current year).
    It could be 'Planned', or 'm/d/yr', or 'NA'.
    Change label to 'Year Built' and display as is when not a 4 digit integer.
* Some of the watermarks need refreshing (see Kennecott bridge)


Optional Enhancements
---------------------
* Improve sync time with Maximo
* Explore additional solution for markers on linear features (roads, trails)
  - current locations are not very convenient, and can be confusing (trail network).
