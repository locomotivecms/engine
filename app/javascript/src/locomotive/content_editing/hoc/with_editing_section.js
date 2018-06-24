import React from 'react';
import { find, pick } from 'lodash';

const withEditingSection = Component => {

  const buildNewProps = props => {
    var newProps = pick(props.match.params, [
      'sectionType', 'sectionId', 'blockType', 'blockId', 'settingId'
    ]);

    newProps.sectionDefinition  = props.findSectionDefinition(newProps.sectionType);
    newProps.blockDefinition    = props.findBlockDefinition(
      newProps.sectionDefinition,
      newProps.blockType
    )

    return Object.assign(newProps, props);
  }

  // find the related content. It depends if the section is a static one or not
  const fetchContent = props => {
    const { sectionType, sectionId, blockType, blockId } = props;
    var content = {};

    // Section content
    content.sectionContent = sectionId ? find(props.content, section =>
      section.id === sectionId
    ) : props.staticContent[sectionType];

    // Block content
    content.blockContent = blockId ? find(content.sectionContent.blocks, block =>
      block.id === blockId
    ) : null;

    return content;
  }

  return function WrappedComponent(props) {
    const newProps = buildNewProps(props)
    return (
      <Component
        {...fetchContent(newProps)}
        {...newProps}
      />
    )
  }

}

export default withEditingSection;

  // return class WithNavParams extends React.Component {

  //   constructor(props) {
  //     super(props);

  //     this.params = pick(this.props.match.params, [
  //       'sectionType', 'sectionId', 'blockType', 'blockId', 'settingId'
  //     ]);

  //     this.params.sectionDefinition = this.findSectionDefinition();
  //     this.params.blockDefinition   = this.findBlockDefinition();

  //     bindAll(this, ['selectItem', 'unselectItem']);
  //   }

  //   findSectionDefinition() {
  //     return find(this.props.definitions, def => def.type === this.params.sectionType);
  //   }

  //   findBlockDefinition() {
  //     const { sectionDefinition, blockType } = this.params;
  //     return find(sectionDefinition.blocks, def => def.type === blockType);
  //   }

  //   // let the preview know about which part (section or block) of the page we're going to edit
  //   selectItem() {
  //     const { sectionType, sectionId, blockType, blockId } = this.params;

  //     if (blockId)
  //       this.props.selectSectionBlock(sectionType, sectionId, blockType, blockId);
  //     else
  //       this.props.selectSection(sectionType, sectionId);
  //   }

  //   // let the preview know about when the editor leaves for another editing view
  //   unselectItem() {
  //     const { sectionType, sectionId, blockId } = this.params;

  //     if (blockId)
  //       this.props.deselectSectionBlock(sectionType, sectionId, blockId);
  //     else
  //       this.props.deselectSection(sectionType, sectionId);
  //   }

  //   // find the related content. It depends if the section is a static one or not (dropsections)
  //   fetchContent() {
  //     const { sectionType, sectionId, blockType, blockId } = this.params;
  //     var content = {};

  //     // Section content
  //     content.sectionContent = sectionId ? find(this.props.content, section =>
  //       section.id === sectionId
  //     ) : this.props.staticContent[sectionType];

  //     // Block content
  //     content.blockContent = blockId ? find(content.sectionContent.blocks, block =>
  //       block.id === blockId
  //     ) : null;

  //     return content;
  //   }

  //   render() {
      // return <Component
      //   selectItem={this.selectItem}
      //   unselectItem={this.unselectItem}
      //   {...this.fetchContent()}
      //   {...this.params}
      //   {...this.props}
      // />
  //   }

  // }

// }
