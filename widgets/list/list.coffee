class Dashing.List extends Dashing.Widget

    if @get('unordered')
      $(@node).find('ol').remove()
    else
      $(@node).find('ul').remove()  