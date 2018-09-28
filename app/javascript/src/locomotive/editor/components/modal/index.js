import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import classnames from 'classnames';

class Modal extends React.Component {

  constructor(props) {
    super(props);
    this.modalRoot = document.body;
    this.el = document.createElement('div');
  }

  componentDidMount() {
    this.modalRoot.appendChild(this.el);
  }

  componentWillUnmount() {
    this.modalRoot.removeChild(this.el);
  }

  render() {
    return ReactDOM.createPortal(
      (
        <div className={classnames('modal-window', this.props.isOpen ? 'modal-open' : null)}>
          <div>
            <a onClick={this.props.onClose} title="Close" className="modal-close">
              <i className="fas fa-times"></i>
            </a>
            {this.props.title && (
              <div className="modal-window-header">{this.props.title}</div>
            )}
            {this.props.children}
          </div>
        </div>
      ),
      this.el
    );
  }

}

export default Modal;
