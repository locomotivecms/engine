module Locomotive
  module Markdown

    def self.render(text)
      self.parser.render(text)
    end

    def self.parser
      @@markdown ||= Redcarpet::Markdown.new Redcarpet::Render::HTML, {
        autolink:         true,
        fenced_code:      true,
        generate_toc:     true,
        gh_blockcode:     true,
        hard_wrap:        true,
        no_intraemphasis: true,
        strikethrough:    true,
        tables:           true,
        xhtml:            true
      }
    end

  end
end