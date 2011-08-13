require 'rspec-cells'
require 'cell/test_case'
require 'rspec/rails/example/cell_example_group'

module CellsResetter

  def self.method_missing(meth, *args)
    if meth =~ /^new_(.*)_klass/
      name = $1

      klass_name = name.camelize

      ::Admin.send(:remove_const, klass_name)
      load "#{name}.rb"

      "::Admin::#{klass_name}".constantize.any_instance.stubs(:sections).returns(args.first)
    end
  end

  def self.clean!
    [:menu_cell, :main_menu_cell, :global_actions_cell, :settings_menu_cell].each do |name|
      ::Admin.send(:remove_const, "#{name.to_s.camelize}")
      load "#{name}.rb"
    end
  end

end