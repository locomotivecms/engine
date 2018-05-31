import React, { Component } from 'react';
import { Link, Redirect } from 'react-router-dom';
import withRedux from '../../utils/with_redux';
import { find } from 'lodash';

// Components
import Input from '../../inputs/base.jsx';

class Edit extends Component {

  constructor(props) {
    super(props);

    const { definitions, match } = this.props;
    const { type, id, blockType, blockId } = match.params;

    // Shortcuts
    this.sectionType = type, this.sectionId = id, this.blockId = blockId;
    this.sectionDefinition  = find(definitions, def => def.type === type);
    this.blockDefinition    = find(this.sectionDefinition.blocks, def => def.type === blockType);

    // Bind methods
    this.onChange = this.onChange.bind(this);
    this.exit     = this.exit.bind(this);
  }

  componentDidMount() {
    this.props.selectSectionBlock(this.sectionId || this.sectionType, this.blockId);
  }

  exit() {
    this.props.deselectSectionBlock(this.sectionId || this.sectionType, this.blockId);
    this.props.history.push(this.getCurrentSectionPath());
  }

  onChange(settingType, settingId, newValue) {
    this.props.updateSectionBlockInput(
      this.sectionType,
      this.sectionId,
      this.blockId,
      settingType,
      settingId,
      newValue
    );
  }

  getSectionContent() {
    if (this.sectionId)
      return find(this.props.content, section => section.id === this.sectionId);
    else
      return this.props.staticContent[this.sectionDefinition.type];
  }

  getContent() {
    return find(this.getSectionContent().blocks, block => block.id === this.blockId);
  }

  getCurrentSectionPath() {
    if (this.sectionId)
      return `/dropzone_sections/${this.sectionType}/${this.sectionId}/edit`;
    else
      return `/sections/${this.sectionType}/edit`;
  }

  render() {
    const content = this.getContent();

    return content ? (
      <div className="editor-edit-block">
        <div className="row header-row">
          <div className="col-md-12">
            <h1>
              {this.sectionDefinition.name} / {this.blockDefinition.name}
              &nbsp;
              <small>
                <a onClick={this.exit}>Back</a>
              </small>
            </h1>
          </div>
        </div>

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
        to={{ pathname: '/' }}
      />
    )
  }

}

export default withRedux(Edit, state => { return {
  staticContent:  state.site.sectionsContent,
  content:        state.page.sectionsContent,
  definitions:    state.sectionDefinitions
} });
