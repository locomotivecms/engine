import React, { Component } from 'react';

class CheckboxInput extends Component {

  constructor(props) {
    super(props);

    var checked = props.data.settings[props.setting.id];
    if (checked === undefined) checked = props.setting.default || false;

    this.state = { checked };

    this.toggleChange = this.toggleChange.bind(this);
  }

  toggleChange(event) {
    const { checked } = event.target;
    this.setState({ checked }, () => {
      this.props.onChange(this.props.setting.type, this.props.setting.id, checked);
    });
  }

  render() {
    const { setting } = this.props;

    return (
      <div className="editor-input editor-input-checkbox">
        <input type="checkbox"
          checked={this.state.checked}
          onChange={this.toggleChange}
        />
        <label>{setting.label}</label>
      </div>
    )
  }

}

export default CheckboxInput;
