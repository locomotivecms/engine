import React, { Component } from 'react';

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
          label="Title"
          getValue={() => page.title}
          handleChange={value => updatePageSetting('title', value)}
          error={errors.title}
        />

        {page.slug !== undefined && (
          <TextInput
            label="Slug"
            getValue={() => page.slug}
            handleChange={value => updatePageSetting('slug', value)}
            error={errors.slug}
          />
        )}

        <div className="editor-page-settings-more">
          <a href={moreSettingPath}>More settings...</a>
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

