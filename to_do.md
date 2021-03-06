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
* Add additional details for Assets


Major Data Editing Tasks
------------------------
* The photo with FACLOCID 58006 points to a deleted building {B8155F...
* Road 39773 is salvaged in FMSS (and several others) remove FACLOCID, or demo road
* GLBA many feature missing a photo are in an adjacent photo dup the attachment links
* The AKR_Asset feature classes should default to ASSETS, not LOCATIONS
* Many of the GLBA misc features with a photo but no FMSs have not popup attributes
* GLBA the fire standpipe w/o a name should swap locations with the PIV (per the photos) 
* Add 2019 Chilkoot Trail features
* Add 2019 WRST Trail survey
* Add Comm Tower at GLBA (86988/1482171) southwest of 91285
* Populate missing map labels (Name in LOCATION popup) -- mostly buildings (Can grab from POI)
* Support additional asset codes (e.g. maintained landscapes) from LOCATIONS
  - Focus on those that are parents to existing items
* Add building assets (when we have photos)
* General review and cleanup of misc issue
  - Resolve missing trail @ Savage river and McKinley Station (surveyed in 2015 but not in DB)
  - End of most trails not as surveyed (or at trail head sign) connectors have been added
    + remove connectors, trails should start at trailheads
  - What to do with Trail End/Start "trails side features"  Ignore or show more info?
  - Report to compare GIS vs FMSS descriptions for DENA 2015 trail features
    + new/missing assets
    + quantity mismatch
    + feature type mismatch
    + Example Asset is 1502607


Known Bugs
----------
* Some of the watermarks need refreshing (see Kennecott bridge)
* From 39547 clicking on child 90863 does not work because 90863 is also part of asset 1490863
* Searching for an ID (90863) that is part of another longer ID (1490863) will not work
  - Goto feature 39547, thnk try linking to child 90863
* The parent ID in the asset popup should only be a link if we have a marker
  currently we are checking the parent, but some locations with assets are
  not parents (ie they have assets, but no children)
* Additional Icons (and selection strategy) for misc facilities


Optional Enhancements
---------------------
* Improve sync time with Maximo
* Explore additional solution for markers on linear features (roads, trails)
  - current locations are not very convenient, and can be confusing (trail network).


More Potential Features
-----------------------
* Printing
* Filtering
* Goto Lat/Long
* Display Lat/Long
* Mileposts for roads/trails
