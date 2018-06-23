import React, { Component } from 'react';
import { Link, Redirect } from 'react-router-dom';
import asView from '../../hoc/as_view';
import { isBlank } from '../../utils/misc';
import { bindAll } from 'lodash';

// Components
import Input from '../../inputs/base.jsx';
import BlockList from './edit/block_list.jsx';

class Edit extends Component {

  constructor(props) {
    super(props);
    bindAll(this, ['onChange', 'exit']);
  }

  componentDidMount() {
    this.props.selectItem();
  }

  onChange(settingType, settingId, newValue) {
    this.props.updateSectionInput(
      this.props.sectionType,
      this.props.sectionId,
      settingType,
      settingId,
      newValue
    );
  }

  exit() {
    this.props.unselectItem();
    this.props.history.push(this.props.routes.parentPath());
  }

  render() {
    return this.props.sectionDefinition && this.props.sectionContent ? (
      <div className="editor-edit-section">
        <div className="row header-row">
          <div className="col-md-12">
            <h1>
              {this.props.sectionDefinition.name}
              &nbsp;
              <small>
                <a onClick={this.exit}>Back</a>
              </small>
            </h1>
          </div>
        </div>

        <div className="editor-section-settings">
          {this.props.sectionDefinition.settings.map(setting =>
            <Input
              key={`section-input-${setting.id}`}
              setting={setting}
              data={this.props.sectionContent}
              onChange={this.onChange}
            />
          )}
        </div>

        <hr/>

        {!isBlank(this.props.sectionDefinition.blocks) &&
          <BlockList {...this.props} />
        }
      </div>
    ) : (
      <Redirect to={{ pathname: `/sections` }} />
    )
  }
}

export default asView(Edit);
