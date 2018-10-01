import React, { Component } from 'react';
import classnames from 'classnames';
import i18n from '../../i18n';

const IconBtn = ({ screensize, icon, changeScreensize, currentScreensize, ...props }) => (
  <a
    className={classnames('preview-actionbar--screensize-btn', currentScreensize === screensize ? 'is-screensize-active' : false)}
    onClick={() => changeScreensize(screensize)}
  >
    <i className={classnames('fas', icon)}></i>
  </a>
)

const ActionBar = ({ previewPath, changed, ...props }) => (
  <div className="preview-actionbar">
    <div className="preview-actionbar--view">
      <a
        href={changed ? null : previewPath}
        className={classnames('preview-actionbar--view-btn', changed ? 'is-disabled' : false)}
        target="_blank"
      >
        <i className="fas fa-eye"></i>
        {i18n.t('views.preview.view')}
      </a>
    </div>

    <div className="preview-actionbar--screensize">
      <IconBtn
        screensize="desktop"
        icon="fa-desktop"
        {...props}
      />

      <IconBtn
        screensize="tablet"
        icon="fa-tablet-alt"
        {...props}
      />

      <IconBtn
        screensize="mobile"
        icon="fa-mobile-alt"
        {...props}
      />

    </div>
  </div>
);

export default ActionBar;
