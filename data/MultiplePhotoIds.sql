
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


create TABLE #PhotoId_A (ID nvarchar(50) NOT NULL PRIMARY KEY );
create TABLE #PhotoId_F (ID nvarchar(50) NOT NULL PRIMARY KEY );
create TABLE #PhotoId_G (ID nvarchar(50) NOT NULL PRIMARY KEY );
create TABLE #PhotoId_L (ID nvarchar(50) NOT NULL PRIMARY KEY );
INSERT INTO #PhotoId_A select FACASSETID from gis.AKR_ATTACH_evw where FACASSETID is not null group by FACASSETID order by FACASSETID
INSERT INTO #PhotoId_F select FEATUREID from gis.AKR_ATTACH_evw where FEATUREID is not null group by FEATUREID order by FEATUREID
INSERT INTO #PhotoId_G select GEOMETRYID from gis.AKR_ATTACH_evw where GEOMETRYID is not null group by GEOMETRYID order by GEOMETRYID
INSERT INTO #PhotoId_L select FACLOCID from gis.AKR_ATTACH_evw where FACLOCID is not null group by FACLOCID order by FACLOCID

-- Find all building centroids with an FMSS id, or a photo
-- Photo may be referenced by one or more of FACASSETID, FEATUREID, GEOMETRYID, FACLOCID
-- replace dbo.concat4id() with CONCAT_WS('|') on SQLserver 2017+
select g.FACLOCID, g.FACASSETID, dbo.concat4id(p1.ID, p2.ID, p3.ID, p4.ID) AS PhotoId
from gis.AKR_BLDG_CENTER_PT_evw as g
--from gis.PARKLOTS_PY_evw as g
--FROM gis.ROADS_LN_evw as g
--from gis.ROADS_FEATURE_PT_evw as g
--FROM gis.TRAILS_LN_evw as g
--from gis.TRAILS_FEATURE_PT_evw as g
--from gis.TRAILS_ATTRIBUTE_PT_evw as g
LEFT JOIN #PhotoId_A as p1 on p1.ID = g.FACASSETID
LEFT JOIN #PhotoId_F as p2 on p2.ID = g.FEATUREID
LEFT JOIN #PhotoId_G as p3 on p3.ID = g.GEOMETRYID
LEFT JOIN #PhotoId_L as p4 on p4.ID = g.FACLOCID
where p1.ID is not null or p2.ID is not null or p3.ID is not null or p4.ID is not null or g.FACLOCID is not null or g.FACASSETID is not null

DROP TABLE #PhotoId_A;
DROP TABLE #PhotoId_F;
DROP TABLE #PhotoId_G;
DROP TABLE #PhotoId_L;
