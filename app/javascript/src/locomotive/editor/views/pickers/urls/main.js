import React, { Component } from 'react';
import { compose } from 'redux';
import { compact, isEqual } from 'lodash';
import i18n from '../../../i18n';

// Components
import TypeOption from './type_option';
import Types from './types';

// Services
import { findBetterText } from '../../../services/sections_service';

// Helpers
const buildSectionOptions = (findSectionDefinition, sections) => {
  return compact((sections || []).map(section => {
    // unknown section type, can happen if the data are messed up (first deployment)
    if (section.type === null) return null;

    const definition = findSectionDefinition(section.type);

    if (definition === undefined || definition === null) return null; // happens with the very first sites using the sections

    const label = findBetterText(section, definition) || definition.name;

    return [label, section.anchor];
  }));
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

  handleTypeChange(newType) {
    this.setState({ type: newType });
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
              handleChange={event => this.handleTypeChange(event.target.value)}
            />
          ))}
        </div>

        <div className="url-picker-type-settings">
          <TypeSettings
            api={this.props.api}
            settings={this.state[this.state.type]}
            contentTypes={this.props.contentTypes}
            handleChange={newSettings => this.handleChange(newSettings)}
            buildSectionOptions={buildSectionOptions.bind(null, this.props.findSectionDefinition)}
          />
        </div>
      </div>
    )
  }

}

export default Main;
