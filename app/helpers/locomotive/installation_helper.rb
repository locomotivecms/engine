module Locomotive
  module InstallationHelper

    def next_installation_step_link(step = 1, label = nil)
      link_to(content_tag(:span, label || t('admin.installation.common.next')), installation_step_url(step), :class => 'button')
    end

  end
end