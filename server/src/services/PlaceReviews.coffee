
provide 'PlaceReviews', class PlaceReviews
  constructor: ->
    @db = depend('db')
    @Review = depend('Review')
    @Place = depend('Place')

  getWithReviews: (placeId) ->

    query = @db.select('place.place_id','name','lat','long','rating','factual_id','details',
    'reviewer_name', 'body', 'review_id', 'review.created_at', 'review.updated_at').from('place')
    .leftOuterJoin('review', 'place.place_id', 'review.place_id').where('place.place_id', placeId)
    query.toSQL()
    query.then (rows) =>
      if rows? and rows.length > 0
        place = @Place.fromDatabase(rows[0])
        for row in rows
          if row.review_id?
            place.reviews.push @Review.fromDatabase(row)
        place

