import React, { Component } from 'react';
import { bindAll } from 'lodash';
import classnames from 'classnames';
import { waitUntil } from '../../utils/misc';

const SUBMITTING_DELAY  = 1000;
const DONE_DELAY        = 4000;

const INIT        = 0;
const IN_PROGRESS = 1;
const SUCCESS     = 2;
const ERROR       = 3;

class Button extends Component {

  constructor(props) {
    super(props);
    this.state = { status: INIT };
    bindAll(this, 'onClick');
  }

  onClick(event) {
    if (this.state.status === IN_PROGRESS || this.state.status === SUCCESS) return;

    this.setState({ status: IN_PROGRESS });

    var clickedAt = new Date().getMilliseconds();

    this.props.onClick()
    .then(success => {
      waitUntil(clickedAt, SUBMITTING_DELAY, () => {
        this.setState({ status: success ? SUCCESS : ERROR });

        if (success)
          setTimeout(() => this.setState({ status: INIT }), DONE_DELAY);
      });
    });
  }

  isDisabled() {
    return this.state.status === INIT && this.props.disabled;
  }

  mainClassName() {
    const base = this.props.mainClassName;

    switch(this.state.status) {
      case INIT: return base;
      case IN_PROGRESS: return `${base}--in-progress`;
      case SUCCESS: return `${base}--success`;
      case ERROR: return `${base}--error`;
    };
  }

  renderLabel() {
    switch(this.state.status) {
      case INIT: return this.props.label;
      case IN_PROGRESS: return this.props.inProgressLabel;
      case SUCCESS: return this.props.successLabel;
      case ERROR: return this.props.errorLabel;
    };
    return null;
  }

  renderIcon() {
    switch(this.state.status) {
      case IN_PROGRESS: return <i className="fas fa-circle-notch fa-spin"></i>;
      case SUCCESS: return <i className="fas fa-check"></i>;
      case ERROR: return <i className="fas fa-exclamation"></i>;
    }
    return null;
  }

  render() {
    return (
      <button
        onClick={this.onClick}
        className={classnames(this.props.className, this.mainClassName())}
        disabled={this.isDisabled()}
      >
        {this.renderIcon()}
        <span>{this.renderLabel()}</span>
      </button>
    );
  }

}

export default Button;

