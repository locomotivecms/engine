import React, { Component } from 'react';
import { Link, Redirect } from 'react-router-dom';
import { updateBlockTextValue as previewUpdateText } from '../../services/preview_service';
import withRedux from '../../utils/with_redux';
import { find } from 'lodash';

// Components
import Input from '../../inputs/base.jsx';

class Edit extends Component {

  constructor(props) {
    super(props);

    const { definitions, staticContent, match } = this.props;
    const { type, blockId } = match.params;
    const block = find(staticContent[type].blocks, block => block.id === blockId) || {};

    // Shortcuts
    this.sectionType = type, this.blockId = blockId;
    this.sectionDefinition  = find(definitions, def => def.type === type);
    this.blockDefinition    = find(this.sectionDefinition.blocks, def => def.type === block.type);

    // Bind methods
    this.onChange = this.onChange.bind(this);
  }

  onChange(settingId, newValue, updatePreview) {
    const { updateStaticSectionBlockInput, iframe } = this.props;

    // Sync with the preview
    if (updatePreview)
      previewUpdateText(iframe, this.sectionType, this.blockId, settingId, newValue);

    // Update the global state
    updateStaticSectionBlockInput(this.sectionType, this.blockId, settingId, newValue);
  }

  getContent() {
    return find(this.props.staticContent[this.sectionType].blocks,
      block => block.id === this.blockId
    );
  }

  render() {
    const content = this.getContent();

    return content ? (
      <div className="editor-edit-block">
        <h2>
          [{this.sectionDefinition.name}] Edit {this.blockDefinition.name}
          &nbsp;
          <Link to={`/sections/${this.sectionDefinition.type}/edit`}>Back</Link>
        </h2>

        <div className="editor-block-settings">
          {this.blockDefinition.settings.map(setting =>
            <Input
              key={`section-input-${setting.id}`}
              setting={setting}
              data={content}
              onChange={this.onChange}
            />
          )}
        </div>
      </div>
    ) : (
      <Redirect
        to={{ pathname: `/sections/${this.sectionType}/edit` }}
      />
    )
  }

}

export default withRedux(Edit, state => { return {
  staticContent:  state.site.sectionsContent,
  definitions:    state.sectionDefinitions,
  iframe:         state.iframe.window
} });
