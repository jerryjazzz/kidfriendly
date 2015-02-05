

class FactualConsumer
  constructor: ->
    @app = depend('App')
    @placeDao = depend('PlaceDAO')
    @factualService = depend('FactualService')

  geoSearch: (options) ->
    @factualService.geoSearch(options)
    .then (factualPlaces) =>
      @correlateFactualPlaces(factualPlaces)

  correlateFactualPlaces: (factualPlaces) ->
    Assert.type(factualPlaces, Array)
   
    @placeDao.get (query) ->
      for factualPlace in factualPlaces
        factual_id = factualPlace.factual_id
        Assert.notNull(factual_id)
        query.orWhere({factual_id})

    .then (places) =>
      foundPlaces = Map.fromList(places, 'factual_id')

      ops = for factualPlace in factualPlaces
        foundPlace = foundPlaces[factualPlace.factual_id]
        if foundPlace?
          @app.log("updating place #{foundPlace.place_id} with factual #{factualPlace.factual_id}")
          patch = @updatePlaceWithFactualData(foundPlace, factualPlace)
          patch2 = @recalculateFactualBasedRanking(foundPlace.withPatch(patch))
          combinedPatch = ObjectUtil.merge(patch, patch2)
          @placeDao.apply(foundPlace, combinedPatch)
          {place_id: foundPlace.place_id, name: factualPlace.name}

        else
          @app.log("adding missing factual place: #{factualPlace.factual_id}")
          place = Place.make({})
          place = place.withPatch(@updatePlaceWithFactualData(place, factualPlace))
          place = place.withPatch(@recalculateFactualBasedRanking(place))
          @placeDao.insert(place)

      Promise.all(ops)

  updatePlaceWithFactualData: (place, factualPlace) ->
    # returns a patch
    patch =
      name: factualPlace.name
      factual_id: factualPlace.factual_id
      lat: factualPlace.latitude
      long: factualPlace.longitude
      rating: 0
      details:
        address: factualPlace.address
        hours: factualPlace.hours
        tel: factualPlace.tel
        website: factualPlace.website
        factual_raw:
          kids_goodfor: factualPlace.kids_goodfor
          kids_menu: factualPlace.kids_menu
          chain_id: factualPlace.chain_id
          chain_name: factualPlace.chain_name
          rating: factualPlace.rating
          smoking: factualPlace.smoking
          options_vegetarian: factualPlace.options_vegetarian
          options_vegan: factualPlace.options_vegan
          options_glutenfree: factualPlace.options_glutenfree
          options_lowfat: factualPlace.options_lowfat
          options_organic: factualPlace.options_organic
          options_healthy: factualPlace.options_healthy
    return patch

  recalculateFactualBasedRanking: (place, log = null) ->
    # returns a patch
    patch = {details: {}}

    factual_raw = place.details.factual_raw

    cond = (b, ifTrue, ifFalse) ->
      if b
        ifTrue
      else
        ifFalse

    cond3 = (b, ifTrue, ifFalse, ifNull) ->
      if not b?
        ifNull
      else if b
        ifTrue
      else
        ifFalse

    average = (list) ->
      if list.length == 0
        return 0

      sum = 0
      for i in list
        sum += i
      return sum / list.length

    kidsMenu = cond3(factual_raw.kids_menu, 5, 2, 3.5)
    healthyOptions = average([
      cond3(factual_raw.options_vegetarian, 5, 2, 3.5)
      cond3(factual_raw.options_vegan, 5, 2, 3.5)
      cond3(factual_raw.options_glutenfree, 5, 2, 3.5)
      cond3(factual_raw.options_lowfat, 5, 2, 3.5)
      cond3(factual_raw.options_organic, 5, 2, 3.5)
      cond3(factual_raw.options_healthy, 5, 2, 3.5)
    ])
    speedAndService = 4
    tableActivities = 3

    detailedRatings = {kidsMenu, healthyOptions, speedAndService, tableActivities}
    patch.details.detailedRatings = detailedRatings

    randomAdjustment = place.details.randomRatingAdjustment
    if not randomAdjustment?
      randomAdjustment = patch.details.randomRatingAdjustment = Math.random()

    detailedRatingsTotal = (detailedRatings.kidsMenu + detailedRatings.healthyOptions \
      + detailedRatings.speedAndService + detailedRatings.tableActivities)

    overallRating = 0

    # List of factors in the overall rating. Each of these numbers is in the range 0..1
    factors =
      goodforkids: cond3(factual_raw.kids_goodfor, 1.0, 0, 0.5)
      kidsmenu: cond3(factual_raw.kids_menu, 1.0, 0, 0.5)
      detailedRatingsTotal: detailedRatingsTotal / 20.0
      factualGenericRating: parseFloat(factual_raw.rating ? 3.5) / 5
      randomAdjustment: randomAdjustment

    # Now the final rating, with weighting
    overallRating = factors.goodforkids * 35 \
      + factors.kidsmenu * 15 \
      + factors.detailedRatingsTotal * 25 \
      + factors.factualGenericRating * 25 \
      + factors.randomAdjustment * 6 - 3

    overallRating = Math.min(overallRating, 100)
    overallRating = Math.max(overallRating, 0)

    patch.rating = Math.round(overallRating)

    return patch

provide('FactualConsumer', FactualConsumer)
