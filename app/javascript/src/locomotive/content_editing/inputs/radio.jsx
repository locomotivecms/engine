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
    // var isSelected = event.target.value === 'on';
    // var selected = this.state.selected;

    // if (isSelected) {
    //   selected.push(event.target.id);
    // } else {
    //   selected.splice(selected.indexOf(event.target.id));
    // }

    // this.setState({
    //   selected
    // })

    this.setState({
      selected: event.target.id
    })
  }

  render() {
    const { setting } = this.props;
    return (
      <div className="editor-input editor-input-radio">
        <form>
          {setting.options.map((option) => (
            <div>
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