import React from 'react';
// import { Redirect } from 'react-router-dom';
import { bindAll } from 'lodash';

export default function withRoutes(Component) {

  // const buildRoutes = (pageId, contentEntryId) => {
  //   const _pageId       = compact([pageId, contentEntryId]).join('-');
  //   const basePath      = `/${_pageId}/content/edit`;
  //   const sectionsPath  = `${basePath}/sections`;

  //   const rootPath              = () => basePath;
  //   const newSectionPath        = () => `${basePath}/sections/dropzone/new`;

  //   const sectionPath = (section) => {
  //     return `${sectionsPath}/${section.uuid}`;
  //   }
  //   const editSectionPath = (section) => {
  //     return `${sectionPath(section)}/edit`;
  //   }

  //   const blockPath = (section, blockType, blockId) => {
  //     return `${sectionPath(section)}/blocks/${blockType}/${blockId}`;
  //   }
  //   const editBlockPath = (section, blockType, blockId) => {
  //     return `${blockPath(section, blockType, blockId)}/edit`;
  //   }

  //   const blockParentPath = (section) => {
  //     return `${sectionPath(section)}/edit`;
  //   }

  //   const pickImagePath = (section, blockType, blockId, settingType, settingId) => {
  //     const postfix = `setting/${settingType}/${settingId}/images`;

  //     if (blockType && blockId)
  //       return `${blockPath(section, blockType, blockId)}/${postfix}`;
  //     else
  //       return `${sectionPath(section)}/${postfix}`;
  //   }

  //   const pickUrlPath = (section, blockType, blockId, settingType, settingId) => {
  //     const postfix = `setting/${settingType}/${settingId}/pick-url`;

  //     if (blockType && blockId)
  //       return `${blockPath(section, blockType, blockId)}/${postfix}`;
  //     else
  //       return `${sectionPath(section)}/${postfix}`;
  //   }

  //   const pickContentEntryPath = (section, blockType, blockId, settingType, settingId) => {
  //     const postfix = `setting/${settingType}/${settingId}/content-entry`;

  //     if (blockType && blockId)
  //       return `${blockPath(section, blockType, blockId)}/${postfix}`;
  //     else
  //       return `${sectionPath(section)}/${postfix}`;
  //   }

  //   return {
  //     rootPath,
  //     editSectionPath,
  //     newSectionPath,
  //     editBlockPath,
  //     blockParentPath,
  //     pickImagePath,
  //     pickUrlPath,
  //     pickContentEntryPath
  //   }
  // }

  return class WrappedComponent extends React.Component {

    constructor(props) {
      super(props);
      bindAll(this, 'redirectTo');
    }

    // componentDidMount() {
    //   // NOTE: dirty hack to allow the usage of the redirectTo outside component
    //   setRedirectTo(this.redirectTo);
    // }

    // NOTE: slideDirection is the direction where the new view will move to
    redirectTo(pathname, slideRediction) {
      console.log('redirectTo', slideRediction, slideRediction || 'right');
      this.props.history.push({ pathname, state: { slideDirection: slideRediction || 'right' } });
    } 

    render() {
      return (
        <Component
          redirectTo={this.redirectTo}
          {...this.props.routes}
          {...this.props}
        />
      )
    }
  }

}
