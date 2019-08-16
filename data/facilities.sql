  -- Create a file called facilities.csv in this folder with the following SQL command.

  SELECT
  g.Shape.STY as Latitude, g.Shape.STX as Longitude, g.FACLOCID as ID, g.MAPLABEL as [Name],
  f.CRV as CRV, f.DM as DM, YEAR(GetDate()) - Try_Convert(int,f.YearBlt) as Age, f.Description as [Desc],
  f.Parent, f.Status as Status, 'warehouse' as [marker-symbol] 
  FROM [akr_facility2].[gis].[AKR_BLDG_CENTER_PT] as g
  JOIN [akr_facility2].[dbo].[FMSSExport] as f
  on g.FACLOCID = f.Location
  where g.FACLOCID is not null and f.[Type] = 'OPERATING'
  UNION
  SELECT
  g.Shape.STCentroid().STY as Latitude, g.Shape.STCentroid().STX as Longitude, g.FACLOCID as ID, g.MAPLABEL as [Name],
  f.CRV as CRV, f.DM as DM, YEAR(GetDate()) - Try_Convert(int,f.YearBlt) as Age, f.Description as [Desc],
  f.Parent, f.Status as Status, 'parking' as [marker-symbol] 
  FROM [akr_facility2].[gis].[PARKLOTS_PY] as g
  JOIN [akr_facility2].[dbo].[FMSSExport] as f
  on g.FACLOCID = f.Location
  where g.FACLOCID is not null and f.[Type] = 'OPERATING'
  UNION
  SELECT
  g.Shape.STStartPoint().STY as Latitude, g.Shape.STStartPoint().STX as Longitude, g.FACLOCID as ID, g.MAPLABEL as [Name],
  f.CRV as CRV, f.DM as DM, YEAR(GetDate()) - Try_Convert(int,f.YearBlt) as Age, f.Description as [Desc],
  f.Parent, f.Status as Status, 'star' as [marker-symbol] 
  FROM [akr_facility2].[gis].[TRAILS_LN] as g
  JOIN [akr_facility2].[dbo].[FMSSExport] as f
  on g.FACLOCID = f.Location
  where g.FACLOCID is not null and f.[Type] = 'OPERATING'
  UNION
  SELECT
  g.Shape.STStartPoint().STY as Latitude, g.Shape.STStartPoint().STX as Longitude, g.FACLOCID as ID, g.MAPLABEL as [Name],
  f.CRV as CRV, f.DM as DM, YEAR(GetDate()) - Try_Convert(int,f.YearBlt) as Age, f.Description as [Desc],
  f.Parent, f.Status as Status, 'bus' as [marker-symbol] 
  FROM [akr_facility2].[gis].[ROADS_LN] as g
  JOIN [akr_facility2].[dbo].[FMSSExport] as f
  on g.FACLOCID = f.Location
  where g.FACLOCID is not null and f.[Type] = 'OPERATING'
