import React, { Component } from 'react';
import { Link, Redirect } from 'react-router-dom';
import { bindAll } from 'lodash';
import withNavParams from '../../hoc/with_nav_params';

// Components
import Input from '../../inputs/base.jsx';

class Edit extends Component {

  constructor(props) {
    super(props);
    bindAll(this, ['onChange', 'exit']);
  }

  componentDidMount() {
    this.props.selectItem();
  }

  exit() {
    this.props.unselectItem();
    this.props.history.push(this.getCurrentSectionPath());
  }

  onChange(settingType, settingId, newValue) {
    this.props.updateSectionBlockInput(
      this.props.sectionType,
      this.props.sectionId,
      this.props.blockId,
      settingType,
      settingId,
      newValue
    );
  }

  getCurrentSectionPath() {
    if (this.props.sectionId)
      return `/dropzone_sections/${this.props.sectionType}/${this.props.sectionId}/edit`;
    else
      return `/sections/${this.props.sectionType}/edit`;
  }

  render() {
    return this.props.sectionDefinition && this.props.blockContent  ? (
      <div className="editor-edit-block">
        <div className="row header-row">
          <div className="col-md-12">
            <h1>
              {this.props.sectionDefinition.name} / {this.props.blockDefinition.name}
              &nbsp;
              <small>
                <a onClick={this.exit}>Back</a>
              </small>
            </h1>
          </div>
        </div>

        <div className="editor-block-settings">
          {this.props.blockDefinition.settings.map(setting =>
            <Input
              key={`section-input-${setting.id}`}
              setting={setting}
              data={this.props.blockContent}
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

export default withNavParams(Edit);
