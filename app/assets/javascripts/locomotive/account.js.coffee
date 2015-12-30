# #= require jquery
# #= require jquery_ujs
# #= require_self
# #= require underscore/underscore
# #= require locomotive/bootstrap-notify
# #= require ./utils/notify
# #= require bootstrap/dropdown
# #= require bootstrap/tab

# window.Locomotive =
#   mounted_on:   window.Locomotive.mounted_on
#   Views:        {}
#   Flags:        {}

# $ ->
#   _.each window.flash_messages, (couple) ->
#       Locomotive.notify couple[1], couple[0]
