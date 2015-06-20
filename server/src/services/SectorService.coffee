
RadiusMeters = 10000

MetroAreas =
  phx:
    nw_corner:
      lat: 33.8707054
      long: -112.4747009
    se_corner:
      lat: 32.9519326
      long: -111.4447327

class SectorService

  constructor: ->
    @Sector = depend('dao/sector')
    @GeomUtil = depend('GeomUtil')

  sectorToLatLong: (sector_id) ->
    @Sector.findOne({sector_id})
    .then (sector) ->
      if sector?
        {lat: sector.lat, long: sector.long}

  initializeSectorRowsForMetroArea: ({name,dryRun}) ->
    details = MetroAreas[name]

    if not details?
      return Promise.reject("metro area not found: " + name)

    {nw_corner, se_corner} = details

    center_location =
      lat: (nw_corner.lat + se_corner.lat) / 2.0
      long: (nw_corner.long + se_corner.long) / 2.0

    latLongDelta = @GeomUtil.latLongDeltaFromDistance(center_location, RadiusMeters * 0.9)

    countX = Math.abs(nw_corner.lat - se_corner.lat) / latLongDelta.dlat
    countY = Math.abs(nw_corner.long - se_corner.long) / latLongDelta.dlong

    everySector = []
    for x in [0..countX]
      for y in [0..countY]
        everySector.push
          sector_id: "#{name}-#{x}-#{y}"
          radius_meters: RadiusMeters
          lat: nw_corner.lat + (se_corner.lat - nw_corner.lat) * x / countX
          long: nw_corner.long + (se_corner.long - nw_corner.long) * y / countY

    if dryRun
      return everySector

    Promise.map everySector, (sector) =>
      @Sector.insert(sector)

provide.class(SectorService)

provide 'admin-endpoint/sector', ->
  SectorService = depend('SectorService')
  Sector = depend('dao/sector')

  '/init': (req) ->
    SectorService.initializeSectorRowsForMetroArea(req.query)

  '/all': (req) ->
    Sector.find({})

  '/:sector_id/loc': (req) ->
    SectorService.sectorToLatLong(req.params.sector_id)