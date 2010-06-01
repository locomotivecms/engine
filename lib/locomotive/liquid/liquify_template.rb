module Locomotive
  
  module Liquid
      
    module LiquifyTemplate
      
      def self.included(base)
        base.extend(ClassMethods)
      end

      # Store the parsed version of a liquid template into a column in order to increase performance
      # See http://cjohansen.no/en/rails/liquid_email_templates_in_rails 
      #
      # class Page
      #   liquify_template :body
      # end
      #
      # page = Page.new :body => '...some liquid tags'
      # page.template # Liquid::Template
      # 
      #
      module ClassMethods

        def liquify_template(source = :value)
          field :serialized_template, :type => Binary
          before_validate :store_template
          
          class_eval <<-EOV
            def liquify_template_source
              self.send(:#{source.to_s})
            end
          EOV
          
          include InstanceMethods
        end

      end
      
      module InstanceMethods
        
        def template
          Marshal.load(read_attribute(:serialized_template).to_s) rescue nil
        end
                
        protected
        
        def store_template
          begin
            template = ::Liquid::Template.parse(self.liquify_template_source)
            self.serialized_template = BSON::Binary.new(Marshal.dump(template))
          rescue ::Liquid::SyntaxError => error
            self.errors.add :template, :liquid_syntax_error
          end
        end
        
      end
      
    end
          
  end
  
end