class Morris.Area extends Morris.Line
  # Initialise
  #
  areaDefaults = 
    fillOpacity: 'auto'
    behaveLikeLine: false

  constructor: (options) ->
    return new Morris.Area(options) unless (@ instanceof Morris.Area)
    areaOptions = Morris.extend {}, areaDefaults, options

    @cumulative = not areaOptions.behaveLikeLine

    if areaOptions.fillOpacity is 'auto'
      areaOptions.fillOpacity = if areaOptions.behaveLikeLine then .8 else 1

    super(areaOptions)

  # calculate series data point coordinates
  #
  # @private
  calcPoints: ->
    for row in @data
      row._x = @transX(row.x)
      total = 0
      row._y = for y in row.y
        if @options.behaveLikeLine
          @transY(y)
        else
          total += (y || 0)
          @transY(total)
      row._ymax = Math.max row._y...

    for row, idx in @data
      @data[idx].label_x = []
      @data[idx].label_y = []
      for index in [@options.ykeys.length-1..0]
        if row._y[index]?
          @data[idx].label_x[index] = row._x
          @data[idx].label_y[index] = row._y[index] - 10
        
        if row._y2?
          if row._y2[index]?
            @data[idx].label_x[index] = row._x
            @data[idx].label_y[index] = row._y2[index] - 10

  # draw the data series
  #
  # @private
  drawSeries: ->
    @seriesPoints = []
    if @options.behaveLikeLine
      range = [0..@options.ykeys.length-1]
    else
      range = [@options.ykeys.length-1..0]

    for i in range
      @_drawFillFor i
      @_drawLineFor i
      @_drawPointFor i

  _drawFillFor: (index) ->
    path = @paths[index]
    if path isnt null
      path = path + "L#{@transX(@xmax)},#{@bottom}L#{@transX(@xmin)},#{@bottom}Z"
      @drawFilledPath path, @fillForSeries(index), index

  fillForSeries: (i) ->
    color = Raphael.rgb2hsl @colorFor(@data[i], i, 'line')
    Raphael.hsl(
      color.h,
      if @options.behaveLikeLine then color.s * 0.9 else color.s * 0.75,
      Math.min(0.98, if @options.behaveLikeLine then color.l * 1.2 else color.l * 1.25))

  drawFilledPath: (path, fill, areaIndex) ->
    if @options.animate
      straightPath = ''
      straightPath = 'M'+@data[0]._x+','+@transY(@ymin)
      straightPath += ','+@data[@data.length-1]._x+','+@transY(@ymin)

      for row, ii in @data by -1
        if straightPath == ''
          straightPath = 'M'+row._x+','+@transY(@ymin)
        else
          straightPath += ','+row._x+','+@transY(@ymin)

      straightPath += 'Z';
      rPath = @raphael.path(straightPath)
                      .attr('fill', fill)
                      .attr('fill-opacity', this.options.fillOpacity)
                      .attr('stroke', 'none')
      do (rPath, path) =>
        rPath.animate {path}, 500, '<>'
    else
      @raphael.path(path)
        .attr('fill', fill)
        .attr('fill-opacity', @options.fillOpacity)
        .attr('stroke', 'none')
