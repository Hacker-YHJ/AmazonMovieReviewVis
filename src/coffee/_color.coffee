d3 = require 'd3'
d3ci = require 'd3-interpolate'
class Color
  constructor: (@c1, @c2, @c3, @s1, @s2, @s3) ->
    @l1 = d3ci.interpolate 'white', @c1
    @l2 = d3ci.interpolate @c1, @c2
    @l3 = d3ci.interpolate @c2, @c3
    @l4 = d3ci.interpolate @c3, 'black'
    @i1 = d3.scale.linear().range([0, 1]).domain([0, @s1])
    @i2 = d3.scale.linear().range([0, 1]).domain([@s1, @s2])
    @i3 = d3.scale.linear().range([0, 1]).domain([@s2, @s3])
    @i4 = d3.scale.linear().range([0, 1]).domain([@s3, 1])

  func: (i) =>
    if i < @s1
      return @l1(@i1(i))
    else if i >= @s1 and i < @s2
      return @l2(@i2(i))
    else if i >= @s2 and i < @s3
      return @l3(@i3(i))
    else if i >= @s3
      return @l4(@i4(i))

exports = module.exports =
  cool: new Color('#DCEDC8', '#42B3D5', '#1A237E', .25, .45, .75).func
  warm: new Color('#FEEB65', '#E4521B', '#4D342F', .3, .65, .85).func
  neon: new Color('#FFECB3', '#E85285', '#6A1B9A', .2, .45, .65).func
