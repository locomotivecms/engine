import React, { Component } from 'react';
import { Link, Redirect } from 'react-router-dom';
import { bindAll } from 'lodash';

// HOC
import asView from '../../hoc/as_view';

// Components
import Input from '../../inputs/base.jsx';

class Edit extends Component {

  constructor(props) {
    super(props);
    bindAll(this, ['onChange', 'exit']);
  }

  componentDidMount() {
    // this.props.selectItem(); // TODO
  }

  exit() {
    // this.props.unselectItem(); // TODO
    this.props.history.push(
      this.props.blockParentPath(
        this.props.sectionType,
        this.props.sectionId
      )
    );
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

  render() {
    return (
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
    )
  }

}

export default asView(Edit);
