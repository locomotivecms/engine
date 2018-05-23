import React, { Component } from 'react';
import { updateTextValue as previewUpdateTextValue } from '../services/preview_service';

class StringInput extends Component {

  constructor(props) {
    super(props);

    console.log('StringInput', props.data.settings, props.settings.id);

    var value = props.data.settings[props.settings.id];
    value = value || props.settings.default;

    this.state = { value };

    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleChange(event) {
    const { value } = event.target;

    this.setState({ value }, () => { this.onChange(value) });
  }

  handleSubmit(event) {
    alert('A name was submitted: ' + this.state.value);
    event.preventDefault();
  }

  onChange(value) {
    switch(this.props.type) {
      case 'staticSection':
        const { editStaticSectionInput, sectionType, settings } = this.props;

        previewUpdateTextValue(this.props.iframe, sectionType, settings.id, value);
        editStaticSectionInput(sectionType, settings.id, value);

        break;
    }
  }

  render() {
    const { settings } = this.props;

    // console.log(settings);

    return (
      <div className="lce-input lce-input-string">
        <label>{settings.label}</label>
        <br/>
        <input type="text" value={this.state.value} onChange={this.handleChange} />
      </div>
    )
  }

}

export default StringInput;
