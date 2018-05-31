import React, { Component } from 'react';
import { Link } from 'react-router-dom';
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
    this.sectionId          = match.params.id;

    // Bind methods
    this.onChange = this.onChange.bind(this);
  }

  onChange(settingType, settingId, newValue) {
    this.props.updateSectionInput(
      this.sectionDefinition.type,
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
      return this.props.staticContent[this.sectionDefinition.type] || {};
  }

  render() {
    const content = this.getContent();

    return content ? (
      <div className="editor-edit-section">
        <div className="row header-row">
          <div className="col-md-12">
            <h1>
              {this.sectionDefinition.name}
              &nbsp;
              <small>
                <Link to="/sections">Back</Link>
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
