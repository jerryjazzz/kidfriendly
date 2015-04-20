
provide 'view/placesCSV', ->
  factualRating = depend('FactualRating')

  (data) ->
    lines = []
    lines.push("place_id,name,factual_rating,kids_menu,kids_goodfor,"\
      +"options_vegetarian,options_vegan," \
      +"options_glutenfree,options_lowfat,options_organic,options_healthy,," \
      +"details: kidsmenu,details:healthy,details:service,details:activities,," \
      +"points from factual,points from kids_goodfor,points from kids_menu," \
      +"points from is_chain,random points," \
      +" overall rating,factual url")

    writeRow = (list) ->
      lines.push(list.join(","))

    shortenBool = (b) ->
      if not b? then return ' '
      if b then return 'y'
      'n'

    for place in data.places
      factual_raw = place.details?.factual_raw ? {}
      extendedRating = factualRating.getExtendedRating(place)
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
        extendedRating.factors.factual_base,
        extendedRating.factors.kids_goodfor,
        extendedRating.factors.kids_menu,
        extendedRating.factors.is_chain,
        extendedRating.factors.random_adjustment,
        extendedRating.overallRating,
        place.getFactualUrl()
      ])

    return {
      content: lines.join('\n')
      contentType: 'text/csv'
    }

