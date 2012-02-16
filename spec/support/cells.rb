require 'rspec-cells'
require 'cell/test_case'
require 'rspec/rails/example/cell_example_group'

#
# module CellsResetter
#
#   def self.method_missing(meth, *args)
#     if meth =~ /^new_(.*)_klass/
#       name = $1
#
#       klass_name = name.camelize
#
#       ::Locomotive.send(:remove_const, klass_name)
#       load "locomotive/#{name}.rb"
#
#       "::Locomotive::#{klass_name}".constantize.any_instance.stubs(:sections).returns(args.first)
#     end
#   end
#
#   def self.clean!
#     [:menu_cell, :main_menu_cell, :global_actions_cell, :settings_menu_cell].each do |name|
#       ::Locomotive.send(:remove_const, "#{name.to_s.camelize}")
#       load "locomotive/#{name}.rb"
#     end
#   end
#
# end
