import React, { Component } from 'react';
import { Link } from 'react-router-dom';
import withRedux from '../../utils/with_redux';
import { isBlank } from '../../utils/misc';
import { find } from 'lodash';

// Components
import Input from '../../inputs/base.jsx';
import BlockList from './components/block_list.jsx';

class Edit extends Component {

  // Return the definition of the current section
  getDefinition() {
    const { definitions, match } = this.props;
    return definitions.find(definition => definition.type === match.params.type)
  }

  // Return the content of the current section
  // Since it's a static section, it has to fetch it from the site
  getContent(type) {
    const { sectionsContent } = this.props.site;
    return sectionsContent[type] || {};
  }

  render() {
    const definition  = this.getDefinition();
    const content     = this.getContent(definition.type);

    return (
      <div className="editor-edit-section">
        <p>
          [Section] Edit {definition.name}
          &nbsp;
          <Link to="/">Back</Link>
        </p>
        <div className="editor-section-settings">
          {definition.settings.map(setting =>
            <Input
              key={`section-input-${setting.id}`}
              setting={setting}
              data={content}
              type="staticSection"
              sectionType={definition.type}
            />
          )}
        </div>
        <hr/>
        {!isBlank(definition.blocks) &&
          <BlockList sectionDefinition={definition} content={content} />
        }
      </div>
    )
  }

}

export default withRedux(Edit, state => { return {
  site: state.site, definitions: state.sectionDefinitions
} });
