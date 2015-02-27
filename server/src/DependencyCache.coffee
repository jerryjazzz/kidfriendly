
class DependencyCache
  constructor: ->
    @providers = {}
    @cache = {}
    @currentlyResolving = {}

  depend: (name) ->
    if @cache[name]?
      return @cache[name]

    if @currentlyResolving[name]?
      error = new Error("Circular dependency with: " + name)
      error.dependencyList = [name]
      throw error

    @currentlyResolving[name] = true

    provider = @providers[name]

    if not provider?
      throw new Error("Unrecognized dependency name: " + name)

    try
      resolved = @callProvider(provider)
    catch e
      if e.dependencyList?
        list = e.dependencyList.concat([name])
        error = new Error("Circular dependency with: " + list)
        error.dependencyList = list
        throw error
      else
        throw e

    @cache[name] = resolved
    delete @currentlyResolving[name]
    return resolved

  dependOptional: (name) ->
    return @cache[name]

  callProvider: (provider) ->
    if provider.prototype?
      return new provider()
    else
      return provider()

  provide: (name, provider) ->
    if @providers[name]?
      throw new Error("Duplicate provider for: " + name)

    @providers[name] = provider

_globalDependencyCache = new DependencyCache()

depend = (name) ->
  return _globalDependencyCache.depend(name)

depend_optional = (name) ->
  return _globalDependencyCache.dependOptional(name)

provide = (name, provider) ->
  return _globalDependencyCache.provide(name, provider)

exports.depend = depend
exports.depend_optional = depend_optional
exports.provide = provide
