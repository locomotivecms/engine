import React from 'react';
import { find } from 'lodash';
import { compose } from 'redux';

import withRedux from './with_redux';

const withNavParams = Component => {

  return class WithNavParams extends React.Component {

    constructor(props) {
      super(props);

      const { definitions, match } = this.props;
      const { sectionType, sectionId, blockType, blockId, settingId } = match.params;

      this.sectionType = sectionType, this.sectionId = sectionId;
      this.blockType = blockType, this.blockId = blockId;
      this.settingId = settingId;

      this.sectionDefinition = find(definitions, def => def.type === sectionType);
      this.blockDefinition   = find(this.sectionDefinition.blocks, def => def.type === blockType);
    }

    // let the preview know about which part (section or block) of the page we're going to edit
    componentDidMount() {
      if (this.blockId)
        this.props.selectSectionBlock(this.sectionType, this.sectionId, this.blockType, this.blockId);
      else
        this.props.selectSection(this.sectionType, this.sectionId);
    }

    // build the nav params passed to the component
    buildNavParams() {
      const { definitions, match } = this.props;
      const { sectionType, sectionId, blockType, blockId, settingId } = match.params;

      var params = {
        sectionType,
        sectionId,
        blockType,
        blockId,
        settingId
      }



      return params;
    }

    // find the related content. It depends if the section is a static one or not (dropsections)
    fetchContent(params) {
      var content = {};

      // Section content
      if (params.sectionId)
        content.sectionContent = find(this.props.content, section =>
          section.id === params.sectionId
        );
      else
        content.sectionContent = this.props.staticContent[params.sectionDefinition.type];

      // Block content
      if (params.blockId)
        find(content.sectionContent.blocks, block => block.id === params.blockId);

      return content;
    }

    render() {
      const params    = this.buildNavParams();
      const content   = this.fetchContent(params);

      return <Component
        {...params}
        {...content}
        {...this.props}
      />
    }

  }

}

export default compose(
  withRedux(state => { return {
    staticContent:  state.site.sectionsContent,
    content:        state.page.sectionsContent,
    definitions:    state.sectionDefinitions
  } }),
  withNavParams
);
