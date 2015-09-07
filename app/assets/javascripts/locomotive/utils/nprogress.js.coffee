parent = if $('.content').size() > 0 then '.content' else '.wrapper'

NProgress.configure
  showSpinner:  false
  ease:         'ease'
  speed:        500
  parent:       parent
