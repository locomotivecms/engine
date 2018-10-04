import React, { Component } from 'react';
import i18n from '../../i18n';

// HOC
import withRedux from '../../hoc/with_redux';

// Components
import View from '../../components/default_view';
import { TextInput, CheckboxInput } from '../../inputs';

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

        {page.slug !== undefined && (
          <CheckboxInput
            label={i18n.t('views.settings.published')}
            getValue={() => page.published}
            handleChange={value => updatePageSetting('published', value)}
            error={errors.published}
          />
        )}

        {page.slug !== undefined && (
          <CheckboxInput
            label={i18n.t('views.settings.listed')}
            getValue={() => page.listed}
            handleChange={value => updatePageSetting('listed', value)}
            error={errors.listed}
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

