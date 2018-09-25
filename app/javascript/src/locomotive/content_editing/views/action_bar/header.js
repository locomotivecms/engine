import React, { Component } from 'react';
import i18n from '../../i18n';

// HOC
import withRedux from '../../hoc/with_redux';

// Components
import Button from '../../components/button';

const Header = props => (
  <div className="editor-header">
    <div className="editor-header--navinfo">
      <div className="navinfo--path">
        {props.page.fullpath}
      </div>
      <div className="navinfo--title">
        {props.page.title || i18n.t('views.action_bar.header.no_title')}
      </div>
    </div>

    <div className="editor-header--savebtn">
      <Button
        mainClassName="btn-save"
        className="btn btn-primary"
        onClick={props.persistChanges}
        disabled={!props.changed}
        label={i18n.t('views.action_bar.header.save_button.label')}
        inProgressLabel={i18n.t('views.action_bar.header.save_button.in_progress')}
        successLabel={i18n.t('views.action_bar.header.save_button.success')}
        errorLabel={i18n.t('views.action_bar.header.save_button.error')}
      />
    </div>
  </div>
)

export default withRedux(state => ({
  page:     state.content.page,
  changed:  state.editor.changed
}))(Header)
