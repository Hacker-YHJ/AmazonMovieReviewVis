require '../stylus/main.styl'
domready = require 'domready'
d3 = require 'd3'
colors = require './_color.coffee'
data = require './vis.json'

startYear = 2000
endYear = 2012
yearRange = endYear - startYear + 1
cellSize = 0
cellGap = 0
calendarGap = 0
calendarWidth = 0
calendarHeight = 0
width = 0
height = 0

$svg = null
$g = null
$text = null
$cells = null
$legend = null
$legendLeft = null
$legendRight = null
$gradient = []
$selectData = null

format = d3.time.format '%Y-%m-%d'

scale = d3.scale.linear().range([0, 1])
range = d3.extent(Object.keys(data).map (key) -> data[key].pScore)
scale.domain range

domready ->
  resize()
  window.addEventListener 'resize', onResize
  $selectData = document.getElementById('selectData')
  $selectData.addEventListener 'change', select

  $svg = d3.select 'main'
    .append 'svg'
    .attr 'width', width
    .attr 'height', height * 1.2
  $g = $svg.selectAll 'g'
      .data d3.range(startYear, endYear+1)
    .enter()
    .append 'g'
      .attr 'width', calendarWidth
      .attr 'height', calendarHeight
      .attr 'transform', (d, i) ->
        "translate(#{calendarGap*i + calendarWidth*i},#{calendarGap})"

  $text = $g.append 'text'
    .text (d) -> d
    .style 'text-anchor', 'middle'
    .attr 'transform', "translate(#{calendarWidth/2},#{calendarHeight+30})"


  ['legendCool', 'legendWarm', 'legendNeon'].forEach (e, i) ->
    $gradient[i] = $svg.append 'defs'
      .append 'linearGradient'
      .attr 'id', e
      .attr 'x1', "0%"
      .attr 'y1', "50%"
      .attr 'x2', "100%"
      .attr 'y2', "50%"

  legendColors = [
    [['white', 0], ['#DCEDC8', .25], ['#42B3D5', .45], ['#1A237E', .75], ['black', 1]]
    [['white', 0], ['#FEEB65', .3], ['#E4521B', .65], ['#4D342F', .85], ['black', 1]]
    [['white', 0], ['#FFECB3', .2], ['#E85285', .45], ['#6A1B9A', .65], ['black', 1]]
  ]
  legendColors.forEach (e, i) ->
    e.forEach (v) ->
      $gradient[i].append 'stop'
        .attr 'offset', "#{v[1]*100}%"
        .attr 'stop-color', v[0]
        .attr 'stop-opacity', 1

  $legend = $svg.selectAll '.legends'
    .data [0]
    .enter()
    .append 'rect'
    .attr 'class', 'legends'
    .attr 'height', cellSize * 2
    .attr 'width', cellSize*64
    .attr 'x', (d) ->
      (width - cellSize*64)/2
    .attr 'y', height + 60

  $legendLeft = $svg.append 'text'
    .text 0
    .style 'text-anchor', 'end'
    .attr 'transform', "translate(#{(width-cellSize*64)/2 - 20},#{calendarHeight+74})"

  $legendRight = $svg.append 'text'
    .text 0
    .style 'text-anchor', 'start'
    .attr 'transform', "translate(#{(width+cellSize*64)/2 + 20},#{calendarHeight+74})"

  $cells = $g.selectAll '.day'
    .data (d) -> d3.time.days(new Date(d, 0, 1), new Date(d+1, 0, 1))
    .enter()
    .append 'rect'
    .attr 'class', 'day'
    .attr 'width', cellSize
    .attr 'height', cellSize
    .attr 'y', (d) ->
      t = d3.time.weekOfYear(d)
      t * (cellSize + cellGap)
    .attr 'x', (d) ->
      d.getDay() * (cellSize + cellGap)
    .attr 'fill', 'transparent'
    .datum (d) ->
      {d: d, s: format(d)}

  $cells.append 'title'
    .text (d) -> d.s
  # $g.selectAll '.month'
  #   .data (d) -> d3.time.months(new Date(d, 0, 1), new Date(d + 1, 0, 1))
  #   .enter()
  #   .append 'path'
  #   .attr 'class', 'month'
  #   .attr 'd', monthPath
  $cells = $cells.filter (d) -> d.s of data
  $cells
    .attr 'fill', (d) ->
      colors.warm .1

  event = new Event 'change'
  $selectData.dispatchEvent event


resize = ->
  width = window.innerWidth*.9
  calendarGap = width/(yearRange*7 + (yearRange - 1)*1.2)
  calendarWidth = calendarGap*7
  height = calendarHeight = calendarGap*54
  cellSize = calendarWidth/(7 + (7 - 1)*.2)
  cellGap = cellSize * .2
  calendarGap *= 1.2

select = (e) ->
  vv = @value
  color = null
  legend = null
  switch vv
    when 'nScore'
      color = colors.cool
      legend = 'legendCool'
    when 'oScore'
      color = colors.neon
      legend = 'legendNeon'
    when 'tCount'
      color = colors.neon
      legend = 'legendNeon'
    else
      color = colors.warm
      legend = 'legendWarm'

  range = d3.extent(Object.keys(data).map (key) -> data[key][vv])
  scale.domain range

  $legendLeft.text range[0]
  $legendRight.text range[1]
  $legend.attr 'fill', "url(##{legend})"

  $cells.select 'title'
    .text (d) -> "#{d.s}: #{data[d.s][vv]}"
  $cells
    .transition()
    .delay (d, i, j) -> i*10 + j * 100
    .attr 'fill', (d) ->
      color(scale(data[d.s][vv]))

onResize = ->
  resize()
  $svg
    .attr 'width', width
    .attr 'height', height*1.2
  $svg.selectAll 'g'
    .attr 'width', calendarWidth
    .attr 'height', calendarHeight
    .attr 'transform', (d, i) ->
      "translate(#{calendarGap*i + calendarWidth*i},#{calendarGap})"
  $text
    .attr 'transform', "translate(#{calendarWidth/2},#{calendarHeight+30})"
  $cells
    .attr 'width', cellSize
    .attr 'height', cellSize
    .attr 'y', (d) ->
      t = d3.time.weekOfYear d.d
      t * (cellSize + cellGap)
    .attr 'x', (d) ->
      d.d.getDay() * (cellSize + cellGap)

  $legend
    .attr 'height', cellSize * 2
    .attr 'width', cellSize*64
    .attr 'x', (d) ->
      (width - cellSize*64)/2
    .attr 'y', height + 60
  $legendLeft
    .attr 'transform', "translate(#{(width-cellSize*64)/2 - 20},#{calendarHeight+74})"

  $legendRight
    .attr 'transform', "translate(#{(width+cellSize*64)/2 + 20},#{calendarHeight+74})"
