import React, { Component } from 'react';
import { compose } from 'redux';
import { bindAll, isEqual } from 'lodash';
import i18n from '../../../i18n';

// Components
import TypeOption from './type_option';
import Types from './types';

// Services
import { findBetterText } from '../../../services/sections_service';

// Helpers
const buildSectionOptions = (findSectionDefinition, sections) => {
  return (sections || []).map(section => {
    const definition  = findSectionDefinition(section.type);
    const label       = findBetterText(section.content, definition)
    return [label, section.id];
  });
}

class Main extends Component {

  constructor(props) {
    super(props);
    this.state = {
      type:           '_external',
      page:           { value: null, new_window: false },
      content_entry:  { value: null, page_id: null, new_window: false },
      _external:      { value: '', new_window: false },
      email:          { value: '', new_window: false }
    };
    bindAll(this, 'handleTypeChange', 'handleChange');
  }

  componentDidMount() {
    this.setDefaultState();
  }

  componentDidUpdate(prevProps) {
    if (!isEqual(prevProps.url, this.props.url))
      this.setDefaultState();
  }

  setDefaultState() {
    const value = this.props.url;

    if (typeof(value) === 'string')
      this.setState({ type: '_external', _external: { value } });
    else if (value != null)
      this.setState({ type: value.type, [value.type]: Object.assign({}, value) });
  }

  handleTypeChange(event) {
    this.setState({ type: event.target.value });
  }

  handleChange(newSettings) {
    const { type } = this.state;

    this.setState({ [type]: newSettings }, () => {
      this.props.updateContent(type, newSettings);
    });
  }

  getOptionList() {
    var list = ['page', 'content_entry', '_external', 'email'];

    // remove the content_entry option if no templatized pages
    if (this.props.contentTypes.length === 0) list.splice(1, 1);

    return list;
  }

  render() {
    const TypeSettings = Types[this.state.type];

    return (
      <div className="url-picker">
        <div className="url-picker-type-list">
          {this.getOptionList().map(type => (
            <TypeOption
              key={type}
              value={type}
              currentValue={this.state.type}
              handleChange={this.handleTypeChange}
            />
          ))}
        </div>

        <div className="url-picker-type-settings">
          <TypeSettings
            api={this.props.api}
            settings={this.state[this.state.type]}
            contentTypes={this.props.contentTypes}
            handleChange={this.handleChange}
            buildSectionOptions={buildSectionOptions.bind(null, this.props.findSectionDefinition)}
          />
        </div>
      </div>
    )
  }

}

export default Main;
