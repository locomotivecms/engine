Locomotive.Views.Import ||= {}

class Locomotive.Views.Import.ShowView extends Backbone.View

  el: '#content'

  render: ->
    super

    @enable_updating()

  enable_updating: ->
    @updater = @$('#import-steps').smartupdater
      url :       @$('#import-steps').attr('data-url')
      dataType:   'json'
      minTimeout: 300,
      @refresh_steps

  refresh_steps: (data) =>
    window.foo = data
    window.bar = @

    if data.step == 'done'
      $('#import-steps li').addClass('done')
      $.growl 'notice', @$('#import-steps').attr('data-success-message')
    else
      steps         = ['site', 'content_types', 'assets', 'snippets', 'pages']
      current_index = steps.indexOf(data.step) || 0

      _.each steps, (step, index) =>
        state = null

        if index == current_index + 1 && data.failed then state = 'failed'
        if (index <= current_index) then state = 'done'

        @$("#import-steps li:eq(#{index})").addClass(state) if state?

      if data.failed
        $.growl 'alert', @$('#import-steps').attr('data-failure-message')

    if data.step == 'done' || data.failed
      @updater.smartupdater('stop')

  remove: ->
    super
    @updater.smartupdater('stop') if @updater?