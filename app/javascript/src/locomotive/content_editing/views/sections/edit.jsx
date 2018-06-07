import React, { Component } from 'react';
import { Link, Redirect } from 'react-router-dom';
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
    this.sectionType        = match.params.type;
    this.sectionId          = match.params.id;
    this.sectionDefinition  = definitions.find(def => def.type === this.sectionType);

    // Bind methods
    this.onChange = this.onChange.bind(this);
    this.exit     = this.exit.bind(this);
  }

  componentDidMount() {
    this.props.selectSection(this.sectionId || this.sectionType);
  }

  onChange(settingType, settingId, newValue) {
    this.props.updateSectionInput(
      this.sectionType,
      this.sectionId,
      settingType,
      settingId,
      newValue
    );
  }

  getContent() {
    if (this.sectionId)
      return find(this.props.content, section => section.id === this.sectionId);
    else
      return this.props.staticContent[this.sectionType] || {};
  }

  exit() {
    this.props.deselectSection(this.sectionId || this.sectionType);
    this.props.history.push('/sections');
  }

  render() {
    const content = this.getContent();

    return this.sectionDefinition && content ? (
      <div className="editor-edit-section">
        <div className="row header-row">
          <div className="col-md-12">
            <h1>
              {this.sectionDefinition.name}
              &nbsp;
              <small>
                <a onClick={this.exit}>Back</a>
              </small>
            </h1>
          </div>
        </div>

        <div className="editor-section-settings">
          {this.sectionDefinition.settings.map(setting =>
            <Input
              key={`section-input-${setting.id}`}
              setting={setting}
              data={content}
              onChange={this.onChange}
            />
          )}
        </div>

        <hr/>

        {!isBlank(this.sectionDefinition.blocks) &&
          <BlockList
            sectionDefinition={this.sectionDefinition}
            sectionId={this.sectionId}
            content={content}
          />
        }
      </div>
    ) : (
      <Redirect to={{ pathname: `/sections` }} />
    )
  }

}

export default withRedux(Edit, state => { return {
  staticContent:  state.site.sectionsContent,
  content:        state.page.sectionsContent,
  definitions:    state.sectionDefinitions
} });
