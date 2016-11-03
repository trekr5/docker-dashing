class Dashing.Number extends Dashing.Widget

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

  @accessor 'isTooLow', ->
    @get('current') / @get('last') - @get('last') / @get('last')  >=  2.00 

  @accessor 'isTooGood', ->
    @get('current') < @get('last') #green

  @accessor 'isTheSame', ->
    @get('current') -  @get('last') == 0.0

  onData: (data) ->
    if data.status
      # clear existing "status-*" classes
      $(@get('node')).attr 'class', (i,c) ->
        c.replace /\bstatus-\S+/g, ''
      # add new class
      $(@get('node')).addClass "status-#{data.status}"  

  @accessor 'current', Dashing.AnimatedValue
  @accessor 'last', Dashing.AnimatedValue
