import React from 'react';
import { Redirect } from 'react-router-dom';
import { bindAll, compact } from 'lodash';

export default function withRoutes(Component) {

  const buildRoutes = (pageId, contentEntryId) => {
    const _pageId   = compact([pageId, contentEntryId]).join('-');
    const basePath  = `/${_pageId}/content/edit`;

    const sectionsPath          = () => `${basePath}/sections`;
    const newSectionPath        = () => `${basePath}/sections/dropzone/new`;

    const sectionPath = (section) => {
      return `${sectionsPath()}/${section.uuid}`;
    }
    const editSectionPath = (section) => {
      return `${sectionPath(section)}/edit`;
    }

    const blockPath = (section, blockType, blockId) => {
      return `${sectionPath(section)}/blocks/${blockType}/${blockId}`;
    }
    const editBlockPath = (section, blockType, blockId) => {
      return `${blockPath(section, blockType, blockId)}/edit`;
    }

    const blockParentPath = (section) => {
      return `${sectionPath(section)}/edit`;
    }

    const imagesPath = (section, blockType, blockId, settingType, settingId) => {
      const postfix = `setting/${settingType}/${settingId}/images`;

      if (blockType && blockId)
        return `${blockPath(section, blockType, blockId)}/${postfix}`;
      else
        return `${sectionPath(section)}/${postfix}`;
    }

    return {
      sectionsPath,
      editSectionPath,
      newSectionPath,
      editBlockPath,
      blockParentPath,
      imagesPath
    }
  }

  return class WrappedComponent extends React.Component {

    constructor(props) {
      super(props);
      this.state = {};
      bindAll(this, 'redirectTo');
    }

    redirectTo(pathname) {
      this.setState({ redirectTo: pathname })
    }

    render() {
      return this.state.redirectTo === undefined ? (
        <Component
          redirectTo={this.redirectTo}
          {...buildRoutes(this.props.pageId, this.props.contentEntryId)}
          {...this.props}
        />
      ) : (
        <Redirect to={{ pathname: this.state.redirectTo }} />
      );
    }

  }

}
