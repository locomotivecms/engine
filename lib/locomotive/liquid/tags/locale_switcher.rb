module Locomotive
  module Liquid
    module Tags
      # Display the links to change the locale of the current page
      #
      # Usage:
      #
      # {% locale_switcher %} => <div id="locale-switcher"><a href="/features" class="current en">Features</a><a href="/fr/fonctionnalites" class="fr">Fonctionnalités</a></div>
      #
      # {% locale_switcher label: locale, sep: ' - ' }
      #
      # options:
      #   - label: iso (de, fr, en, ...etc), locale (Deutsch, Français, English, ...etc), title (page title)
      #   - sep: piece of html code separating 2 locales
      #
      # notes:
      #   - "iso" is the default choice for label
      #   - " | " is the default separating code
      #
      class LocaleSwitcher < ::Liquid::Tag

        Syntax = /(#{::Liquid::Expression}+)?/

        def initialize(tag_name, markup, tokens, context)
          @options = { :label => 'iso', :sep => ' | ' }

          if markup =~ Syntax
            markup.scan(::Liquid::TagAttributes) { |key, value| @options[key.to_sym] = value.gsub(/"|'/, '') }

            @options[:exclude] = Regexp.new(@options[:exclude]) if @options[:exclude]
          else
            raise ::Liquid::SyntaxError.new("Syntax Error in 'locale_switcher' - Valid syntax: locale_switcher <options>")
          end

          super
        end

        def render(context)
          @site, @page = context.registers[:site], context.registers[:page]

          output = %(<div id="locale-switcher">)

          output += @site.locales.collect do |locale|
            ::Mongoid::Fields::I18n.with_locale(locale) do
              fullpath = @site.localized_page_fullpath(@page, locale)

              if @page.templatized?
                fullpath.gsub!('content_type_template', context['entry']._permalink)
              end

              %(<a href="/#{fullpath}" class="#{locale} #{'current' if locale == context['current_locale']}">#{link_label(locale)}</a>)
            end
          end.join(@options[:sep])

          output += %(</div>)
        end

        private

        def link_label(locale)
          case @options[:label]
          when :iso     then locale
          when :locale  then I18n.t("locomotive.locales.#{locale}", :locale => locale)
          when :title   then @page.title # FIXME: this returns nil if the page has not been translated in the locale
          else
            locale
          end
        end

      end

      ::Liquid::Template.register_tag('locale_switcher', LocaleSwitcher)
    end
  end
end