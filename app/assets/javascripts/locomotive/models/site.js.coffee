class Locomotive.Models.Site extends Backbone.Model

  paramRoot: 'site'

  urlRoot: "#{Locomotive.mount_on}/sites"

  initialize: ->
    # Be careful, domains_without_subdomain becomes domains
    domains = _.map @get('domains_without_subdomain'), (name) =>
      new Locomotive.Models.Domain(name: name)

    memberships = new Locomotive.Models.MembershipsCollection(@get('memberships'))

    @set domains: domains, memberships: memberships

  includes_domain: (name) ->
    name == @domain_with_domain() || _.any(@get('domains'), (domain) -> domain.get('name') == name)

  domain_with_domain: ->
    "#{@get('subdomain')}.#{@get('domain_name')}"

  toJSON: ->
    _.tap super, (hash) =>
      hash.memberships = @get('memberships').toJSONForSave() if @get('memberships')
      hash.domains = _.map(@get('domains'), (domain) -> domain.get('name'))

class Locomotive.Models.CurrentSite extends Locomotive.Models.Site

  url: "#{Locomotive.mount_on}/current_site"


