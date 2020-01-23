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
--   facilities.csv
--
-------------------------

-- Facilities in GIS matching FMSS Location records

SELECT
    -- GIS Attributes
    g.Kind,
    g.FACLOCID AS ID, COALESCE(g.MAPLABEL, '') AS [Name],
    g.Latitude, g.Longitude,
    g.FACLOCID AS Photo_Id, -- FIXME (Pphotos may be linked to GEOMETRYID or FEATUREID or FACASSSETID)
    -- FMSS Attributes
    COALESCE(FORMAT(TRY_CAST(f.CRV AS FLOAT), 'C', 'en-us'), 'Unknown') AS CRV,
    COALESCE(FORMAT(TRY_CAST(f.DM AS FLOAT), 'C', 'en-us'), 'Unknown') AS DM,
    COALESCE(CONVERT(varchar, YEAR(GetDate()) - TRY_CONVERT(INT, f.YearBlt)) + ' yrs', 'Unknown') AS Age,
    f.Description AS [Desc],
    COALESCE(COALESCE(f.PARKNAME, f.PARKNUMB), '')  AS [Park_Id],
    f.Qty + ' ' + f.UM + g.Size as Size,
    f.Parent, f.Status AS [Status]
FROM
    akr_facility2.dbo.FMSSExport AS f
JOIN
    (
    -- Buildings (Center Point)
    SELECT
      'Building' AS Kind,
      FACLOCID, MAPLABEL,
      Shape.STY AS Latitude, Shape.STX AS Longitude,
      '' as Size
    FROM
      akr_facility2.gis.AKR_BLDG_CENTER_PT_evw
    WHERE 
      FACLOCID IS NOT NULL
  UNION ALL
    -- Parking Lots (Centroid)
    SELECT
      'Parking' AS Kind,
      FACLOCID, MAPLABEL,
      Shape.STCentroid().STY AS Latitude, Shape.STCentroid().STX AS Longitude,
      ' (GIS: '+FORMAT(GEOGRAPHY::STGeomFromText(shape.STAsText(),4269).STArea() * 3.28084 * 3.28084,'N0') + 'sf)' as Size
    FROM
      akr_facility2.gis.PARKLOTS_PY_evw
    WHERE 
      FACLOCID IS NOT NULL
  UNION ALL
    -- Trails (All start and end points for a given FACLOCID that are not coincident
    --         with another end or start point respectively)
    SELECT 
      'Trail' AS Kind,
      g1.FACLOCID, g1.MAPLABEL,
      g1.Latitude, g1.Longitude,
      '(GIS: '+FORMAT(g2.Feet,'N0') + 'ft)' as Size
    FROM (
      SELECT 
        FACLOCID, MAPLABEL,
        Latitude, Longitude
      FROM (
          SELECT
            FACLOCID, MAPLABEL,
            Shape.STStartPoint().STY AS Latitude, Shape.STStartPoint().STX AS Longitude
          FROM
            akr_facility2.gis.TRAILS_LN_evw
          WHERE
            FACLOCID IS NOT NULL AND ISBRIDGE = 'No'
        UNION ALL
          SELECT
            FACLOCID, MAPLABEL,
            Shape.STEndPoint().STY AS Latitude, Shape.STEndPoint().STX AS Longitude
          FROM
            akr_facility2.gis.TRAILS_LN_evw
          WHERE
            FACLOCID IS NOT NULL AND ISBRIDGE = 'No'
        ) AS temp
      GROUP BY
        FACLOCID, MAPLABEL, Latitude, Longitude
      HAVING
        COUNT(*) = 1
    ) AS g1
    JOIN (
      SELECT
        FACLOCID,
        SUM(GEOGRAPHY::STGeomFromText(shape.STAsText(),4269).STLength()) * 3.28084 as Feet
      FROM
        akr_facility2.gis.TRAILS_LN_evw
      WHERE
        FACLOCID IS NOT NULL
      GROUP BY
        FACLOCID
    ) AS g2
    ON g1.FACLOCID = g2.FACLOCID
  UNION ALL
    -- Roads (All start and end points for a given FACLOCID that are not coincident
    --         with another end or start point respectively)
    SELECT
      'Road' AS Kind,
      g1.FACLOCID, g1.MAPLABEL,
      g1.Latitude, g1.Longitude,
      ' (GIS: '+FORMAT(g2.Miles,'N2') + 'mi)' as Size
    FROM (
      SELECT 
        FACLOCID, MAPLABEL,
        Latitude, Longitude
      FROM (
          SELECT
            FACLOCID, MAPLABEL,
            Shape.STStartPoint().STY AS Latitude, Shape.STStartPoint().STX AS Longitude
          FROM
            akr_facility2.gis.ROADS_LN_evw
          WHERE
            FACLOCID IS NOT NULL AND ISBRIDGE = 'No'
        UNION ALL
          SELECT
            FACLOCID, MAPLABEL,
            Shape.STEndPoint().STY AS Latitude, Shape.STEndPoint().STX AS Longitude
          FROM
            akr_facility2.gis.ROADS_LN_evw
          WHERE
            FACLOCID IS NOT NULL AND ISBRIDGE = 'No'
        ) AS temp
      GROUP BY
        FACLOCID, MAPLABEL, Latitude, Longitude
      HAVING
        COUNT(*) = 1
    ) AS g1
    JOIN (
      SELECT
        FACLOCID,
        SUM(GEOGRAPHY::STGeomFromText(shape.STAsText(),4269).STLength()) * 0.000621371 as Miles
      FROM
        akr_facility2.gis.ROADS_LN_evw
      WHERE
        FACLOCID IS NOT NULL
      GROUP BY
        FACLOCID
    ) AS g2
    ON g1.FACLOCID = g2.FACLOCID
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
      '' AS Size
    FROM
      akr_facility2.gis.ROADS_LN_evw
    WHERE
      FACLOCID IS NOT NULL AND ISBRIDGE = 'Yes'
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
      '' AS Size
    FROM
      akr_facility2.gis.TRAILS_LN_evw
    WHERE
      FACLOCID IS NOT NULL AND ISBRIDGE = 'Yes'
  ) AS g 
ON
    g.FACLOCID = f.Location
WHERE
    f.[Type] = 'OPERATING'



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
  COALESCE(f.[Description], 'Not an FMSS Asset') AS [Desc]
FROM
  akr_facility2.dbo.FMSSExport_Asset AS f
RIGHT JOIN
  (
      SELECT
        -- trail features
        'Trail' AS Kind,
        f.FACASSETID,
        COALESCE(p.FACLOCID, COALESCE(p.FACASSETID, COALESCE(p.FEATUREID, p.GEOMETRYID))) AS Photo_Id,
        CASE WHEN f.TRLFEATTYPE = 'Other' THEN f.TRLFEATTYPEOTHER ELSE f.TRLFEATTYPE END + 
          CASE WHEN f.TRLFEATSUBTYPE is NULL THEN '' ELSE ', ' + f.TRLFEATSUBTYPE END AS [Name],
        f.Shape.STY AS Latitude, f.Shape.STX AS Longitude
      FROM
        akr_facility2.gis.TRAILS_FEATURE_PT_evw AS f
      JOIN
        akr_facility2.gis.AKR_ATTACH_evw AS p
      ON
        -- FIXME Breaks if a ATTACH has more than one foreign key (i.e. a photo of more than one object)
        f.GEOMETRYID = p.GEOMETRYID OR f.FEATUREID = p.FEATUREID 
        --f.FACLOCID = p.FACLOCID OR f.FACASSETID = p.FACASSETID OR f.FEATUREID = p.FEATUREID OR f.GEOMETRYID = p.GEOMETRYID
      WHERE
        f.FACASSETID IS NOT NULL OR p.ATCHLINK IS NOT NULL
    UNION ALL
      -- trail attributes (surface material, etc)
      SELECT
        'Trail' AS Kind,
        a.FACASSETID,
        COALESCE(p.FACLOCID, COALESCE(p.FACASSETID, COALESCE(p.FEATUREID, p.GEOMETRYID))) AS Photo_Id,
        CASE WHEN a.TRLATTRTYPE = 'Other' THEN a.TRLATTRTYPEOTHER ELSE a.TRLATTRTYPE END + 
          CASE WHEN a.TRLATTRVALUE is NULL THEN '' ELSE ', ' + a.TRLATTRVALUE END AS [Name],
        a.Shape.STY AS Latitude, a.Shape.STX AS Longitude
      FROM
        akr_facility2.gis.TRAILS_ATTRIBUTE_PT_evw AS a
      JOIN
        akr_facility2.gis.AKR_ATTACH_evw AS p
      ON
        -- FIXME Breaks if a ATTACH has more than one foreign key (i.e. a photo of more than one object)
        -- FIXME: The general solution is VERY! slow
        a.FACLOCID = p.FACLOCID -- OR a.FACASSETID = p.FACASSETID OR a.FEATUREID = p.FEATUREID OR a.GEOMETRYID = p.GEOMETRYID
      WHERE
        a.FACASSETID IS NOT NULL OR p.ATCHLINK IS NOT NULL
    UNION ALL
      -- Buildings (typically out-buildings that are grouped with a main structure)
      SELECT
        'Building' AS Kind,
        FACASSETID,
        FACASSETID AS Photo_Id,
        MAPLABEL AS [Name],
        Shape.STY AS Latitude, Shape.STX AS Longitude
      FROM
        akr_facility2.gis.AKR_BLDG_CENTER_PT_evw
      WHERE
        FACASSETID IS NOT NULL AND FACLOCID IS NULL
  ) AS g 
ON
  g.FACASSETID = f.Asset



-------------------------
--
--   children.csv
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
