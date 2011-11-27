class Locomotive.Models.Site extends Backbone.Model

  paramRoot: 'page'

  urlRoot: "#{Locomotive.mount_on}/sites"

  initialize: ->
    # Be careful, domains_without_subdomain becomes domains
    domains = _.map @get('domains_without_subdomain'), (name) =>
      new Locomotive.Models.Domain(name: name)

    @set domains: domains

class Locomotive.Models.CurrentSite extends Locomotive.Models.Site

  urlRoot: "#{Locomotive.mount_on}/current_site"


