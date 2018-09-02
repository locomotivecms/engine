import React from 'react';
import { truncate } from 'lodash';

// HOC
import asView from '../../hoc/as_view';

// Components
import View from '../../components/default_view';
import Input from '../../inputs/base';

const removeBlock = ({ section, blockId, history, editSectionPath, removeSectionBlock }) => {
  if (confirm('Are you sure?')) {
    history.push(editSectionPath(section));
    removeSectionBlock(section, blockId);
  }
}

const Edit = props => (
  <View
    title={props.blockLabel || props.blockDefinition.name}
    subTitle={props.sectionLabel || props.sectionDefinition.name}
    onLeave={props.leaveView}
    renderAction={() => (
      <button className="btn btn-primary btn-sm" onClick={() => removeBlock(props)}>
        Remove
      </button>
    )}
  >
    <div className="editor-edit-block">
      <div className="editor-block-settings">
        {props.blockDefinition.settings.map((setting, index) =>
          <Input
            key={`section-section-input-${setting.id}-${index}`}
            setting={setting}
            data={props.blockContent}
            onChange={props.handleChange}
            {...props}
          />
        )}
      </div>
    </div>
  </View>
)

export default asView(Edit);
