import React, { Component } from 'react';
import i18n from '../../../i18n';

// Components
import Autosuggest from './autosuggest';

class Main extends Component {

  constructor(props) {
    super();
    this.state = { contentEntry: {} };
  }

  componentDidMount() {
    const { contentEntry } = this.props;
    this.setState({ contentEntry });
  }

  handleChange(value) {
    this.props.updateContent({ id: value.value.id, label: value.label[1] })
  }

  render() {
    const { contentEntry } = this.state;
    const contentType = this.props.setting.content_type;

    return (
      <div className="content-entry-picker">
        <Autosuggest
          label={i18n.t('views.pickers.content_entry.input.label')}
          placeholder={i18n.t('views.pickers.content_entry.input.placeholder')}
          input={contentEntry?.label || ''}
          search={input => this.props.api.searchForResources('content_entry', input, contentType) }
          handleChange={value => this.handleChange(value)}
          handleNewInput={() => this.setState({ contentEntry: {} })}
        />
     </div>
    )
  }

}

export default Main;
