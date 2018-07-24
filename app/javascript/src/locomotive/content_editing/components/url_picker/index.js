import React, { Component } from 'react';
import { bindAll } from 'lodash';
import PropTypes from 'prop-types';

// Components
import UrlInput from './input.jsx';
import UrlInfo from './info.jsx';

class UrlPicker extends Component {

  constructor(props) {
    super(props);
    this.state = {
      editing:        props.editing || false,
      value:          this.getValue(),
      useDoneButton:  false
    };
    bindAll(this, 'handleEditing', 'handleChange', 'handleCancel', 'handleDone', 'handleChangeCheckbox');
  }

  handleEditing() {
    this.setState({ editing: true });
  }

  handleCancel() {
    this.setState({ editing: false });
  }

  handleChange(value) {
    this.setState({ editing: false, value: { new_window: this.state.value.new_window, ...value } });
    if (!this.props.useDoneButton)
      this.handleDone();
  }

  handleChangeCheckbox(event) {
    const { value } = this.state;
    value.new_window = event.target.checked;
    this.setState({ value });
    if (!this.props.useDoneButton)
      this.handleDone();
  }

  handleDone() {
    this.props.handleChange(this.state.value);
  }

  getValue() {
    const value = this.props.value;

    if (typeof(value) === 'string') {
      return { type: '_external', value, label: ['external', value], new_window: false };
    } else
      return { new_window: false, ...value };
  }

  render() {
    return (
      <div className="url-picker">
        {this.state.editing ? (
          <UrlInput
            value={this.state.value}
            handleChange={this.handleChange}
            handleCancel={this.handleCancel}
            searchForResources={this.props.searchForResources}
          />
        ) : (
          <UrlInfo
            value={this.state.value}
            handleDone={this.props.useDoneButton ? this.handleDone : null}
            handleEditing={this.handleEditing}
          />
        )}
        <div className="url-picker-new-window">
          <input
            type="checkbox"
            checked={this.state.value.new_window}
            onChange={this.handleChangeCheckbox}
          /> Open in a new window?
        </div>
      </div>
    )
  }

}

UrlPicker.propTypes = {
  editing:            PropTypes.bool,
  value:              PropTypes.oneOfType([PropTypes.object, PropTypes.string]),
  useDoneButton:      PropTypes.bool,
  searchForResources: PropTypes.func
}

export default UrlPicker;
