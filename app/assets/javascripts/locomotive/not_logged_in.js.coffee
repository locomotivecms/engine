#= require jquery
#= require_self
#= require underscore
#= require locomotive/bootstrap-notify
#= require ./utils/notify

window.Locomotive = {}

$ ->
  _.each window.flash_messages, (couple) ->
      Locomotive.notify couple[1], couple[0]

  # JavaScript to render the form wrapper vertically in the middle.

  $window = $(window)

  $window.resize ->
    console.log($(window).height() - 50)
    console.log($('.public-form-wrapper').height())
    if $('.public-form-wrapper').height() < ($(window).height() - 50)
      $('.public-form-wrapper').removeClass('is-fixed');
      $('.public-form-wrapper').css 'margin-top', -($('.public-form-wrapper').height() / 2)
    else
      $('.public-form-wrapper').addClass('is-fixed');
      $('.public-form-wrapper').css 'margin-top', 25
    return

  $window.trigger 'resize'
