  --Latitude,Longitude,FMSS_Id,Desc,Cost,Size,Status,Year,Occupant,Name,Park_Id,Photo_Id
  
  SELECT
  g.Shape.STY as Latitude, g.Shape.STX as Longitude, g.FACLOCID as ID, g.MAPLABEL as [Name],
  f.CRV as CRV, f.DM as DM, YEAR(GetDate()) - Try_Convert(int,f.YearBlt) as Age, f.Description as [Desc],
  f.Parent, f.Status as Status, 'warehouse' as [marker-symbol],
  COALESCE(FACLOCID, COALESCE(FEATUREID, COALESCE(FACASSETID, GEOMETRYID))) AS Photo_Id
  FROM [akr_facility2].[gis].[AKR_BLDG_CENTER_PT] as g
  JOIN [akr_facility2].[dbo].[FMSSExport] as f
  on g.FACLOCID = f.Location
  where g.FACLOCID is not null and f.[Type] = 'OPERATING'
  UNION
  SELECT
  g.Shape.STCentroid().STY as Latitude, g.Shape.STCentroid().STX as Longitude, g.FACLOCID as ID, g.MAPLABEL as [Name],
  f.CRV as CRV, f.DM as DM, YEAR(GetDate()) - Try_Convert(int,f.YearBlt) as Age, f.Description as [Desc],
  f.Parent, f.Status as Status, 'parking' as [marker-symbol],
  COALESCE(FACLOCID, COALESCE(FEATUREID, COALESCE(FACASSETID, GEOMETRYID))) AS Photo_Id 
  FROM [akr_facility2].[gis].[PARKLOTS_PY] as g
  JOIN [akr_facility2].[dbo].[FMSSExport] as f
  on g.FACLOCID = f.Location
  where g.FACLOCID is not null and f.[Type] = 'OPERATING'
  UNION
  SELECT
  g.Shape.STStartPoint().STY as Latitude, g.Shape.STStartPoint().STX as Longitude, g.FACLOCID as ID, g.MAPLABEL as [Name],
  f.CRV as CRV, f.DM as DM, YEAR(GetDate()) - Try_Convert(int,f.YearBlt) as Age, f.Description as [Desc],
  f.Parent, f.Status as Status, 'star' as [marker-symbol],
  COALESCE(FACLOCID, COALESCE(FEATUREID, COALESCE(FACASSETID, GEOMETRYID))) AS Photo_Id
  FROM [akr_facility2].[gis].[TRAILS_LN] as g
  JOIN [akr_facility2].[dbo].[FMSSExport] as f
  on g.FACLOCID = f.Location
  where g.FACLOCID is not null and f.[Type] = 'OPERATING'
  UNION
  SELECT
  g.Shape.STStartPoint().STY as Latitude, g.Shape.STStartPoint().STX as Longitude, g.FACLOCID as ID, g.MAPLABEL as [Name],
  f.CRV as CRV, f.DM as DM, YEAR(GetDate()) - Try_Convert(int,f.YearBlt) as Age, f.Description as [Desc],
  f.Parent, f.Status as Status, 'bus' as [marker-symbol],
  COALESCE(FACLOCID, COALESCE(FEATUREID, COALESCE(FACASSETID, GEOMETRYID))) AS Photo_Id
  FROM [akr_facility2].[gis].[ROADS_LN] as g
  JOIN [akr_facility2].[dbo].[FMSSExport] as f
  on g.FACLOCID = f.Location
  where g.FACLOCID is not null and f.[Type] = 'OPERATING'

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