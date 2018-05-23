import React, { Component } from 'react';
import { updateTextValue as previewUpdateTextValue } from '../services/preview_service';

class StringInput extends Component {

  constructor(props) {
    super(props);

    var value = props.data.settings[props.setting.id];
    value = value || props.setting.default;

    this.state = { value };

    this.handleChange = this.handleChange.bind(this);
  }

  handleChange(event) {
    const { value } = event.target;
    this.setState({ value }, () => { this.onChange(value) });
  }

  onChange(value) {
    switch(this.props.type) {
      case 'staticSection':
        const { updateStaticSectionInput, sectionType, setting } = this.props;

        previewUpdateTextValue(this.props.iframe, sectionType, setting.id, value);
        updateStaticSectionInput(sectionType, setting.id, value);

        break;
    }
  }

  render() {
    const { setting } = this.props;

    return (
      <div className="lce-input lce-input-string">
        <label>{setting.label}</label>
        <br/>
        <input type="text" value={this.state.value} onChange={this.handleChange} />
      </div>
    )
  }

}

export default StringInput;
