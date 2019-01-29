import React, { Component } from 'react';
import { bindAll, truncate } from 'lodash';
import { isBlank } from '../../utils/misc';
import classnames from 'classnames';

// Components
const DefaultView = ({ title, subTitle, renderMenu, onLeave, renderAction, ...props }) => (
  <div className={classnames('editor-view', title ? 'editor-view--with-nav' : null)}>
    {renderMenu && renderMenu()}
    {title && (
      <div className="editor-view--header">
        <div className="editor-view--header-back-btn">
          <a onClick={onLeave}>
            <i className="fas fa-chevron-left"></i>
          </a>
        </div>
        <div className="editor-view--header-title">
          {!isBlank(subTitle) && (
            <div className="editor-view--header-sub-title">
              {truncate(subTitle, { length: 30 })}
            </div>
          )}
          <div className="editor-view--header-main-title">
            {truncate(title, { length: 25 })}
          </div>
        </div>
        {renderAction && (
          <div className="editor-view--header-action">
            {renderAction()}
          </div>
        )}
      </div>
    )}
    <div className="editor-view--scrollable">
      <div className="scrollable">
        {props.children}
      </div>
    </div>
  </div>
)

export default DefaultView;
