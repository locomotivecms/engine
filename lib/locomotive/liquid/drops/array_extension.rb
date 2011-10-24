class Array
  def to_liquid
    Locomotive::Liquid::Drops::Base.new(self)
  end
end
