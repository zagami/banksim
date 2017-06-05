if (!Array::sum)
  Array::sum = ->
    i = @length
    s = 0
    s += @[--i] while i > 0
    s

if (!Array::last)
  Array::last = ->
    i = @length
    if i > 0
      return @[i-1]
    else
      null

assert = (condition, message) ->
  if (!condition)
    message = message || "Assertion failed"
    if (typeof Error != "undefined")
      e = new Error(message)
      console.log e.stack
      alert message
      throw e
    throw message

randomize = (from, to) ->
  x = to - from
  parseFloat(from + x * Math.random())
  
randomizeInt = (from, to) ->
  x = to - from + 1
  Math.floor(from + x * Math.random())

module.exports.assert = assert
module.exports.randomize = randomize
module.exports.randomizeInt = randomizeInt

