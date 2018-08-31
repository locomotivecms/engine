import React from 'react';
import { truncate } from 'lodash';

// HOC
import asView from '../../hoc/as_view';

// Components
import View from '../../components/default_view';
import Input from '../../inputs/base';

const Edit = props => (
  <View title={props.blockLabel || props.blockDefinition.name} subTitle={props.sectionLabel || props.sectionDefinition.name} onLeave={props.leaveView}>
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
