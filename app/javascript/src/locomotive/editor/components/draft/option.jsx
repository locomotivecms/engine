import React, { Component } from 'react';
import { bindAll } from 'lodash';
import classNames from 'classnames';

export default class Option extends Component {

  constructor(props) {
    super(props);
    bindAll(this, 'onClick');
  }

  onClick(event) {
    const { disabled, onClick, value } = this.props;
    if (!disabled)
      onClick(value);
  };

  render() {
    const { children, className, activeClassName, active, disabled, title } = this.props;
    return (
      <div
        className={classNames(
          'rdw-option-wrapper',
          className,
          {
            [`rdw-option-active ${activeClassName}`]: active,
            'rdw-option-disabled': disabled,
          },
        )}
        onClick={this.onClick}
        aria-selected={active}
        title={title}
      >
        {children}
      </div>
    );
  }
}
