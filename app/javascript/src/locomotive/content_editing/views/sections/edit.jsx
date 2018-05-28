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

    // Bind methods
    this.onChange = this.onChange.bind(this);
  }

  onChange(settingType, settingId, newValue) {
    this.props.updateStaticSectionInput(
      this.sectionDefinition.type,
      settingType,
      settingId,
      newValue
    );
  }

  getContent() {
    return this.props.staticContent[this.sectionDefinition.type] || {};
  }

  render() {
    return (
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
  definitions:    state.sectionDefinitions
} });
