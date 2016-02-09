#= require_self
#= require_tree ./utils
#= require_tree ./views

window.Locomotive =
  mounted_on:   window.Locomotive.mounted_on
  Views:        { Sessions: {}, Registrations: {}, Passwords: {}, CustomFields: {}  }
  Flags:        {}
