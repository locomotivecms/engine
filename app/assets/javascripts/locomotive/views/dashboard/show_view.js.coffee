Locomotive.Views.Dashboard ||= {}

class Locomotive.Views.Dashboard.ShowView extends Backbone.View

  el: '.main'

  infinite_activity_button: 'a[data-behavior~=load-more]'

  events:
    'ajax:beforeSend  a[data-behavior~=load-more]': 'loading_activity_feed'
    'ajax:success     a[data-behavior~=load-more]': 'refresh_activity_feed'

  render: ->
    super

    # replace the img by the name of the file
    @$('.assets img').error ->
      $(this).parent().html($(this).attr('alt'))

  loading_activity_feed: (event) -> $(event.target).button('loading')

  refresh_activity_feed: (event, data, status, xhr) ->
    $btn      = $(event.target).button('reset')
    $last     = @$('.activity-feed > li:last-child')
    $response = $(data)

    # add new activity items
    $response.find('.activity-feed > li').appendTo(@$('.activity-feed'))

    # display or not the load more button
    if ($new_btn = $response.find(@infinite_activity_button)).size() > 0
      $btn.replaceWith($new_btn)
    else
      @$(@infinite_activity_button).hide()

    # scroll to see the new items
    $(@el).parent().animate scrollTop: $last.offset().top + 'px', 2000
