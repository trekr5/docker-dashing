class Dashing.Numbersuccess extends Dashing.Widget
  @accessor 'current', Dashing.AnimatedValue

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
    ""

  @accessor 'arrow', ->
    if @get('last')
      if parseInt(@get('current')) > parseInt(@get('last')) then 'icon-arrow-up' else 'icon-arrow-down'



  @accessor 'isTooGood', ->
    @get('current') > @get('last')

  @accessor 'isTooLow', ->
    @get('current') / @get('last') - @get('last') / @get('last')  <=  -0.10

#  @accessor 'isTheSame', ->
#    @get('current') -  @get('last') == 0.0


