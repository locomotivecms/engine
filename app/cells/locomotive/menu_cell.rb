module Locomotive
  class MenuCell < Cell::Rails

    include ::Locomotive::Engine.routes.url_helpers

    delegate :main_app, :sections, :to => :parent_controller

    attr_accessor :list

    def initialize(*args)
      super
      self.list = []
    end

    def show(args = {})
      self.build_list
      render
    end

    def url_options
      super.reverse_merge(
        :host               => request.host_with_port,
        :protocol           => request.protocol,
        :_path_segments     => request.symbolized_path_parameters
      ).merge(:script_name  => request.script_name)
    end

    class MenuProxy

      def initialize(cell)
        @cell = cell
      end

      def method_missing(meth, *args)
        @cell.send(meth, *args)
      end

    end

    def self.update_for(name, &block)
      method_name = "build_list_with_#{name}".to_sym
      previous_method_name = "build_list_without_#{name}".to_sym

      unless self.instance_methods.include?(method_name) # prevents the method to be called twice which will raise a "stack level too deep" exception

        self.send(:define_method, method_name) do
          self.send(previous_method_name)
          block.call(MenuProxy.new(self))
        end

        # Note: this might cause "stack level too deep" if called twice for the same name
        alias_method_chain :build_list, name.to_sym

      end
    end

    protected

    def build_list
      raise 'the build_list method must be overridden'
    end

    def build_item(name, attributes)
      unless attributes.key?(:label)
        attributes[:label] = localize_label(name)
      end

      attributes.merge!(:name => name, :class => name.to_s.dasherize.downcase)
    end

    def add(name, attributes)
      self.list << build_item(name, attributes)
    end

    def add_after(pivot, name, attributes)
      index = self.list.index { |i| i[:name] == pivot }
      self.list.insert(index + 1, self.build_item(name, attributes))
    end

    def add_before(pivot, name, attributes)
      index = self.list.index { |i| i[:name] == pivot }
      self.list.insert(index, self.build_item(name, attributes))
    end

    def modify(name, attributes)
      self.find(name).merge!(attributes)
    end

    def remove(name)
      self.list.delete_if { |i| i[:name] == name }
    end

    def find(name)
      self.list.detect { |i| i[:name] == name }
    end

    def localize_label(label)
      I18n.t("locomotive.shared.menu.#{label}")
    end

  end
end