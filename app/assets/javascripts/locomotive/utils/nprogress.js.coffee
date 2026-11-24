parent = if $('.content').length > 0 then '.content' else '.wrapper'

if $(parent).length > 0
  NProgress.configure
    showSpinner:  false
    ease:         'ease'
    speed:        500
    parent:       parent
