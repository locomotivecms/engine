import React, { Component } from 'react';
import i18n from '../../i18n';
import { truncate } from 'lodash';

// HOC
import withRedux from '../../hoc/with_redux';

// Components
import Button from '../../components/button';
import LocaleSwitcher from '../../components/locale_switcher';

const Header = props => (
  <div className="editor-header">
    <div className="editor-header--navinfo">
      <div className="navinfo--path">
        {truncate(props.page.fullpath, { length: 33 })}
      </div>
      <div className="navinfo--title">
        {truncate(props.page.title, { length: 26 }) || i18n.t('views.action_bar.header.no_title')}
      </div>
      <div className="navinfo-locale">
        {props.locales.length > 1 && (
          <LocaleSwitcher
            locale={props.locale}
            locales={props.locales}
            handleSelect={_locale => props.changeLocale(props.pageId, props.contentEntryId, _locale)}
          />
        )}
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
  page:           state.content.page,
  pageId:         state.content.page.id,
  contentEntryId: state.content.page.contentEntryId,
  changed:        state.editor.changed,
  locale:         state.editor.locale,
  locales:        state.editor.locales
}))(Header)
