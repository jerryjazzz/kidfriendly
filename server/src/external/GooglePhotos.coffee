
BaseUrl = 'https://maps.googleapis.com/maps/api/place/photo'

ThumbnailSize =
  width: 80
  height: 80

BigImageSize =
  width: 500
  height: 300

class GooglePhotos
  constructor: ->
    @browserApiKey = depend('google/BrowserApiKey')
    @Place = depend('dao/place')

  photoReferenceUrl: ({width, height}, photo_reference) ->
    if not photo_reference?
      return null
    "#{BaseUrl}?key=#{@browserApiKey}&maxwidth=#{width}&maxheight=#{height}&photoreference=#{photo_reference}"

  savePhotosForPlace: (place_id, googleDetails) ->
    # Use first image as the thumbnail, and the first landscape image as the 'big' image.
    thumbnail = googleDetails.photos?[0]

    landscape = do ->
      for photo in (googleDetails.photos ? [])
        if photo.width > photo.height
          return photo
      return thumbnail

    @Place.update2 {place_id},
      thumb_img_url: @photoReferenceUrl(ThumbnailSize, thumbnail?.photo_reference)
      big_img_url: @photoReferenceUrl(BigImageSize, landscape?.photo_reference)

provide.class(GooglePhotos)
