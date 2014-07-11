module Locomotive
  module InstallationHelper

    def next_installation_step_link(step = 1, label = nil)
      link_to(label || t('admin.installation.common.next'), installation_step_path(step), class: 'btn btn-block btn-danger')
    end

  end
end