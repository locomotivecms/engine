class Locomotive.Models.Site extends Backbone.Model

  paramRoot: 'site'

  urlRoot: "#{Locomotive.mounted_on}/sites"

  initialize: ->
    @_fix_attributes()

    # After save, need to fix the attributes again
    this.on 'sync', ->
      @_fix_attributes()

  includes_domain: (name_with_port) ->
    name = name_with_port.replace(/:[0-9]*/, '')
    name == @domain_with_domain() || _.any(@get('domains'), (domain) -> domain.get('name') == name)

  domain_with_domain: ->
    "#{@get('subdomain')}.#{@get('domain_name')}"

  toJSON: ->
    _.tap super, (hash) =>
      _.each ['locales_text', 'timezone_name_text'], (key) => delete hash[key]
      delete hash.memberships
      hash.memberships_attributes = @get('memberships').toJSONForSave() if @get('memberships')? && @get('memberships').length > 0
      delete hash.domains
      hash.domains = _.map(@get('domains'), (domain) -> domain.get('name'))
      hash.locales = _.flatten([@get('locales')])

  _fix_attributes: ->
    # Be careful, domains_without_subdomain becomes domains
    domains = _.map @get('domains_without_subdomain'), (name) =>
      new Locomotive.Models.Domain(name: name)

    memberships = new Locomotive.Models.MembershipsCollection(@get('memberships'))

    @set domains: domains, memberships: memberships


class Locomotive.Models.CurrentSite extends Locomotive.Models.Site

  url: "#{Locomotive.mounted_on}/current_site"


