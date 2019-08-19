--Select  [marker-symbol], ID, count(*) from (
    SELECT
    g.FACLOCID as ID, g.MAPLABEL as [Name], g.Shape.STY as Latitude, g.Shape.STX as Longitude,
    f.CRV as CRV, f.DM as DM, YEAR(GetDate()) - Try_Convert(int,f.YearBlt) as Age, f.Description as [Desc],
    f.Parent, f.Status as Status, 'warehouse' as [marker-symbol],
    COALESCE(FACLOCID, COALESCE(FEATUREID, COALESCE(FACASSETID, GEOMETRYID))) AS Photo_Id
    FROM [akr_facility2].[gis].[AKR_BLDG_CENTER_PT] as g
    JOIN [akr_facility2].[dbo].[FMSSExport] as f
    on g.FACLOCID = f.Location
    where g.FACLOCID is not null and f.[Type] = 'OPERATING'
  UNION
    SELECT
    g.FACLOCID as ID, g.MAPLABEL as [Name], g.Shape.STCentroid().STY as Latitude, g.Shape.STCentroid().STX as Longitude,
    f.CRV as CRV, f.DM as DM, YEAR(GetDate()) - Try_Convert(int,f.YearBlt) as Age, f.Description as [Desc],
    f.Parent, f.Status as Status, 'parking' as [marker-symbol],
    COALESCE(FACLOCID, COALESCE(FEATUREID, COALESCE(FACASSETID, GEOMETRYID))) AS Photo_Id 
    FROM [akr_facility2].[gis].[PARKLOTS_PY] as g
    JOIN [akr_facility2].[dbo].[FMSSExport] as f
    on g.FACLOCID = f.Location
    where g.FACLOCID is not null and f.[Type] = 'OPERATING'
  UNION
    SELECT g.ID, g.[Name], g.Latitude, g.Longitude,
    f.CRV as CRV, f.DM as DM, YEAR(GetDate()) - Try_Convert(int,f.YearBlt) as Age, f.Description as [Desc],
    f.Parent, f.Status as Status, 'star' as [marker-symbol],
    g.ID AS Photo_Id
    FROM (
            Select ID, Latitude, Longitude, [Name] FROM (
                SELECT
                Shape.STStartPoint().STY as Latitude, Shape.STStartPoint().STX as Longitude, FACLOCID as ID, MAPLABEL as [Name]
                FROM [akr_facility2].[gis].[TRAILS_LN] where faclocid is not null and ISBRIDGE = 'No'
                UNION ALL
                SELECT
                Shape.STEndPoint().STY as Latitude, Shape.STEndPoint().STX as Longitude, FACLOCID as ID, MAPLABEL as [Name]
                FROM [akr_facility2].[gis].[TRAILS_LN] where faclocid is not null and ISBRIDGE = 'No'
            ) as t
            group by ID, Latitude, Longitude, [Name] having count(*) = 1
    ) as g
    JOIN [akr_facility2].[dbo].[FMSSExport] as f
    on g.ID = f.Location
    where f.[Type] = 'OPERATING'
  UNION
    SELECT g.ID, g.[Name], g.Latitude, g.Longitude,
    f.CRV as CRV, f.DM as DM, YEAR(GetDate()) - Try_Convert(int,f.YearBlt) as Age, f.Description as [Desc],
    f.Parent, f.Status as Status, 'bus' as [marker-symbol],
    g.ID AS Photo_Id
    FROM (
            Select ID, Latitude, Longitude, [Name] FROM (
                SELECT
                Shape.STStartPoint().STY as Latitude, Shape.STStartPoint().STX as Longitude, FACLOCID as ID, MAPLABEL as [Name]
                FROM [akr_facility2].[gis].[ROADS_LN] where faclocid is not null and ISBRIDGE = 'No'
                UNION ALL
                SELECT
                Shape.STEndPoint().STY as Latitude, Shape.STEndPoint().STX as Longitude, FACLOCID as ID, MAPLABEL as [Name]
                FROM [akr_facility2].[gis].[ROADS_LN] where faclocid is not null and ISBRIDGE = 'No'
            ) as t
            group by ID, Latitude, Longitude, [Name] having count(*) = 1
    ) as g
    JOIN [akr_facility2].[dbo].[FMSSExport] as f
    on g.ID = f.Location
    where f.[Type] = 'OPERATING'
  UNION
    SELECT
    g.FACLOCID as ID, g.MAPLABEL as [Name],
    -- Get mid point of bridge
    CASE WHEN (g.Shape.STNumPoints() % 2) = 0
    THEN --Even number of vertices
       (g.Shape.STPointN(g.Shape.STNumPoints()/2).STY + g.Shape.STPointN(1 + g.Shape.STNumPoints()/2).STY)/2.0
    ELSE -- Odd
       g.Shape.STPointN(1 + g.Shape.STNumPoints()/2).STY
    END  as Latitude,
    CASE WHEN (g.Shape.STNumPoints() % 2) = 0
    THEN --Even
       (g.Shape.STPointN(g.Shape.STNumPoints()/2).STX + g.Shape.STPointN(1 + g.Shape.STNumPoints()/2).STX)/2.0
    ELSE -- Odd
       g.Shape.STPointN(1 + g.Shape.STNumPoints()/2).STX
    END as Longitude,
    f.CRV as CRV, f.DM as DM, YEAR(GetDate()) - Try_Convert(int,f.YearBlt) as Age, f.Description as [Desc],
    f.Parent, f.Status as Status, 'square' as [marker-symbol],
    COALESCE(FACLOCID, COALESCE(FEATUREID, COALESCE(FACASSETID, GEOMETRYID))) AS Photo_Id 
    FROM [akr_facility2].[gis].[ROADS_LN] as g
    JOIN [akr_facility2].[dbo].[FMSSExport] as f
    on g.FACLOCID = f.Location
    where g.FACLOCID is not null and g.ISBRIDGE = 'Yes' and f.[Type] = 'OPERATING'   
  UNION
    SELECT
    g.FACLOCID as ID, g.MAPLABEL as [Name],
    -- Get mid point of bridge
    CASE WHEN (g.Shape.STNumPoints() % 2) = 0
    THEN --Even number of vertices
       (g.Shape.STPointN(g.Shape.STNumPoints()/2).STY + g.Shape.STPointN(1 + g.Shape.STNumPoints()/2).STY)/2.0
    ELSE -- Odd
       g.Shape.STPointN(1 + g.Shape.STNumPoints()/2).STY
    END  as Latitude,
    CASE WHEN (g.Shape.STNumPoints() % 2) = 0
    THEN --Even
       (g.Shape.STPointN(g.Shape.STNumPoints()/2).STX + g.Shape.STPointN(1 + g.Shape.STNumPoints()/2).STX)/2.0
    ELSE -- Odd
       g.Shape.STPointN(1 + g.Shape.STNumPoints()/2).STX
    END as Longitude,
    f.CRV as CRV, f.DM as DM, YEAR(GetDate()) - Try_Convert(int,f.YearBlt) as Age, f.Description as [Desc],
    f.Parent, f.Status as Status, 'square' as [marker-symbol],
    COALESCE(FACLOCID, COALESCE(FEATUREID, COALESCE(FACASSETID, GEOMETRYID))) AS Photo_Id 
    FROM [akr_facility2].[gis].[TRAILS_LN] as g
    JOIN [akr_facility2].[dbo].[FMSSExport] as f
    on g.FACLOCID = f.Location
    where g.FACLOCID is not null and g.ISBRIDGE = 'Yes' and f.[Type] = 'OPERATING'   
--) as t
--group by [marker-symbol], ID having count(*) > 1
--order by [marker-symbol], count(*) DESC, ID

/*  Original Building Query

 	 SELECT P.Shape.STY AS Latitude,  P.Shape.STX AS Longitude, P.FACLOCID as FMSS_Id,
	        COALESCE(F.[Description], P.MAPLABEL) AS [Desc],
	        COALESCE(FORMAT(CAST(F.CRV AS float), 'C', 'en-us'), 'unknown') AS Cost,
--			COALESCE(FORMAT(F.Qty, '0,0 Sq Ft', 'en-us'), 'unknown') AS Size, F.[Status] AS [Status], 
			'unknown' AS Size, P.BLDGSTATUS AS [Status],
			COALESCE(CAST(F.YearBlt AS nvarchar), 'unknown') AS [Year], P.FACOCCUPANT AS Occupant,
			P.BLDGNAME AS [Name], P.PARKBLDGID AS Park_Id,
            COALESCE(FACLOCID, COALESCE(FEATUREID, COALESCE(FACASSETID, GEOMETRYID))) AS Photo_Id
       FROM gis.AKR_BLDG_CENTER_PT_evw as P
  LEFT JOIN dbo.FMSSEXPORT as F
         ON P.FACLOCID = F.Location
	  WHERE P.ISEXTANT = 'True' AND (P.FACLOCID IS NOT NULL OR (P.ISOUTPARK <> 'Yes' AND P.FACMAINTAIN IN ('NPS','FEDERAL')))

*/