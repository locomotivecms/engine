import React, { Component } from 'react';

class StringInput extends Component {

  constructor(props) {
    super(props);

    console.log('StringInput', props.data.settings, props.settings.id);

    var value = props.data.settings[props.settings.id];
    value = value ||  props.settings.default;

    this.state = { value };

    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleChange(event) {
    const { value } = event.target;
    this.setState({ value });

    switch(this.props.type) {
      case 'staticSection':
        // TODO: refactor, add a service
        const dataValue = `section-${this.props.sectionType}.${this.props.settings.id}`;

        $(this.props.iframe.document)
          .find(`[data-locomotive-editor-setting='${dataValue}']`)
          .html(value);

        this.props.editStaticSectionInput(
          this.props.sectionType,
          this.props.settings.id,
          value
        );
        break;
    }
  }

  handleSubmit(event) {
    alert('A name was submitted: ' + this.state.value);
    event.preventDefault();
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
