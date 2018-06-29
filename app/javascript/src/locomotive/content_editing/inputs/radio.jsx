import React, { Component } from 'react';

class RadioInput extends Component {

  constructor(props) {
    super(props);

    var selected = props.data.settings[props.setting.id];

    if (selected == undefined) {
      selected = props.setting.default;
    }

    if (selected == undefined) {
      selected = [];
    }

    this.state = {
      selected
    }

    this.handleChange =  this.handleChange.bind(this)
  }

  handleChange(event) {
    const selected = event.target.id;

    this.setState({ selected }, () => {
      this.props.onChange(this.props.setting.type, this.props.setting.id, selected);
    });
  }

  render() {
    const { setting } = this.props;
    return (
      <div className="editor-input editor-input-radio">
        <form>
          {setting.options.map((option) => (
            <div key={option.value}>
              <input
                type="radio"
                id={option.value}
                onChange={this.handleChange}
                checked={this.state.selected == option.value}
              />
              {option.label}
            </div>
          ))}
        </form>
      </div>
    )


  }

}

export default RadioInput;