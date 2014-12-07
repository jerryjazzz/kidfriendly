
GoogleApi =
  apiKey: '***REMOVED***'
  browserApiKey: '***REMOVED***'
  nearbySearchUrl: 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
  detailsUrl: 'https://maps.googleapis.com/maps/api/place/details/json'
  photoUrl: 'https://maps.googleapis.com/maps/api/place/photo'

  _createUrl: (photo, maxWidth) ->
    "#{GoogleApi.photoUrl}?maxwidth=#{maxWidth}&photoreference=#{photo.photo_reference}&key=#{GoogleApi.browserApiKey}"

  convertPlaceResult: (place_id, googlePlace) ->

    photoUrl = null
    photos =[]
    if (googlePlace.photos?.length >0)
      photoUrl = @_createUrl(googlePlace.photos[0], 88)
      for photo in  googlePlace.photos
        photos.push(@_createUrl(photo, 500))

    rating = 70
    if googlePlace.rating?
      rating = parseFloat(googlePlace.rating) * 20

    return {
      place_id
      name: googlePlace.name
      location: googlePlace.location
      thumbnail_url: photoUrl
      vicinity: googlePlace.vicinity
      phone:googlePlace.formatted_phone_number
      photos:photos
      open_now: googlePlace?.opening_hours?.open_now ? null
      rating
      price_level: googlePlace.price_level
      url: googlePlace.url
      googleData: googlePlace
    }
