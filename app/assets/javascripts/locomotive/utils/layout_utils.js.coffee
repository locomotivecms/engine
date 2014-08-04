
$ ->

  #
  # same height columns
  #

  jQuery.fn.equalize = ->

    items = @
    max   = -1

    @find_max = ->
      $(items).each ()->
        # console.log(max)
        h = $(@).height()
        max = Math.max(h, max)
    @apply_max = ->
      $(items).css 'min-height': max

    @find_max()
    @apply_max()
    @

  $('section.main > *').equalize()
