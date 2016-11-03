class Dashing.Anotheralert extends Dashing.Widget

  ready: ->
    # This is fired when the widget is done being rendered

  onData: (data) ->
    # Handle incoming data
    # You can access the html node of this widget with `@node`
    # Example: $(@node).fadeOut().fadeIn() will make the node flash each time data comes in.

  @accessor 'difference', ->
    if @get('last')
      last = parseInt(@get('last'))
      current = parseInt(@get('current'))
      if last != 0
        diff = Math.abs(Math.round((current - last) / last * 100))
        "#{diff}%"
      else
        "0%"  

  @accessor 'arrow', ->
    if @get('last')
      if parseInt(@get('current')) > parseInt(@get('last')) then 'icon-arrow-up' else 'icon-arrow-down'    

  @accessor 'isTooGood', ->
    @get('current') > @get('last')

  @accessor 'isTooLow', ->
    @get('current') < @get('last') 

  @accessor 'isTheSame', ->
    @get('current') -  @get('last') == 0.0

  @accessor 'current', Dashing.AnimatedValue