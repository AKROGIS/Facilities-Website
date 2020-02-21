-- //////////////////////////////////////////////////////////////////////
-- Queries to get the CSV files which provide the operational point data for the Facilities Web application
-- Written by Regan Sarwas, 2019-08-20 +/-
--
--  TODO: Consider adding facilities in GIS (that have photos?) even if not in FMSS
--        ISEXTANT = 'True' AND ISOUTPARK <> 'Yes' AND P.FACMAINTAIN IN ('NPS','FEDERAL')
-- //////////////////////////////////////////////////////////////////////

-- Make sure we are using the DEFAULT version in SDE
exec sde.set_default


-------------------------
--
--   Create Temp tables used in queries
--
-------------------------
create TABLE #PhotoId_A (ID nvarchar(50) NOT NULL PRIMARY KEY );
create TABLE #PhotoId_F (ID nvarchar(50) NOT NULL PRIMARY KEY );
create TABLE #PhotoId_G (ID nvarchar(50) NOT NULL PRIMARY KEY );
create TABLE #PhotoId_L (ID nvarchar(50) NOT NULL PRIMARY KEY );
INSERT INTO #PhotoId_A select FACASSETID from akr_facility2.gis.AKR_ATTACH_evw where FACASSETID is not null group by FACASSETID order by FACASSETID
INSERT INTO #PhotoId_F select FEATUREID from akr_facility2.gis.AKR_ATTACH_evw where FEATUREID is not null group by FEATUREID order by FEATUREID
INSERT INTO #PhotoId_G select GEOMETRYID from akr_facility2.gis.AKR_ATTACH_evw where GEOMETRYID is not null group by GEOMETRYID order by GEOMETRYID
INSERT INTO #PhotoId_L select FACLOCID from akr_facility2.gis.AKR_ATTACH_evw where FACLOCID is not null group by FACLOCID order by FACLOCID

SELECT g.FACLOCID, g.FACASSETID, g.MAPLABEL, g.BLDGTYPE, g.Shape, dbo.concat4id(p1.ID, p2.ID, p3.ID, p4.ID) AS PhotoId
INTO #Buildings
FROM akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as g
LEFT JOIN #PhotoId_A as p1 on p1.ID = g.FACASSETID
LEFT JOIN #PhotoId_F as p2 on p2.ID = g.FEATUREID
LEFT JOIN #PhotoId_G as p3 on p3.ID = g.GEOMETRYID
LEFT JOIN #PhotoId_L as p4 on p4.ID = g.FACLOCID
WHERE (p1.ID IS NOT NULL OR p2.ID IS NOT NULL OR p3.ID IS NOT NULL OR p4.ID IS NOT NULL OR g.FACLOCID IS NOT NULL OR g.FACASSETID IS NOT NULL)

SELECT g.FACLOCID, g.FACASSETID, g.MAPLABEL, g.Shape, dbo.concat4id(p1.ID, p2.ID, p3.ID, p4.ID) AS PhotoId
INTO #Parking
FROM akr_facility2.gis.PARKLOTS_PY_evw as g
LEFT JOIN #PhotoId_A as p1 on p1.ID = g.FACASSETID
LEFT JOIN #PhotoId_F as p2 on p2.ID = g.FEATUREID
LEFT JOIN #PhotoId_G as p3 on p3.ID = g.GEOMETRYID
LEFT JOIN #PhotoId_L as p4 on p4.ID = g.FACLOCID
WHERE (p1.ID IS NOT NULL OR p2.ID IS NOT NULL OR p3.ID IS NOT NULL OR p4.ID IS NOT NULL OR g.FACLOCID IS NOT NULL OR g.FACASSETID IS NOT NULL)

SELECT g.FACLOCID, g.FACASSETID, g.MAPLABEL, g.ISBRIDGE, g.Shape, dbo.concat4id(p1.ID, p2.ID, p3.ID, p4.ID) AS PhotoId
INTO #Trails
FROM akr_facility2.gis.TRAILS_LN_evw as g
LEFT JOIN #PhotoId_A as p1 on p1.ID = g.FACASSETID
LEFT JOIN #PhotoId_F as p2 on p2.ID = g.FEATUREID
LEFT JOIN #PhotoId_G as p3 on p3.ID = g.GEOMETRYID
LEFT JOIN #PhotoId_L as p4 on p4.ID = g.FACLOCID
WHERE (p1.ID IS NOT NULL OR p2.ID IS NOT NULL OR p3.ID IS NOT NULL OR p4.ID IS NOT NULL OR g.FACLOCID IS NOT NULL OR g.FACASSETID IS NOT NULL)
AND g.LINETYPE = 'Center line'

SELECT g.FACLOCID, g.FACASSETID, g.MAPLABEL, g.Shape, dbo.concat4id(p1.ID, p2.ID, p3.ID, p4.ID) AS PhotoId,
        CASE WHEN g.TRLFEATTYPE = 'Other' THEN g.TRLFEATTYPEOTHER ELSE g.TRLFEATTYPE END + 
          CASE WHEN g.TRLFEATSUBTYPE is NULL THEN '' ELSE ', ' + g.TRLFEATSUBTYPE END AS FEATTYPE,
        g.TRLFEATDESC AS FEATDESC
INTO #Trail_Feats
FROM akr_facility2.gis.TRAILS_FEATURE_PT_evw as g
LEFT JOIN #PhotoId_A as p1 on p1.ID = g.FACASSETID
LEFT JOIN #PhotoId_F as p2 on p2.ID = g.FEATUREID
LEFT JOIN #PhotoId_G as p3 on p3.ID = g.GEOMETRYID
LEFT JOIN #PhotoId_L as p4 on p4.ID = g.FACLOCID
WHERE (p1.ID IS NOT NULL OR p2.ID IS NOT NULL OR p3.ID IS NOT NULL OR p4.ID IS NOT NULL OR g.FACASSETID IS NOT NULL)
OR (g.FACLOCID IS NOT NULL AND TRLFEATTYPE <> 'Trail Head'AND TRLFEATTYPE <> 'Trail End' AND TRLFEATTYPEOTHER <> 'AnchorPt')

SELECT g.FACLOCID, g.FACASSETID, g.Shape, dbo.concat4id(p1.ID, p2.ID, p3.ID, p4.ID) AS PhotoId,
        CASE WHEN g.TRLATTRTYPE = 'Other' THEN g.TRLATTRTYPEOTHER ELSE g.TRLATTRTYPE END + 
          CASE WHEN g.TRLATTRVALUE is NULL THEN '' ELSE ', ' + g.TRLATTRVALUE END AS ATTTYPE,
        g.TRLATTRDESC as ATTDESC
INTO #Trail_Atts
FROM akr_facility2.gis.TRAILS_ATTRIBUTE_PT_evw as g
LEFT JOIN #PhotoId_A as p1 on p1.ID = g.FACASSETID
LEFT JOIN #PhotoId_F as p2 on p2.ID = g.FEATUREID
LEFT JOIN #PhotoId_G as p3 on p3.ID = g.GEOMETRYID
LEFT JOIN #PhotoId_L as p4 on p4.ID = g.FACLOCID
WHERE (p1.ID IS NOT NULL OR p2.ID IS NOT NULL OR p3.ID IS NOT NULL OR p4.ID IS NOT NULL OR g.FACLOCID IS NOT NULL OR g.FACASSETID IS NOT NULL)

SELECT g.FACLOCID, g.FACASSETID, g.MAPLABEL, g.ISBRIDGE, g.Shape, dbo.concat4id(p1.ID, p2.ID, p3.ID, p4.ID) AS PhotoId
INTO #Roads
FROM akr_facility2.gis.ROADS_LN_evw as g
LEFT JOIN #PhotoId_A as p1 on p1.ID = g.FACASSETID
LEFT JOIN #PhotoId_F as p2 on p2.ID = g.FEATUREID
LEFT JOIN #PhotoId_G as p3 on p3.ID = g.GEOMETRYID
LEFT JOIN #PhotoId_L as p4 on p4.ID = g.FACLOCID
WHERE (p1.ID IS NOT NULL OR p2.ID IS NOT NULL OR p3.ID IS NOT NULL OR p4.ID IS NOT NULL OR g.FACLOCID IS NOT NULL OR g.FACASSETID IS NOT NULL)
AND g.LINETYPE = 'Center line'

SELECT g.FACLOCID, g.FACASSETID, g.MAPLABEL, g.Shape, dbo.concat4id(p1.ID, p2.ID, p3.ID, p4.ID) AS PhotoId,
        CASE WHEN g.RDFEATTYPE = 'Other' THEN g.RDFEATTYPEOTHER ELSE RDFEATTYPE END + 
          CASE WHEN g.RDFEATSUBTYPE is NULL THEN '' ELSE ', ' + g.RDFEATSUBTYPE END AS FEATTYPE,
        g.RDFEATDESC AS FEATDESC
INTO #Road_Feats
FROM akr_facility2.gis.ROADS_FEATURE_PT_evw as g
LEFT JOIN #PhotoId_A as p1 on p1.ID = g.FACASSETID
LEFT JOIN #PhotoId_F as p2 on p2.ID = g.FEATUREID
LEFT JOIN #PhotoId_G as p3 on p3.ID = g.GEOMETRYID
LEFT JOIN #PhotoId_L as p4 on p4.ID = g.FACLOCID
WHERE (p1.ID IS NOT NULL OR p2.ID IS NOT NULL OR p3.ID IS NOT NULL OR p4.ID IS NOT NULL OR g.FACLOCID IS NOT NULL OR g.FACASSETID IS NOT NULL)

SELECT g.FACLOCID, g.FACASSETID, g.MAPLABEL, g.Shape, dbo.concat4id(p1.ID, p2.ID, p3.ID, p4.ID) AS PhotoId,
        CASE WHEN g.ASSETTYPE = 'Other' THEN g.ASSETTYPEOTHDESC ELSE ASSETTYPE END AS FEATTYPE,
        g.ASSETDESC AS FEATDESC
INTO #Misc_Pt
FROM akr_facility2.gis.AKR_ASSET_PT_evw as g
LEFT JOIN #PhotoId_A as p1 on p1.ID = g.FACASSETID
LEFT JOIN #PhotoId_F as p2 on p2.ID = g.FEATUREID
LEFT JOIN #PhotoId_G as p3 on p3.ID = g.GEOMETRYID
LEFT JOIN #PhotoId_L as p4 on p4.ID = g.FACLOCID
WHERE (p1.ID IS NOT NULL OR p2.ID IS NOT NULL OR p3.ID IS NOT NULL OR p4.ID IS NOT NULL OR g.FACLOCID IS NOT NULL OR g.FACASSETID IS NOT NULL)

SELECT g.FACLOCID, g.FACASSETID, g.MAPLABEL, g.Shape, dbo.concat4id(p1.ID, p2.ID, p3.ID, p4.ID) AS PhotoId,
        CASE WHEN g.ASSETTYPE = 'Other' THEN g.ASSETTYPEOTHDESC ELSE ASSETTYPE END AS FEATTYPE,
        g.ASSETDESC AS FEATDESC
INTO #Misc_Py
FROM akr_facility2.gis.AKR_ASSET_PY_evw as g
LEFT JOIN #PhotoId_A as p1 on p1.ID = g.FACASSETID
LEFT JOIN #PhotoId_F as p2 on p2.ID = g.FEATUREID
LEFT JOIN #PhotoId_G as p3 on p3.ID = g.GEOMETRYID
LEFT JOIN #PhotoId_L as p4 on p4.ID = g.FACLOCID
WHERE (p1.ID IS NOT NULL OR p2.ID IS NOT NULL OR p3.ID IS NOT NULL OR p4.ID IS NOT NULL OR g.FACLOCID IS NOT NULL OR g.FACASSETID IS NOT NULL)

SELECT g.FACLOCID, g.FACASSETID, g.MAPLABEL, g.Shape, dbo.concat4id(p1.ID, p2.ID, p3.ID, p4.ID) AS PhotoId,
        CASE WHEN g.ASSETTYPE = 'Other' THEN g.ASSETTYPEOTHDESC ELSE ASSETTYPE END AS FEATTYPE,
        g.ASSETDESC AS FEATDESC
INTO #Misc_Ln
FROM akr_facility2.gis.AKR_ASSET_LN_evw as g
LEFT JOIN #PhotoId_A as p1 on p1.ID = g.FACASSETID
LEFT JOIN #PhotoId_F as p2 on p2.ID = g.FEATUREID
LEFT JOIN #PhotoId_G as p3 on p3.ID = g.GEOMETRYID
LEFT JOIN #PhotoId_L as p4 on p4.ID = g.FACLOCID
WHERE (p1.ID IS NOT NULL OR p2.ID IS NOT NULL OR p3.ID IS NOT NULL OR p4.ID IS NOT NULL OR g.FACLOCID IS NOT NULL OR g.FACASSETID IS NOT NULL)


-------------------------
--
--   facilities.csv
--
-------------------------

-- Facilities in GIS matching FMSS Location records or having a photo and but no FACASSETID (selected in assets below)

SELECT
    -- GIS Attributes
    g.Kind,
    g.FACLOCID  + CASE WHEN f.[Type] = 'SALVAGE' THEN ' (Salvage)' ELSE '' END AS ID,
    COALESCE(g.MAPLABEL, '') AS [Name],
    g.Latitude, g.Longitude,
    g.Photo_Id,
    -- FMSS Location Attributes
    COALESCE(FORMAT(TRY_CAST(f.CRV AS FLOAT), 'C', 'en-us'), 'Unknown') AS CRV,
    COALESCE(FORMAT(TRY_CAST(f.DM AS FLOAT), 'C', 'en-us'), 'Unknown') AS DM,
    COALESCE(CONVERT(varchar, YEAR(GetDate()) - TRY_CONVERT(INT, f.YearBlt)) + ' yrs', YearBlt) AS Age,
    f.Description AS [Desc],
    COALESCE(COALESCE(f.PARKNAME, f.PARKNUMB), '')  AS [Park_Id],
    f.Qty + ' ' + f.UM + g.Size as Size,
    f.Parent, f.Status AS [Status]
FROM
    akr_facility2.dbo.FMSSExport AS f
RIGHT JOIN
    (
    -- Buildings (Center Point)
    SELECT
      'Building' AS Kind,
      FACLOCID, MAPLABEL,
      Shape.STY AS Latitude, Shape.STX AS Longitude,
      '' as Size,
      PhotoId AS Photo_Id
    FROM
      #Buildings
    WHERE
      FACASSETID IS NULL
  UNION ALL
    -- Parking Lots (Centroid)
    SELECT
      'Parking' AS Kind,
      FACLOCID, MAPLABEL,
      Shape.STCentroid().STY AS Latitude, Shape.STCentroid().STX AS Longitude,
      ' (GIS: '+FORMAT(GEOGRAPHY::STGeomFromText(shape.STAsText(),4269).STArea() * 3.28084 * 3.28084,'N0') + 'sf)' as Size,
      PhotoId AS Photo_Id
    FROM
      #Parking
    WHERE
      FACASSETID IS NULL
  UNION ALL
    SELECT DISTINCT
      -- road features (asserts by default, must have a FACLOCID)
      'Road' AS Kind,
      FACLOCID,
      FEATTYPE + CASE WHEN FEATDESC IS NULL THEN ' (' + FEATDESC + ')' ELSE '' END AS MAPLABEL,
      Shape.STY AS Latitude, Shape.STX AS Longitude,
      '' AS Size,
      PhotoID AS Photo_Id
    FROM
      #Road_Feats
    WHERE
      FACASSETID IS NULL AND PhotoId IS NULL
  UNION ALL
    SELECT DISTINCT
      -- trail features (asserts by default, must have a FACLOCID)
      'Trail' AS Kind,
      FACLOCID,
      FEATTYPE + CASE WHEN FEATDESC IS NULL THEN ' (' + FEATDESC + ')' ELSE '' END AS MAPLABEL,
      Shape.STY AS Latitude, Shape.STX AS Longitude,
      '' AS Size,
      PhotoID AS Photo_Id
    FROM
      #Trail_Feats
    WHERE
      FACASSETID IS NULL AND PhotoId IS NULL
  -- SKIP trail attributes - Will only be an asset (FACLOCID is used as a foreign key to trail)
  UNION ALL
    -- Trails (All start and end points for a given FACLOCID that are not coincident
    --         with another end or start point respectively)
    SELECT 
      'Trail' AS Kind,
      g1.FACLOCID, g1.MAPLABEL,
      g1.Latitude, g1.Longitude,
      '(GIS: '+FORMAT(g2.Feet,'N0') + 'ft)' as Size,
      g1.PhotoId AS Photo_Id
    FROM (
      SELECT 
        FACLOCID, PhotoId, MAPLABEL,
        Latitude, Longitude
      FROM (
          SELECT
            FACLOCID, PhotoId, MAPLABEL,
            Shape.STStartPoint().STY AS Latitude, Shape.STStartPoint().STX AS Longitude
          FROM
            #Trails
          WHERE
            FACASSETID IS NULL AND ISBRIDGE <> 'Yes'
        UNION ALL
          SELECT
            FACLOCID, PhotoId, MAPLABEL,
            Shape.STEndPoint().STY AS Latitude, Shape.STEndPoint().STX AS Longitude
          FROM
            #Trails
          WHERE
            FACASSETID IS NULL AND ISBRIDGE <> 'Yes'
        ) AS temp
      GROUP BY
        FACLOCID, PhotoId, MAPLABEL, Latitude, Longitude
      HAVING
        COUNT(*) = 1
    ) AS g1
    JOIN (
      SELECT
        FACLOCID, PhotoId, MAPLABEL,
        SUM(GEOGRAPHY::STGeomFromText(shape.STAsText(),4269).STLength()) * 3.28084 as Feet
      FROM
        #Trails
      WHERE
        FACASSETID IS NULL AND ISBRIDGE <> 'Yes'
      GROUP BY
        FACLOCID, PhotoId, MAPLABEL
    ) AS g2
    ON COALESCE(g1.FACLOCID,'') = COALESCE(g2.FACLOCID,'')
    AND COALESCE(g1.PhotoId,'') = COALESCE(g2.PhotoId,'')
    AND COALESCE(g1.MAPLABEL,'') = COALESCE(g2.MAPLABEL,'')
  UNION ALL
    -- Roads (All start and end points for a given FACLOCID that are not coincident
    --         with another end or start point respectively)
    SELECT
      'Road' AS Kind,
      g1.FACLOCID, g1.MAPLABEL,
      g1.Latitude, g1.Longitude,
      ' (GIS: '+FORMAT(g2.Miles,'N2') + 'mi)' as Size,
      g1.PhotoId AS Photo_Id
    FROM (
      SELECT 
        FACLOCID, PhotoId, MAPLABEL,
        Latitude, Longitude
      FROM (
          SELECT
            FACLOCID, PhotoId, MAPLABEL,
            Shape.STStartPoint().STY AS Latitude, Shape.STStartPoint().STX AS Longitude
          FROM
            #Roads
          WHERE
            FACASSETID IS NULL AND ISBRIDGE <> 'Yes'
        UNION ALL
          SELECT
            FACLOCID, PhotoId, MAPLABEL,
            Shape.STEndPoint().STY AS Latitude, Shape.STEndPoint().STX AS Longitude
          FROM
            #Roads
          WHERE
            FACASSETID IS NULL AND ISBRIDGE <> 'Yes'
        ) AS temp
      GROUP BY
        FACLOCID, PhotoId, MAPLABEL, Latitude, Longitude
      HAVING
        COUNT(*) = 1
    ) AS g1
    JOIN (
      SELECT
        FACLOCID, PhotoId, MAPLABEL,
        SUM(GEOGRAPHY::STGeomFromText(shape.STAsText(),4269).STLength()) * 0.000621371 as Miles
      FROM
        #Roads
      WHERE
        FACASSETID IS NULL AND ISBRIDGE <> 'Yes'
      GROUP BY
        FACLOCID, PhotoId, MAPLABEL
    ) AS g2
    ON COALESCE(g1.FACLOCID,'') = COALESCE(g2.FACLOCID,'')
    AND COALESCE(g1.PhotoId,'') = COALESCE(g2.PhotoId,'') AND COALESCE(g1.MAPLABEL,'') = COALESCE(g2.MAPLABEL,'')
  UNION ALL
    -- Trail Bridges (Middle vertex, or average of two middle vertices)
    SELECT
      'Bridge' AS Kind,
      FACLOCID, MAPLABEL,
      -- Mid point of bridge
      CASE
        WHEN
          (Shape.STNumPoints() % 2) = 0
        THEN --Even number of vertices
          (Shape.STPointN(Shape.STNumPoints()/2).STY + Shape.STPointN(1 + Shape.STNumPoints()/2).STY)/2.0
        ELSE -- Odd
          Shape.STPointN(1 + Shape.STNumPoints()/2).STY
      END AS Latitude,
      CASE
        WHEN
          (Shape.STNumPoints() % 2) = 0
        THEN --Even
          (Shape.STPointN(Shape.STNumPoints()/2).STX + Shape.STPointN(1 + Shape.STNumPoints()/2).STX)/2.0
        ELSE -- Odd
          Shape.STPointN(1 + Shape.STNumPoints()/2).STX
      END AS Longitude,
      '' AS Size,
      PhotoId AS Photo_Id
    FROM
      #Trails
    WHERE
      FACASSETID IS NULL AND ISBRIDGE = 'Yes'
  UNION ALL
    -- Road Bridges (Middle vertex, or average of two middle vertices)
    SELECT
      'Bridge' AS Kind,
      FACLOCID, MAPLABEL,
      -- Get mid point of bridge
      CASE
        WHEN
          (Shape.STNumPoints() % 2) = 0
        THEN --Even number of vertices
          (Shape.STPointN(Shape.STNumPoints()/2).STY + Shape.STPointN(1 + Shape.STNumPoints()/2).STY)/2.0
        ELSE -- Odd
          Shape.STPointN(1 + Shape.STNumPoints()/2).STY
      END AS Latitude,
      CASE
        WHEN
          (Shape.STNumPoints() % 2) = 0
        THEN --Even
          (Shape.STPointN(Shape.STNumPoints()/2).STX + Shape.STPointN(1 + Shape.STNumPoints()/2).STX)/2.0
        ELSE -- Odd
          Shape.STPointN(1 + Shape.STNumPoints()/2).STX
      END AS Longitude,
      '' AS Size,
      PhotoId AS Photo_Id
    FROM
      #Roads
    WHERE
      FACASSETID IS NULL AND ISBRIDGE = 'Yes'
  UNION ALL
    -- Miscellaneous points (Center Point)
    SELECT
      'Misc' AS Kind,
      FACLOCID, MAPLABEL,
      Shape.STY AS Latitude, Shape.STX AS Longitude,
      '' as Size,
      PhotoId AS Photo_Id
    FROM
      #Misc_Pt
    WHERE
      FACASSETID IS NULL
  UNION ALL
    -- Miscellaneous polygons (centroid)
    SELECT
      'Misc' AS Kind,
      FACLOCID, MAPLABEL,
      Shape.STCentroid().STY AS Latitude, Shape.STCentroid().STX AS Longitude,
      '' as Size,
      PhotoId AS Photo_Id
    FROM
      #Misc_Py
    WHERE
      FACASSETID IS NULL
  UNION ALL
    -- Miscellaneous lines (All start and end points for a given FACASSETID that are not coincident
    --         with another end or start point respectively)
    SELECT
      'Misc' AS Kind,
      g1.FACLOCID, g1.MAPLABEL,
      g1.Latitude, g1.Longitude,
      '' as Size,
      g1.PhotoId AS Photo_Id
    FROM (
      SELECT 
        FACLOCID, PhotoId, MAPLABEL, FEATTYPE,
        Latitude, Longitude
      FROM (
          SELECT
            FACLOCID, PhotoId, MAPLABEL, FEATTYPE,
            Shape.STStartPoint().STY AS Latitude, Shape.STStartPoint().STX AS Longitude
          FROM
            #Misc_Ln
          WHERE
            FACASSETID IS NULL
        UNION ALL
          SELECT
            FACLOCID, PhotoId, MAPLABEL, FEATTYPE,
            Shape.STEndPoint().STY AS Latitude, Shape.STEndPoint().STX AS Longitude
          FROM
            #Misc_Ln
          WHERE
            FACASSETID IS NULL
        ) AS temp
      GROUP BY
        FACLOCID, PhotoId, MAPLABEL, FEATTYPE, Latitude, Longitude
      HAVING
        COUNT(*) = 1
    ) AS g1
  ) AS g 
ON
    g.FACLOCID = f.Location

-------------------------
--
--   assets.csv
--
-------------------------

-- Items in GIS matching FMSS Asset records

SELECT
  -- GIS
  g.Kind,
  COALESCE(g.FACASSETID, 'N/A') AS ID,
  g.[Name] AS [Name],
  g.Photo_Id,
  g.Latitude, g.Longitude,
  -- FMSS
  f.Location AS Parent,  
  COALESCE(f.[Description], COALESCE(g.[Desc], 'Not an FMSS Asset')) AS [Desc]
FROM
  akr_facility2.dbo.FMSSExport_Asset AS f
RIGHT JOIN
  (
      SELECT DISTINCT
        -- road features (asserts by default, has a photoID or FACASSETID)
        'Road' AS Kind,
        FACASSETID,
        PhotoID AS Photo_Id,
        FEATTYPE AS [Name],
        FEATDESC as [Desc],
        Shape.STY AS Latitude, Shape.STX AS Longitude
      FROM
        #Road_Feats
      WHERE
        FACASSETID IS NOT NULL OR PhotoId IS NOT NULL
    UNION ALL
      SELECT DISTINCT
        -- trail features (asserts by default, has a photoID or FACASSETID)
        'Trail' AS Kind,
        FACASSETID,
        PhotoID AS Photo_Id,
        FEATTYPE AS [Name],
        FEATDESC as [Desc],
        Shape.STY AS Latitude, Shape.STX AS Longitude
      FROM
        #Trail_Feats
      WHERE
        FACASSETID IS NOT NULL OR PhotoId IS NOT NULL
    UNION ALL
      -- trail attributes (surface material, etc) (asserts by default, has a photoID or FACASSETID)
      SELECT DISTINCT
        'Trail' AS Kind,
        FACASSETID,
        PhotoID AS Photo_Id,
        ATTTYPE AS [Name],
        ATTDESC as [Desc],
        Shape.STY AS Latitude, Shape.STX AS Longitude
      FROM
        #Trail_Atts
      WHERE
        FACASSETID IS NOT NULL OR PhotoId IS NOT NULL
    UNION ALL
      -- Buildings (Center Point) - Typically out-buildings that are grouped with a main structure
      SELECT
        'Building' AS Kind,
        FACASSETID,
        PhotoId AS Photo_Id,
        MAPLABEL AS [Name],
        BLDGTYPE as [Desc],
        Shape.STY AS Latitude, Shape.STX AS Longitude
      FROM
        #Buildings
      WHERE
        FACASSETID IS NOT NULL
    UNION ALL
      -- Parking Lots (Centroid)
      SELECT
        'Parking' AS Kind,
        FACASSETID,
        PhotoId AS Photo_Id,
        MAPLABEL AS [Name],
        '' as [Desc],
        --' (GIS: '+FORMAT(GEOGRAPHY::STGeomFromText(shape.STAsText(),4269).STArea() * 3.28084 * 3.28084,'N0') + 'sf)' as Size,
        Shape.STCentroid().STY AS Latitude, Shape.STCentroid().STX AS Longitude
      FROM
        #Parking
      WHERE
        FACASSETID IS NOT NULL
    UNION ALL
      -- Roads (All start and end points for a given FACASSETID that are not coincident
      --         with another end or start point respectively)
      SELECT
        'Road' AS Kind,
        g1.FACASSETID,
        g1.PhotoId AS Photo_Id,
        g1.MAPLABEL AS [Name],
        '' AS [Desc],
        -- ' (GIS: '+FORMAT(g2.Miles,'N2') + 'mi)' as Size,
        g1.Latitude, g1.Longitude
      FROM (
        SELECT 
          FACASSETID, PhotoId, MAPLABEL,
          Latitude, Longitude
        FROM (
            SELECT
              FACASSETID, PhotoId, MAPLABEL,
              Shape.STStartPoint().STY AS Latitude, Shape.STStartPoint().STX AS Longitude
            FROM
              #Roads
            WHERE
              FACASSETID IS NOT NULL AND ISBRIDGE <> 'Yes'
          UNION ALL
            SELECT
              FACASSETID, PhotoId, MAPLABEL,
              Shape.STEndPoint().STY AS Latitude, Shape.STEndPoint().STX AS Longitude
            FROM
              #Roads
            WHERE
              FACASSETID IS NOT NULL AND ISBRIDGE <> 'Yes'
          ) AS temp
        GROUP BY
          FACASSETID, PhotoId, MAPLABEL, Latitude, Longitude
        HAVING
          COUNT(*) = 1
      ) AS g1
      JOIN (
        SELECT
          FACASSETID, PhotoId, MAPLABEL,
          SUM(GEOGRAPHY::STGeomFromText(shape.STAsText(),4269).STLength()) * 0.000621371 as Miles
        FROM
          #Roads
        WHERE
          FACASSETID IS NOT NULL AND ISBRIDGE <> 'Yes'
        GROUP BY
          FACASSETID, PhotoId, MAPLABEL
      ) AS g2
      ON g1.FACASSETID = g2.FACASSETID
      AND COALESCE(g1.PhotoId,'') = COALESCE(g2.PhotoId,'') AND COALESCE(g1.MAPLABEL,'') = COALESCE(g2.MAPLABEL,'')
    UNION ALL
      -- Trails (All start and end points for a given FACASSETID that are not coincident
      --         with another end or start point respectively)
      SELECT
        'Trail' AS Kind,
        g1.FACASSETID,
        g1.PhotoId AS Photo_Id,
        g1.MAPLABEL AS [Name],
        '' AS [Desc],
        -- '(GIS: '+FORMAT(g2.Feet,'N0') + 'ft)' as Size,
        g1.Latitude, g1.Longitude
      FROM (
        SELECT 
          FACASSETID, PhotoId, MAPLABEL,
          Latitude, Longitude
        FROM (
            SELECT
              FACASSETID, PhotoId, MAPLABEL,
              Shape.STStartPoint().STY AS Latitude, Shape.STStartPoint().STX AS Longitude
            FROM
              #Trails
            WHERE
              FACASSETID IS NOT NULL AND ISBRIDGE <> 'Yes'
          UNION ALL
            SELECT
              FACASSETID, PhotoId, MAPLABEL,
              Shape.STEndPoint().STY AS Latitude, Shape.STEndPoint().STX AS Longitude
            FROM
              #Trails
            WHERE
              FACASSETID IS NOT NULL AND ISBRIDGE <> 'Yes'
          ) AS temp
        GROUP BY
          FACASSETID, PhotoId, MAPLABEL, Latitude, Longitude
        HAVING
          COUNT(*) = 1
      ) AS g1
      JOIN (
        SELECT
          FACASSETID, PhotoId, MAPLABEL,
          SUM(GEOGRAPHY::STGeomFromText(shape.STAsText(),4269).STLength()) * 3.28084 as Feet
        FROM
          #Trails
        WHERE
          FACASSETID IS NOT NULL AND ISBRIDGE <> 'Yes'
        GROUP BY
          FACASSETID, PhotoId, MAPLABEL
      ) AS g2
      ON g1.FACASSETID = g2.FACASSETID
      AND COALESCE(g1.PhotoId,'') = COALESCE(g2.PhotoId,'') AND COALESCE(g1.MAPLABEL,'') = COALESCE(g2.MAPLABEL,'')
    UNION ALL
      -- Trail Bridges (Middle vertex, or average of two middle vertices)
      SELECT
        'Bridge' AS Kind,
        FACASSETID,
        PhotoId AS Photo_Id,
        MAPLABEL AS [Name],
        '' AS [Desc],
        -- '' AS Size,
        -- Mid point of bridge
        CASE
          WHEN
            (Shape.STNumPoints() % 2) = 0
          THEN --Even number of vertices
            (Shape.STPointN(Shape.STNumPoints()/2).STY + Shape.STPointN(1 + Shape.STNumPoints()/2).STY)/2.0
          ELSE -- Odd
            Shape.STPointN(1 + Shape.STNumPoints()/2).STY
        END AS Latitude,
        CASE
          WHEN
            (Shape.STNumPoints() % 2) = 0
          THEN --Even
            (Shape.STPointN(Shape.STNumPoints()/2).STX + Shape.STPointN(1 + Shape.STNumPoints()/2).STX)/2.0
          ELSE -- Odd
            Shape.STPointN(1 + Shape.STNumPoints()/2).STX
        END AS Longitude
      FROM
        #Trails
      WHERE
        FACASSETID IS NOT NULL AND ISBRIDGE = 'Yes'
    UNION ALL
      -- Road Bridges (Middle vertex, or average of two middle vertices)
      SELECT
        'Bridge' AS Kind,
        FACASSETID,
        PhotoId AS Photo_Id,
        MAPLABEL AS [Name],
        '' AS [Desc],
        -- '' AS Size,
        -- Get mid point of bridge
        CASE
          WHEN
            (Shape.STNumPoints() % 2) = 0
          THEN --Even number of vertices
            (Shape.STPointN(Shape.STNumPoints()/2).STY + Shape.STPointN(1 + Shape.STNumPoints()/2).STY)/2.0
          ELSE -- Odd
            Shape.STPointN(1 + Shape.STNumPoints()/2).STY
        END AS Latitude,
        CASE
          WHEN
            (Shape.STNumPoints() % 2) = 0
          THEN --Even
            (Shape.STPointN(Shape.STNumPoints()/2).STX + Shape.STPointN(1 + Shape.STNumPoints()/2).STX)/2.0
          ELSE -- Odd
            Shape.STPointN(1 + Shape.STNumPoints()/2).STX
        END AS Longitude
      FROM
        #Roads
      WHERE
        FACASSETID IS NOT NULL AND ISBRIDGE = 'Yes'
    UNION ALL
      -- Miscellaneous points (Center Point)
      SELECT
        'Misc' AS Kind,
        FACASSETID,
        PhotoId AS Photo_Id,
        MAPLABEL AS [Name],
        '' AS [Desc],
        Shape.STY AS Latitude, Shape.STX AS Longitude
      FROM
        #Misc_Pt
      WHERE
        FACASSETID IS NOT NULL
    UNION ALL
      -- Miscellaneous polygons (centroid)
      SELECT
        'Misc' AS Kind,
        FACASSETID,
        PhotoId AS Photo_Id,
        MAPLABEL AS [Name],
        '' AS [Desc],
        Shape.STCentroid().STY AS Latitude, Shape.STCentroid().STX AS Longitude
      FROM
        #Misc_Py
      WHERE
        FACASSETID IS NOT NULL
    UNION ALL
      -- Miscellaneous lines (All start and end points for a given FACASSETID that are not coincident
      --         with another end or start point respectively)
      SELECT
        'Misc' AS Kind,
        g1.FACASSETID,
        g1.PhotoId AS Photo_Id,
        g1.MAPLABEL AS [Name],
        g1.FEATTYPE AS [Desc],
        g1.Latitude, Longitude
      FROM (
        SELECT 
          FACASSETID, PhotoId, MAPLABEL, FEATTYPE,
          Latitude, Longitude
        FROM (
            SELECT
              FACASSETID, PhotoId, MAPLABEL, FEATTYPE,
              Shape.STStartPoint().STY AS Latitude, Shape.STStartPoint().STX AS Longitude
            FROM
              #Misc_Ln
            WHERE
              FACASSETID IS NOT NULL
          UNION ALL
            SELECT
              FACASSETID, PhotoId, MAPLABEL, FEATTYPE,
              Shape.STEndPoint().STY AS Latitude, Shape.STEndPoint().STX AS Longitude
            FROM
              #Misc_Ln
            WHERE
              FACASSETID IS NOT NULL
          ) AS temp
        GROUP BY
          FACASSETID, PhotoId, MAPLABEL, FEATTYPE, Latitude, Longitude
        HAVING
          COUNT(*) = 1
      ) AS g1
  ) AS g 
ON
  g.FACASSETID = f.Asset


DROP TABLE #PhotoId_A;
DROP TABLE #PhotoId_F;
DROP TABLE #PhotoId_G;
DROP TABLE #PhotoId_L;
DROP TABLE #Buildings;
DROP TABLE #Parking;
DROP TABLE #Trails;
DROP TABLE #Trail_Feats
DROP TABLE #Trail_Atts
DROP TABLE #Roads;
DROP TABLE #Road_Feats
DROP TABLE #Misc_Pt
DROP TABLE #Misc_Py
DROP TABLE #Misc_Ln



-------------------------
--
--   parents.csv
--
-------------------------
SELECT  Parent, Location, Description, Asset_Code
FROM FMSSExport
WHERE Type <> 'SALVAGE'
  AND Parent IS NOT NULL
ORDER BY Parent, Location


-------------------------
--
--   all_assets.csv
--
-------------------------
SELECT Location, Asset, Description
FROM FMSSExport_Asset
WHERE [Description] NOT LIKE '%REMOVED%'
  AND [Location] IS NOT NULL
ORDER BY [Location]
