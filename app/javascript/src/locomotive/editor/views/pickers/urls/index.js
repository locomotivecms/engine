import React, { Component } from 'react';
import { compose } from 'redux';
import { bindAll, debounce } from 'lodash';
import i18n from '../../../i18n';

// HOC
import asView from '../../../hoc/as_view';
import withRedux from '../../../hoc/with_redux';

// Components
import View from '../../../components/default_view';
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

class Index extends Component {

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
    this.updateContent = debounce(this.updateContent, 500);
  }

  componentDidMount() {
    const value = this.props.currentContent.settings[this.props.settingId];

    if (typeof(value) === 'string')
      this.setState({ type: '_external', _external: { value } });
    else
      this.setState({ type: value.type, [value.type]: value });
  }

  handleTypeChange(event) {
    this.setState({ type: event.target.value });
  }

  handleChange(newSettings) {
    const { handleChange, settingType, settingId } = this.props;
    const { type } = this.state;

    // console.log('handleChange', type, newSettings);

    this.setState({ [type]: newSettings }, () => {
      // change the value through the this.props.handleChange method
      // provided by the asView HOC
      this.updateContent(type, newSettings);
    });
  }

  updateContent(type, settings) {
    const { handleChange, settingType, settingId } = this.props;
    handleChange(settingType, settingId, { ...settings, type });
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
      <View
        title={i18n.t('views.pickers.url.title')}
        subTitle={this.props.settingLabel}
        onLeave={this.props.leaveView}
      >
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
      </View>
    )
  }

}

export default compose(
  asView,
  withRedux(state => ({ contentTypes: state.editor.contentTypes }))
)(Index);
