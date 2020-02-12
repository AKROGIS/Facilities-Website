
-- Photos.json
-- {id:[photo, photo, ...], id:[photo, ...], ...}
-- Existing; Broken - if a photo is for multiple ids, only one is used
-- Test with where ATCHLINK is of the photos in the next query 

             SELECT COALESCE(FACLOCID, COALESCE(FEATUREID, COALESCE(FACASSETID, GEOMETRYID))) AS id,
			        REPLACE(ATCHLINK, 'https://akrgis.nps.gov/fmss/photos/web/', '') AS photo
               FROM gis.AKR_ATTACH_evw
              WHERE ATCHALTNAME IS NOT NULL AND (FACLOCID IS NOT NULL OR FACASSETID IS NOT NULL OR FEATUREID IS NOT NULL OR GEOMETRYID IS NOT NULL)
           ORDER BY id, ATCHDATE DESC

-- Photos with Multiple IDs
select FACLOCID, FEATUREID, FACASSETID, GEOMETRYID, ATCHLINK
from gis.AKR_ATTACH_evw
-- IIF() is TSQL shorthand for an equivalent ANSI SQL case statement
where IIF(FACLOCID IS NULL, 0,1) + IIF(FEATUREID IS NULL, 0,1) + IIF(FACASSETID IS NULL, 0,1) + IIF(GEOMETRYID IS NULL, 0,1) > 1


-- Fix to get all (11597 v 11589)
             SELECT FACLOCID AS id, REPLACE(ATCHLINK, 'https://akrgis.nps.gov/fmss/photos/web/', '') AS photo, ATCHDATE
               FROM gis.AKR_ATTACH_evw
              WHERE ATCHLINK LIKE 'https://akrgis.nps.gov/fmss/photos/web/%' AND FACLOCID IS NOT NULL
              UNION ALL
             SELECT FACASSETID AS id, REPLACE(ATCHLINK, 'https://akrgis.nps.gov/fmss/photos/web/', '') AS photo, ATCHDATE
               FROM gis.AKR_ATTACH_evw
              WHERE ATCHLINK LIKE 'https://akrgis.nps.gov/fmss/photos/web/%' AND FACASSETID IS NOT NULL
              UNION ALL
             SELECT FEATUREID AS id, REPLACE(ATCHLINK, 'https://akrgis.nps.gov/fmss/photos/web/', '') AS photo, ATCHDATE
               FROM gis.AKR_ATTACH_evw
              WHERE ATCHLINK LIKE 'https://akrgis.nps.gov/fmss/photos/web/%' AND FEATUREID IS NOT NULL
              UNION ALL
             SELECT GEOMETRYID AS id, REPLACE(ATCHLINK, 'https://akrgis.nps.gov/fmss/photos/web/', '') AS photo, ATCHDATE
               FROM gis.AKR_ATTACH_evw
              WHERE ATCHLINK LIKE 'https://akrgis.nps.gov/fmss/photos/web/%' AND GEOMETRYID IS NOT NULL
           ORDER BY id, ATCHDATE DESC


-- Normalize to GEOMETRYID
-- first check for unique GEOMETRYID
-- GEOMETRYID should be unique but it is not.  We could (and should) fix the following errors,
--   but we are not doing a cross feature class QC check, so errors could slip in again.
select GEOMETRYID, min(tbl), max(tbl), count(*) from
    (
        SELECT GEOMETRYID, 'bldg_ct' as tbl from gis.AKR_BLDG_CENTER_PT_evw
        UNION ALL
        SELECT GEOMETRYID, 'bldg_pt' as tbl from gis.AKR_BLDG_OTHER_PT_evw
        UNION ALL
        SELECT GEOMETRYID, 'bldg_foot' as tbl from gis.AKR_BLDG_FOOTPRINT_PY_evw
        UNION ALL
        SELECT GEOMETRYID, 'bldg_py' as tbl from gis.AKR_BLDG_OTHER_PY_evw
        UNION ALL
        SELECT GEOMETRYID, 'road' as tbl from gis.ROADS_LN_evw
        UNION ALL
        SELECT GEOMETRYID, 'road_feat' as tbl from gis.ROADS_FEATURE_PT_evw
        UNION ALL
        SELECT GEOMETRYID, 'trail' as tbl from gis.TRAILS_LN_evw
        UNION ALL
        SELECT GEOMETRYID, 'trail_feat' as tbl from gis.TRAILS_FEATURE_PT_evw
        UNION ALL
        SELECT GEOMETRYID, 'trail_att' as tbl from gis.TRAILS_ATTRIBUTE_PT_evw
        UNION ALL
        SELECT GEOMETRYID, 'plot' as tbl from gis.PARKLOTS_PY_evw
        UNION ALL
        SELECT GEOMETRYID, 'attach' as tbl from gis.AKR_ATTACH_PT_evw
    ) as T 
GROUP BY GEOMETRYID
HAVING COUNT(*) > 1

-- Multipart PhotoID
    SELECT GEOMETRYID, FEATUREID, FACLOCID, FACASSETID from gis.AKR_BLDG_CENTER_PT_evw
    UNION ALL
    SELECT GEOMETRYID, FEATUREID, FACLOCID, FACASSETID from gis.ROADS_LN_evw
    UNION ALL
    SELECT GEOMETRYID, FEATUREID, FACLOCID, FACASSETID from gis.ROADS_FEATURE_PT_evw
    UNION ALL
    SELECT GEOMETRYID, FEATUREID, FACLOCID, FACASSETID from gis.TRAILS_LN_evw
    UNION ALL
    SELECT GEOMETRYID, FEATUREID, FACLOCID, FACASSETID from gis.TRAILS_FEATURE_PT_evw
    UNION ALL
    -- Skip trail attributes, there are no photos, and nothing useful for the facilities web app
    -- SELECT GEOMETRYID, FEATUREID, FACLOCID, FACASSETID from gis.TRAILS_ATTRIBUTE_PT_evw
    -- UNION ALL
    SELECT GEOMETRYID, FEATUREID, FACLOCID, FACASSETID from gis.PARKLOTS_PY_evw



             SELECT FACLOCID AS id, REPLACE(ATCHLINK, 'https://akrgis.nps.gov/fmss/photos/web/', '') AS photo, ATCHDATE
               FROM gis.AKR_ATTACH_evw
              WHERE ATCHLINK LIKE 'https://akrgis.nps.gov/fmss/photos/web/%' AND FACLOCID IS NOT NULL

select 