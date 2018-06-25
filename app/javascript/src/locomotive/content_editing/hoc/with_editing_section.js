import React from 'react';
import { Redirect } from 'react-router-dom';
import { find, pick, bindAll } from 'lodash';

const withEditingSection = Component => {

  // Enhance the props
  const fetchSectionContent = (props, content, staticContent) => {
    const { sectionType, sectionId } = props;
    return sectionId ? find(content, s => s.id === sectionId) : staticContent[sectionType];
  }

  const fetchBlockContent = props => {
    const { sectionContent, blockId } = props;
    return blockId ? find(sectionContent.blocks, b => b.id === blockId) : null;
  }

  const buildNewProps = props => {
    var newProps = pick(props.match.params, [
      'sectionType', 'sectionId', 'blockType', 'blockId', 'settingId'
    ]);

    // find definitions (section and block)
    newProps.sectionDefinition  = props.findSectionDefinition(newProps.sectionType);
    newProps.blockDefinition    = props.findBlockDefinition(
      newProps.sectionDefinition,
      newProps.blockType
    )

    // find content
    newProps.sectionContent = fetchSectionContent(newProps, props.content, props.staticContent);
    newProps.blockContent   = fetchBlockContent(newProps);

    return Object.assign(newProps, props);
  }

  // Helpers
  const isEditingSection  = props => (props.sectionId || props.sectionType) && props.sectionContent
  const isEditingBlock    = props => props.blockId && props.blockContent
  const isEditing         = props => isEditingSection(props) || isEditingBlock(props)
  const editingType = props => {
    if (isEditingBlock(props))    return 'block';
    if (isEditingSection(props))  return 'section';
    return null;
  }

  // Notifications
  const notifySectionOnEnter = props => {
    props.selectSection(props.sectionType, props.sectionId);
  }

  const notifyBlockOnEnter = props => {
    props.selectSectionBlock(props.sectionType, props.sectionId, props.blockType, props.blockId);
  }

  const notifySectionOnLeave = props => {
    props.deselectSection(props.sectionType, props.sectionId);
  }

  const notifyBlockOnLeave = props => {
    props.deselectSectionBlock(props.sectionType, props.sectionId, props.blockType, props.blockId);
  }

  const notifyOnEnter = props => {
    switch(editingType(props)) {
      case 'section': notifySectionOnEnter(props); break;
      case 'block':   notifyBlockOnEnter(props); break;
    }
  }

  const notifyOnLeave = props => {
    switch(editingType(props)) {
      case 'section': notifySectionOnLeave(props); break;
      case 'block':   notifyBlockOnLeave(props); break;
    }
  }

  // Path helper

  const parentPath = props => {
    switch(editingType(props)) {
      case 'section':
        return props.sectionsPath();
      case 'block':
        return props.editSectionPath(props.sectionType, props.sectionId);
    }
  }

  // Callbacks

  const handleChange = (props, settingType, settingId, newValue) => {
    const { sectionType, sectionId, blockId, updateSectionInput, updateSectionBlockInput } = props;

    const updateInput = isEditingBlock(props) ?
      updateSectionBlockInput.bind(null, sectionType, sectionId, blockId) :
      updateSectionInput.bind(null, sectionType, sectionId);

    updateInput(settingType, settingId, newValue);
  }

  class WrappedComponent extends React.Component {

    constructor(props) {
      super(props);
      bindAll(this, 'leaveView', 'handleChange');
    }

    componentDidMount() {
      notifyOnEnter(this.props);
    }

    leaveView() {
      notifyOnLeave(this.props);
      this.props.history.push(parentPath(this.props));
    }

    handleChange(settingType, settingId, newValue) {
      handleChange(this.props, settingType, settingId, newValue);
    }

    render() {
      return (
        <Component
          leaveView={this.leaveView}
          handleChange={this.handleChange}
          {...this.props}
        />
      )
    }

  }

  return function WithEditingSection(props) {
    const newProps = buildNewProps(props);

    return isEditing(newProps) ? (
      <WrappedComponent
        {...newProps}
      />
    ) : (
      <Redirect to={{ pathname: '/' }} />
    )
  }

}

export default withEditingSection;
