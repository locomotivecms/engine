import React, { Component } from 'react';
import { forEach } from 'lodash';
import Popover from 'react-awesome-popover';
import i18n from '../../i18n';

const LocaleSwitcher = ({ locale, locales, handleSelect, ...props }) => (
  <div className="locale-switcher">
    <Popover action="click" placement="bottom" contentClass="locale-switcher-content">
      <a className="locale-switcher-button" role="button">
        {locale}
        &nbsp;
        <span className="caret" />
      </a>
      <ul className="locale-switcher-locales">
        {locales.map(_locale => (
          <li key={_locale} className="locale-switcher-locale">
            <a
              onClick={e => handleSelect(_locale)}
              dangerouslySetInnerHTML={{ __html: i18n.t('components.locale_switcher.locale', { locale: _locale }) }}
            />
          </li>
        ))}
      </ul>
    </Popover>
  </div>
)

export default LocaleSwitcher;
