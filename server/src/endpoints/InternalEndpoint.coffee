

class InternalEndpoint
  constructor: ->
    @app = depend('App')
    @placeDao = depend('PlaceDAO')
    @factualConsumer = depend('FactualConsumer')
    @defaultPath = '/internal'
    @route = require('express')()
    wrap = (f) -> ExpressUtil.wrap({}, f)

    @route.get '/places.csv', wrap (req) =>
      {limit} = req.query
      @placeDao.get((query) -> query.limit(limit ? 500))
      .then (places) =>
        lines = []
        lines.push("place_id,name,factual_rating,kids_menu,kids_goodfor,"\
          +"options_vegetarian,options_vegan," \
          +"options_glutenfree,options_lowfat,options_organic,options_healthy,," \
          +"details: kidsmenu,details:healthy,details:service,details:activities,," \
          +"points from goodforkids,points from kidsmenu,points from detailedRatings," \
          +"points from factual rating,random points," \
          +" overall rating,factual url")

        writeRow = (list) ->
          lines.push(list.join(","))

        shortenBool = (b) ->
          if not b? then return ' '
          if b then return 'y'
          'n'

        for place in places
          factual_raw = place.details?.factual_raw ? {}
          extendedRating = @factualConsumer.getExtendedRating(place)
          detailedRatings = extendedRating.detailedRatings
          writeRow([
            place.place_id,
            place.name,
            factual_raw.rating,
            shortenBool(factual_raw.kids_menu),
            shortenBool(factual_raw.kids_goodfor),
            shortenBool(factual_raw.options_vegetarian),
            shortenBool(factual_raw.options_vegan),
            shortenBool(factual_raw.options_glutenfree),
            shortenBool(factual_raw.options_lowfat),
            shortenBool(factual_raw.options_organic),
            shortenBool(factual_raw.options_healthy),
            '',
            detailedRatings.kidsMenu,
            detailedRatings.healthyOptions,
            detailedRatings.speedAndService,
            detailedRatings.tableActivities,
            '',
            extendedRating.factors.goodforkids,
            extendedRating.factors.kidsmenu,
            extendedRating.factors.detailedRatingsTotal,
            extendedRating.factors.factualGenericRating,
            Math.round(extendedRating.factors.randomAdjustment*100)/100,
            place.rating,
            place.getFactualUrl()
          ])

        {
          content: lines.join('\n')
          contentType: 'text/csv'
        }

      

provide('InternalEndpoint', InternalEndpoint)
