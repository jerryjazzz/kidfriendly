
class Place

  constructor: ({@name, @google_id, @id, @location}) ->

  @fromGooglePlace: (googlePlace) ->

    return new Place(
      google_id: googlePlace.place_id
      location: Location.fromGoogleLocation(googlePlace.geometry.location)
    )
