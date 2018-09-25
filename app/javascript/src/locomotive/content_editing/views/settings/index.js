import React, { Component } from 'react';
import i18n from '../../i18n';

// HOC
import withRedux from '../../hoc/with_redux';

// Components
import View from '../../components/default_view';
import { TextInput } from '../../inputs';

const SettingsForm = ({ page, errors, updatePageSetting, moreSettingPath, ...props }) => {
  return (
    <View>
      <div className="editor-page-settings">
        <TextInput
          label={i18n.t('views.settings.title_label')}
          getValue={() => page.title}
          handleChange={value => updatePageSetting('title', value)}
          error={errors.title}
        />

        {page.slug !== undefined && (
          <TextInput
            label={i18n.t('views.settings.slug_label')}
            getValue={() => page.slug}
            handleChange={value => updatePageSetting('slug', value)}
            error={errors.slug}
          />
        )}

        <div className="editor-page-settings-more">
          <a href={moreSettingPath}>
            {i18n.t('views.settings.more')}
          </a>
        </div>
      </div>
    </View>
  )
}

export default withRedux(state => ({
  page: state.content.page,
  errors: state.editor.formErrors.page || {},
  moreSettingPath: state.editor.urls.settings
}))(SettingsForm);

