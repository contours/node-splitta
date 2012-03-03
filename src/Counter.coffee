class Counter

  constructor: (@counts = {}) ->

  get: (entry) ->
    return @counts[entry] or 0

  count: (entry) ->
    @counts[entry] = @get(entry) + 1

  totalCount: ->
    counts = (count for entry,count of @counts)
    return 0 if counts.length == 0
    return counts.reduce (m,n) -> (m+n)

  normalize: ->
    total = @totalCount()
    counts = {}
    counts[entry] = (count / total) for entry,count of @counts
    return new Counter(counts)

exports.Counter = Counter