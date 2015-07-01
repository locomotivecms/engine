module Locomotive

  class TranslationService < Struct.new(:site, :account)

    def all(options = {})
      query       = site.translations.ordered
      keywords    = prepare_keywords_statement(options[:q])
      completion  = prepare_completion_statement(options[:filter_by])

      # filtering
      query = if completion then query.and(*keywords, *completion) else query.where(keywords) end

      # pagination
      query
        .page(options[:page] || 1)
        .per(options[:per_page] || Locomotive.config.ui[:per_page])
    end

    def update(translation, values)
      translation.tap do
        translation.values = values
        translation.updated_by = account if account
        translation.save
      end
    end

    protected

    def prepare_keywords_statement(keywords)
      return {} if keywords.blank?

      regexp = /.*#{keywords.split.map { |k| Regexp.escape(k) }.join('.*')}.*/i

      [{ '$or' => [
        { key: regexp },
        *site.locales.map { |l| { "values.#{l}" => regexp  } }
      ] }]
    end

    def prepare_completion_statement(filter_by)
      case filter_by
      when 'done'       then [{ completion: site.locales.size }]
      when 'partially'  then [{ :completion.lt => site.locales.size }, { :completion.gt => 0 }]
      when 'none'       then [{ completion: 0 }]
      else {}
      end
    end

  end

end
