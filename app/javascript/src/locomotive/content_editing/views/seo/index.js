import React, { Component } from 'react';

// HOC
import withRedux from '../../hoc/with_redux';

// Components
import View from '../../components/default_view';
import { TextInput } from '../../inputs';

const SeoForm = ({ page, errors, updatePageSetting, moreSettingPath, ...props }) => {
  return (
    <View>
      <div className="editor-page-settings">
        <TextInput
          label="seo title"
          getValue={() => page.seo_title || ''}
          handleChange={value => updatePageSetting('seo_title', value)}
        />

        <TextInput
          label="meta keywords"
          getValue={() => page.meta_keywords || ''}
          handleChange={value => updatePageSetting('meta_keywords', value)}
          error={errors.slug}
        />

        <TextInput
          label="meta description"
          getValue={() => page.meta_description || ''}
          handleChange={value => updatePageSetting('meta_description', value)}
        />
      </div>
    </View>
  )
}

export default withRedux(state => ({
  page: state.content.page,
  errors: state.editor.formErrors.page || {},
  moreSettingPath: state.editor.urls.settings
}))(SeoForm);

