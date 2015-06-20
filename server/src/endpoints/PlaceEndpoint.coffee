
Factual = require('factual-api')
Promise = require('bluebird')

provide 'endpoint/api/place', ->
  Place = depend('dao/place')
  PlaceReviews = depend('PlaceReviews')
  FactualRating = depend('FactualRating')
  MyPlaceDetails = depend('MyPlaceDetails')

  getPlaceDetails = (req) ->
    {place_id} = req.params
    Place.findById(place_id)
    .then (place) ->
      if not place?
        return {error: "Place not found", place_id: place_id}
      place.toClient()
    .then (place) ->
      MyPlaceDetails.maybeAnnotateOne(req, place)

  '/:place_id/explain': (req) ->
    {place_id} = req.params
    Place.findById(place_id)
    .then (place) ->
      if not place?
        return {error: "Place not found", place_id: place_id}

      factualRating = FactualRating.getExtendedRating(place)
      {raw: place, factualRating: factualRating}

  '/:place_id': getPlaceDetails
  '/:place_id/details': getPlaceDetails

  '/:place_id/details/reviews': (req) ->
    {place_id} = req.params
    PlaceReviews.getWithReviews(place_id)
    .then (place) ->
      if not place?
        return Promise.reject({error: "Place not found", place_id: place_id})
      place.toClient()
    .then (place) ->
      MyPlaceDetails.maybeAnnotateOne(req, place)

  '/any': (req) ->
    Place.find((query) -> query.limit(1))
    .then (places) ->
      places[0].toClient()

  ###
  post @route, '/new', (req) =>
    manualId = req.body.place_id # usually null
    place =
      place_id: manualId
      name: req.body.name
      location: req.body.location
      google_id: req.body.google_id
      created_at: Timestamp()
      source_ver: @app.sourceVersion

    @app.insert('place',place)

  get @route, '/:place_id/rerank', (req) =>

    where = switch
      when req.params.place_id == 'all'
        ->
      else
        (query) -> query.where(place_id: req.params.place_id)

    Place.modifyMulti where, (place) =>
      FactualRating.recalculateFactualBasedRating(place)
  ###


provide 'admin-endpoint/place', ->
  Place = depend('dao/place')
  FactualService = depend('FactualService')

  '/:place_id/factual': (req) ->
    Place.findById(req.params.place_id)
    .then (place) ->
      FactualService.singlePlace(place.factual_id)

  '/:place_id/factual/refresh': (req) ->
    Place.findById(req.params.place_id)
    .then (place) ->
      FactualService.singlePlace(place.factual_id)
    
