module Locomotive

  module Liquid
    
    module Tags
    
      class Blueprint < ::Liquid::Tag
      
        def render(context)
          %{
            <link href="/stylesheets/blueprint/screen.css" media="screen, projection" rel="stylesheet" type="text/css" />
          	<link href="/stylesheets/blueprint/print.css" media="print" rel="stylesheet" type="text/css" />
          	<!--[if IE]>
          		<link href="/stylesheets/blueprint/ie.css" media="screen, projection" rel="stylesheet" type="text/css" />
          	<![endif]-->
          }
        end
      
      end
  
      ::Liquid::Template.register_tag('blueprint_stylesheets', Blueprint)
      
    end
  
  end
  
end