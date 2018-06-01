import React, { Component } from 'react';

class SelectInput extends Component {

  constructor(props) {
    super(props);

    var value = props.data.settings[props.setting.id];
    if (value === undefined) value = props.setting.default || null;

    this.state = { value };

    this.handleChange = this.handleChange.bind(this);
  }

  handleChange(event) {
    console.log(event);
    const { value } = event.target;
    this.setState({ value }, () => {
      this.props.onChange(this.props.setting.type, this.props.setting.id, value);
    });
  }

  render() {
    const { setting } = this.props;

    return (
      <div className="editor-input editor-input-select">
        <label>{setting.label}</label>
        <br/>
        <select onChange={this.handleChange} value={this.state.value}>
          {setting.options.map((option, index) =>
            <option key={index} value={option.value}>{option.label}</option>
          )}
        </select>
      </div>
    )
  }

}

export default SelectInput;
