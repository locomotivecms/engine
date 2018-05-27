import React, { Component } from 'react';

class StringInput extends Component {

  constructor(props) {
    super(props);

    var value = props.data.settings[props.setting.id];
    value = value || props.setting.default || '';

    this.state = { value };

    this.handleChange = this.handleChange.bind(this);
  }

  handleChange(event) {
    const { value } = event.target;
    this.setState({ value }, () => {
      this.props.onChange(this.props.setting.id, value, true)
    });
  }

  render() {
    const { setting } = this.props;

    return (
      <div className="locomotive-editor-input locomotive-editor-input-string">
        <label>{setting.label}</label>
        <br/>
        <input type="text" value={this.state.value} onChange={this.handleChange} />
      </div>
    )
  }

}

export default StringInput;
