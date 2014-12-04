
GoogleApi =
  apiKey: '***REMOVED***'
  browserApiKey: '***REMOVED***'
  nearbySearchUrl: 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
  detailsUrl: 'https://maps.googleapis.com/maps/api/place/details/json'
  photoUrl: 'https://maps.googleapis.com/maps/api/place/photo'

  convertPlaceResult: (place_id, googlePlace) ->

    photoUrl = null
    if (googlePhoto = googlePlace.photos?[0])?
      photoUrl = "#{GoogleApi.photoUrl}?maxwidth=88&photoreference=#{googlePhoto.photo_reference}&key=#{GoogleApi.browserApiKey}"

    rating = 70
    if googlePlace.rating?
      rating = parseFloat(googlePlace.rating) * 20

    return {
      place_id
      name: googlePlace.name
      location: googlePlace.location
      thumbnail_url: photoUrl
      open_now: googlePlace?.opening_hours?.open_now ? null
      rating
      price_level: googlePlace.price_level
      url: googlePlace.url
      googleData: googlePlace
    }
