import React, { Component } from 'react';
import { isBlank } from '../../../../utils/misc';
import i18n from '../../../../i18n';

// Components
import Autosuggest from './shared/autosuggest';
import Select from './shared/select';
import NewWindowCheckbox from './shared/new_window_checkbox';

class Page extends Component {

  constructor(props) {
    super();
    this.state = { settings: {}, sections: [] };
  }

  componentDidMount() {
    const { settings, api } = this.props;

    this.setState({ settings }, () => {
      if (isBlank(settings.value)) return; // no selected page

      // required to re-populate the sections select box
      api.searchForResources('page', settings.value)
      .then(data => this.setState({ sections: (data?.list || [])[0]?.sections }));
    });
  }

  _handleChange(newSettings, extraData) {
    this.setState({
      ...extraData,
      settings: Object.assign(this.state.settings, newSettings)
    }, () => this.props.handleChange(this.state.settings));
  }

  handlePageChanged(newSettings) {
    const { sections, ...settings } = newSettings;
    this._handleChange(Object.assign(settings, { section_id: '' }), { sections });
  }

  handleSectionChanged(newSectionId) {
    this._handleChange({ section_id: newSectionId }, {});
  }

  handleNewWindowChanged(checked) {
    this._handleChange({ new_window: checked }, {});
  }

  renderPagePicker() {
    return (
      <Autosuggest
        label={i18n.t('views.pickers.url.page.label')}
        placeholder={i18n.t('views.pickers.url.page.placeholder')}
        input={(this.state.settings?.label || [])[1] || ''}
        search={input => this.props.api.searchForResources('page', input) }
        handleChange={value => this.handlePageChanged(value)}
        handleNewInput={() => this.setState({ settings: {} })}
      />
    );
  }

  renderSectionPicker() {
    return (
      <Select
        label={i18n.t('views.pickers.url.page.section_label')}
        value={this.state.settings.section_id}
        list={this.props.buildSectionOptions(this.state.sections)}
        includeEmpty={true}
        onChange={id => this.handleSectionChanged(id)}
      />
    )
  }

  renderNewWindowCheckbox() {
    return (
      <NewWindowCheckbox
        label={i18n.t('views.pickers.url.open_new_window')}
        checked={this.state.settings.new_window}
        onChange={checked => this.handleNewWindowChanged(checked)}
      />
    )
  }

  render() {
    const { settings, sections } = this.state;

    return (
      <div className="url-picker-page-settings">
        {this.renderPagePicker()}

        {settings && sections.length > 0 && this.renderSectionPicker()}

        {settings && this.renderNewWindowCheckbox()}
      </div>
    )
  }

}

export default Page;

// class Page extends Component {

//   constructor(props) {
//     super();
//     this.state = { settings: {}, input: '', suggestions: [], sectionOptions: [], loading: false };
//     bindAll(this, 'onChange', 'onSuggestionsFetchRequested', 'onSuggestionsClearRequested')
//   }

//   componentDidMount() {
//     const { settings, findSectionDefinition } = this.props;
//     this.setState({ settings, input: getInputText(settings) }, () => {
//       if (isBlank(settings.section_id)) return; // no selected page

//       // required to re-populate the sections select box
//       this.props.api.searchForResources('page', settings.value)
//       .then(data => {
//         const sections = isBlank(data.list) ? [] : data.list[0].sections;
//         const sectionOptions = buildSectionOptions(sections, findSectionDefinition)
//         this.setState({ sectionOptions })
//       });
//     });
//   }

//   onChange(event, { newValue, method }) {
//     // console.log(method, newValue, this.props.findSectionDefinition);

//     switch(method) {
//       case 'enter':
//       case 'click':
//         this.setState({
//           settings:       newValue,
//           input:          getInputText(newValue),
//           sectionOptions: buildSectionOptions(newValue.sections, this.props.findSectionDefinition)
//         }, () => {
//           this.props.handleChange(newValue);
//         });
//         return;
//       case 'type':
//         this.setState({ settings: null, input: newValue });
//       default:
//         // do nothing
//     }
//   }

//   onSuggestionsFetchRequested({ value }) {
//     this.setState({ loading: true });
//     this.props.api.searchForResources('page', value)
//     .then(data => this.setState({ suggestions: data.list, loading: false }));
//   }

//   onSuggestionsClearRequested() {
//     this.setState({ suggestions: [] });
//   }

//   render() {
//     const { handleChange } = this.props;
//     const { settings, input, suggestions, sectionOptions, loading } = this.state;
//     const inputProps = {
//       placeholder:  i18n.t('views.pickers.url.page.placeholder'),
//       value:        input,
//       onChange:     this.onChange
//     };

//     return (
//       <div className="url-picker-page-settings">
//         <div className="editor-input editor-input-text">
//           <label className="editor-input--label">
//             {i18n.t('views.pickers.url.page.label')}
//           </label>
//           <div className={classnames('react-autosuggest', loading && 'react-autosuggest--loading')}>
//             <div className="react-autosuggest__spinner">
//               <i className="fas fa-circle-notch fa-spin"></i>
//             </div>
//             <Autosuggest
//               suggestions={suggestions}
//               onSuggestionsFetchRequested={this.onSuggestionsFetchRequested}
//               onSuggestionsClearRequested={this.onSuggestionsClearRequested}
//               getSuggestionValue={getSuggestionValue}
//               renderSuggestion={renderSuggestion}
//               inputProps={inputProps}
//             />
//           </div>
//         </div>

//         {settings && sectionOptions.length > 0 && (
//           <div className="editor-input editor-input-select">
//             <label className="editor-input--label">
//               {i18n.t('views.pickers.url.page.section_label')}
//             </label>
//             <div className="editor-input-select-wrapper">
//               <select
//                 value={settings.section_id}
//                 onChange={e => this.onChange(null, { newValue: { ...settings, section_id: e.target.value }, method: 'click' })}
//                 className="editor-input--select"
//               >
//                 <option value=""></option>
//                 {sectionOptions.map((option, index) =>
//                   <option key={index} value={option.id}>
//                     {option.label}
//                   </option>
//                 )}
//               </select>
//             </div>
//           </div>
//         )}

//         {settings && (
//           <div className="editor-input editor-input-checkbox">
//             <label className="editor-input--label">
//               {i18n.t('views.pickers.url.open_new_window')}
//             </label>
//             <div className="editor-input--button">
//               <Switch
//                 checked={settings.new_window}
//                 onChange={value => this.onChange(null, { newValue: { ...settings, new_window: value }, method: 'click' })}
//               />
//             </div>
//           </div>
//         )}
//       </div>
//     )
//   }

// }

// export default Page;
