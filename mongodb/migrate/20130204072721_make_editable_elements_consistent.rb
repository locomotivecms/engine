class MakeEditableElementsConsistent < MongoidMigration::Migration
  def self.up
    Locomotive::Site.all.each do |site|
      site.locales.each do |locale|
        ::Mongoid::Fields::I18n.locale = locale
        site.pages.each do |page|
          puts "[#{site.name}] #{page.fullpath} (#{locale})"

          found_elements = []

          next if page.template.nil?

          page.template.walk do |node, memo|
            case node
            when Locomotive::Liquid::Tags::InheritedBlock
              puts "found block ! #{node.name} --- #{memo[:parent_block_name]}"

              # set the new name based on a potential parent block
              name = node.name.gsub(/[\"\']/o, '')

              if memo[:parent_block_name] && !name.starts_with?(memo[:parent_block_name])
                name = "#{memo[:parent_block_name]}/#{name}"
              end

              puts "new_name = #{name}"

              # retrieve all the editable elements of this block and set them the new name
              page.find_editable_elements(node.name).each do |el|
                # puts "**> hurray found the element #{el.block} _ #{el.slug}"
                el.block = name
                puts "**> hurray found the element #{el.block} _ #{el.slug} | #{page.find_editable_element(name, el.slug).present?.inspect}"
              end

              # assign the new name to the block
              node.instance_variable_set :@name, name

              # record the new parent block name for children
              memo[:parent_block_name] = name

            when Locomotive::Liquid::Tags::Editable::ShortText,
                Locomotive::Liquid::Tags::Editable::LongText,
                Locomotive::Liquid::Tags::Editable::Control,
                Locomotive::Liquid::Tags::Editable::File

              puts "\tfound editable_element ! #{node.slug} --- #{memo[:parent_block_name]}"

              slug = node.slug.gsub(/[\"\']/o, '')

              # assign the new slug to the editable element
              puts "\t\t...looking for #{node.slug} inside #{memo[:parent_block_name]}"

              options = node.instance_variable_get :@options
              block   = options[:block].blank? ? memo[:parent_block_name] : options[:block]

              if el = page.find_editable_element(block, node.slug)
                puts "\t\t--> yep found the element"

                el.slug   = slug
                el.block  = memo[:parent_block_name] # just to make sure

                node.instance_variable_set :@slug, slug

                options.delete(:block)
                node.instance_variable_set :@block, nil  # just to make sure

                found_elements << el._id
              else
                puts "\t\t[WARNING] el not found (#{block} - #{slug})"
              end

            end

            memo
          end # page walk

          puts "found elements = #{found_elements.join(', ')} / #{page.editable_elements.count}"

          # "hide" useless editable elements
          page.editable_elements.each do |el|
            next if found_elements.include?(el._id)
            el.disabled = true
          end

          # serialize
          page.send(:_serialize_template)

          # puts page.template.inspect

          # save ?
          page.instance_variable_set :@template_changed, false
          page.save

          # TODO:
          #  x ", block: 'Asset #1'"" ???? les re-assigner a "main" d'une facon ou d'une autre
          #   => en fait, ce sont des editable elements qui n'ont pas vrais blocks
          #  x hide useless editable elements
          #  x re-serializer le template
          #  ? skipper la methode parse (quoique pas besoin car template non modifie)
          #  x snippets
          #  x sauvegarder (sans callbacks ??)
        end # loop: pages
      end # loop: locales
    end # loop: sites
  end

  def self.down
    raise MongoidMigration::IrreversibleMigration
  end
end