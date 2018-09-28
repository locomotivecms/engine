import React from 'react';
import { truncate } from 'lodash';
import i18n from '../../i18n';

// HOC
import asView from '../../hoc/as_view';

// Components
import View from '../../components/default_view';
import Input from '../../inputs/base';

const removeBlock = ({ section, blockId, history, redirectTo, editSectionPath, removeSectionBlock }) => {
  if (confirm(i18n.t('shared.confirm'))) {
    removeSectionBlock(section, blockId);
    redirectTo(editSectionPath(section));
  }
}

const Edit = props => (
  <View
    title={props.blockLabel || props.blockDefinition.name}
    subTitle={props.sectionLabel || props.sectionDefinition.name}
    onLeave={props.leaveView}
    renderAction={() => (
      <a href="#" onClick={() => removeBlock(props)}>
        <i className="far fa-trash-alt"></i>
      </a>
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
