## String
class String
  # def perma_string(sep = '_')
  #   ActiveSupport::Inflector.parameterize(self, sep).to_s
  # end
  
  def slugify(options = {})
    options = { :sep => '_', :without_extension => false }.merge(options)
    # replace accented chars with ther ascii equivalents
    s = ActiveSupport::Inflector.transliterate(self).to_s
    # No more than one slash in a row
    s.gsub!(/(\/[\/]+)/, '/')
    # Remove leading or trailing space
    s.strip!
    # Remove leading or trailing slash
    s.gsub! /(^[\/]+)|([\/]+$)/, ''
    # Remove extensions
    s.gsub! /(\.[a-zA-Z]{2,})/, '' if options[:without_extension]
    # Turn unwanted chars into the seperator
    s.gsub!(/[^a-zA-Z0-9\-_\+\/]+/i, options[:sep])
    s
  end
  
end