import React, { Component } from 'react';
import { Link } from 'react-router-dom';
import { updateTextValue as previewUpdateText } from '../../services/preview_service';
import withRedux from '../../utils/with_redux';
import { isBlank } from '../../utils/misc';
import { find } from 'lodash';

// Components
import Input from '../../inputs/base.jsx';
import BlockList from './components/block_list.jsx';

class Edit extends Component {

  constructor(props) {
    super(props);

    const { definitions, match } = this.props;

    // shortcuts
    this.sectionDefinition  = definitions.find(def => def.type === match.params.type);

    // Bind methods
    this.onChange = this.onChange.bind(this);
  }

  onChange(settingId, newValue, updatePreview) {
    const { updateStaticSectionInput, iframe } = this.props;
    const sectionType = this.sectionDefinition.type;

    if (updatePreview)
      previewUpdateText(iframe, sectionType, settingId, newValue);

    updateStaticSectionInput(sectionType, settingId, newValue);
  }

  getContent() {
    return this.props.staticContent[this.sectionDefinition.type] || {};
  }

  render() {
    return (
      <div className="editor-edit-section">
        <h2>
          [{this.sectionDefinition.name}] Edit
          &nbsp;
          <Link to="/">Back</Link>
        </h2>

        <div className="editor-section-settings">
          {this.sectionDefinition.settings.map(setting =>
            <Input
              key={`section-input-${setting.id}`}
              setting={setting}
              data={this.getContent()}
              onChange={this.onChange}
            />
          )}
        </div>

        <hr/>

        {!isBlank(this.sectionDefinition.blocks) &&
          <BlockList sectionDefinition={this.sectionDefinition} content={this.getContent()} />
        }
      </div>
    )
  }

}

export default withRedux(Edit, state => { return {
  staticContent:  state.site.sectionsContent,
  definitions:    state.sectionDefinitions,
  iframe:         state.iframe.window
} });
