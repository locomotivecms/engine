parent = if $('.content').size() > 0 then '.content' else '.wrapper'

if $(parent).size() > 0
  NProgress.configure
    showSpinner:  false
    ease:         'ease'
    speed:        500
    parent:       parent
