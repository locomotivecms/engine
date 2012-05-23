# encoding: utf-8

## String

class String #:nodoc

  def permalink
    self.to_ascii.parameterize('-')
  end

  def permalink!
    replace(self.permalink)
  end

  alias :parameterize! :permalink!

end

## Hash

class Hash #:nodoc

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

class Boolean #:nodoc
  BOOLEAN_MAP = {
    true => true, "true" => true, "TRUE" => true, "1" => true, 1 => true, 1.0 => true,
    false => false, "false" => false, "FALSE" => false, "0" => false, 0 => false, 0.0 => false
  }

  def self.set(value)
    value = BOOLEAN_MAP[value]
    value.nil? ? nil : value
  end

  def self.get(value)
    value
  end
end

