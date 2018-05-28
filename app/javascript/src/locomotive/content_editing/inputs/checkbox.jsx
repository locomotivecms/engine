import React, { Component } from 'react';

class CheckboxInput extends Component {

  constructor(props) {
    super(props);

    var checked = props.data.settings[props.setting.id];
    checked = checked || props.setting.default || false;

    this.state = { checked };

    this.toggleChange = this.toggleChange.bind(this);
  }

  toggleChange(event) {
    const { checked } = event.target;
    this.setState({ checked }, () => {
      this.props.onChange(this.props.setting.id, checked, false)
    });
  }

  render() {
    const { setting } = this.props;

    return (
      <div className="locomotive-editor-input locomotive-editor-input-checkbox">
        <label>{setting.label}</label>
        <input type="checkbox"
          checked={this.state.checked}
          onChange={this.toggleChange}
        />
      </div>
    )
  }

}

export default CheckboxInput;
