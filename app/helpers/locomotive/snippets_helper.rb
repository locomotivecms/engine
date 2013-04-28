module Locomotive
	module SnippetsHelper

		# Give the path to the template of the snippet for the main locale ONLY IF
		# the user does not already edit the snippet in the main locale.
		#
		# @param [ Object ] snippet The snippet
		#
		# @return [ String ] The path or nil if the main locale is enabled
		#
		def snippet_main_template_path(snippet)
			if not_the_default_current_locale?
				snippet_path(snippet, content_locale: current_site.default_locale, format: :json)
			else
				nil
			end
		end

	end
end