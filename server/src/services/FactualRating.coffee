
class FactualRating
  constructor: ->
    @tweaks = depend('Tweaks')

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

    factors =
      factual_base: (factual_raw.rating ? 4) / 5 * 100
      kids_goodfor: cond(factual_raw.kids_goodfor, @tweaks.get('rating.points.kids_goodfor'), 0)
      kids_menu: cond(factual_raw.kids_menu, @tweaks.get('rating.points.kids_menu'), 0)
      is_chain: cond(factual_raw.chain_id?, @tweaks.get('rating.points.is_chain'), 0)

    overallRating = 0
    for k,v of factors
      overallRating += v

    # Cap at 97, then add the random adjustment which might take it up to 100.
    randomPoints = @tweaks.get('rating.points.randomAdjustment')

    overallRating = Math.min(overallRating, 100 - randomPoints)
    overallRating = Math.max(overallRating, 0)

    overallRating += randomAdjustment * randomPoints

    overallRating = Math.round(overallRating)

    return { detailedRatings, detailedRatingsTotal, randomAdjustment, factors, overallRating }

  recalculateFactualBasedRating: (place) ->
    extended = @getExtendedRating(place)
    place.rating = extended.overallRating
    place.details.detailedRatings = extended.detailedRatings
    place
  
provide('FactualRating', FactualRating)

