
class FactualRating
  constructor: ->
  getExtendedRating: (place) ->

    factual_raw = place.details?.factual_raw ? {}

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

    randomAdjustment = place.details.randomRatingAdjustment
    if not randomAdjustment?
      randomAdjustment = place.details.randomRatingAdjustment = Math.random()

    detailedRatingsTotal = (detailedRatings.kidsMenu + detailedRatings.healthyOptions \
      + detailedRatings.speedAndService + detailedRatings.tableActivities)

    ###
    overallRating = 0

    # List of factors in the overall rating, with weighting.
    factors =
      goodforkids: cond3(factual_raw.kids_goodfor, 1.0, 0, 0.5) * 35
      kidsmenu: cond3(factual_raw.kids_menu, 1.0, 0, 0.5) * 15
      detailedRatingsTotal: (detailedRatingsTotal / 20.0) * 25
      factualGenericRating: (parseFloat(factual_raw.rating ? 3.5) / 5) * 26
      randomAdjustment: randomAdjustment * 6 - 3

    # Now the final rating, with weighting
    overallRating = 0
    for k,v of factors
      overallRating += v
    ###

    # Rating algorithm discussed in a meeting in Feb 2015
    factors =
      factual_base: (factual_raw.rating ? 4) / 5 * 100
      kids_goodfor: cond(factual_raw.kids_goodfor, 2, 0)
      kids_menu: cond(factual_raw.kids_menu, 2, 0)
      is_chain: cond(factual_raw.chain_id?, -10, 0)

    overallRating = 0
    for k,v of factors
      overallRating += v

    # Cap at 97, then add the random adjustment which might take it up to 100.
    overallRating = Math.min(overallRating, 97)
    overallRating = Math.max(overallRating, 0)

    overallRating += randomAdjustment * 3

    overallRating = Math.round(overallRating)

    return { detailedRatings, detailedRatingsTotal, randomAdjustment, factors, overallRating }

  recalculateFactualBasedRating: (place) ->
    extended = @getExtendedRating(place)
    place.rating = extended.overallRating
    place.details.detailedRatings = extended.detailedRatings
    place
  
provide('FactualRating', FactualRating)

