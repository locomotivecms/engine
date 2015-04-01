module Locomotive
  class BaseRepository

    private

    def model
      self.class.name.gsub(/Repository/, '').constantize
    end

  end
end
