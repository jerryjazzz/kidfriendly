
provide 'Tweaks', class Tweaks
  constructor: ->
    @tweakValueDAO = depend('TweakValueDAO')
    @loaded = {}
    @loadAll()

  defaults:
    'rating.points.randomAdjustment': 3
    'sort.penalty_points_per_10mi': 10
    'rating.points.kids_goodfor': 2
    'rating.points.kids_menu': 2
    'rating.points.is_chain': -10

  loadAll: ->
    @tweakValueDAO.find(->).then (rows) =>
      for row in rows when @defaults[row.name]?
        @loaded[row.name] = row.value

  get: (name) ->
    if (found = @loaded[name])?
      return found
    if (found = @defaults[name])?
      return found

    throw new Error("tweak not found: #{name}")

  getAll: ->
    out = {}
    for k,v of @defaults
      out[k] = @get(k)
    out

  set: (name, value) ->
    console.log('value = ', value)
    where = (query) -> query.where({name})
    @tweakValueDAO.modifyOrInsert where, (tweak) =>
      tweak.name = name
      tweak.value = value
