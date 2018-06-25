import React from 'react';

// HOC
import asView from '../../hoc/as_view';

// Components
import Input from '../../inputs/base.jsx';

const Edit = props => (
  <div className="editor-edit-block">
    <div className="row header-row">
      <div className="col-md-12">
        <h1>
          {props.sectionDefinition.name} / {props.blockDefinition.name}
          &nbsp;
          <small>
            <a onClick={props.leaveView}>Back</a>
          </small>
        </h1>
      </div>
    </div>

    <div className="editor-block-settings">
      {props.blockDefinition.settings.map(setting =>
        <Input
          key={`section-input-${setting.id}`}
          setting={setting}
          data={props.blockContent}
          onChange={props.handleChange}
          {...props}
        />
      )}
    </div>
  </div>
)

export default asView(Edit);
