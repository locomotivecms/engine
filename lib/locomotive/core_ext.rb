## String
class String
  # def perma_string(sep = '_')
  #   ActiveSupport::Inflector.parameterize(self, sep).to_s
  # end

  def slugify(options = {})
    options = { :sep => '_', :without_extension => false, :downcase => false, :underscore => false }.merge(options)
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
    # Downcase
    s.downcase! if options[:downcase]
    # Turn unwanted chars into the seperator
    s.gsub!(/[^a-zA-Z0-9\-_\+\/]+/i, options[:sep])
    # Underscore
    s.gsub!(/[\-]/i, '_') if options[:underscore]
    s
  end

  def slugify!(options = {})
    replace(self.slugify(options))
  end

  def parameterize!(sep = '_')
    replace(self.parameterize(sep))
  end

end

## Hash

class Hash

  def underscore_keys
    new_hash = {}

    self.each_pair do |key, value|
      if value.respond_to?(:collect!) # Array
        value.collect do |item|
          if item.respond_to?(:each_pair) # Hash item within
            item.underscore_keys
          else
            item
          end
        end
      elsif value.respond_to?(:each_pair) # Hash
        value = value.underscore_keys
      end

      new_key = key.is_a?(String) ? key.underscore : key # only String keys

      new_hash[new_key] = value
    end

    self.replace(new_hash)
  end

end


