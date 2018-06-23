import React from 'react';
import { bindAll } from 'lodash';

const withRoutes = Component => {

  return class WithRoutes extends React.Component {

    constructor(props) {
      super(props);
      bindAll(this, 'getParentPath', 'getEditBlockPath');
    }

    getParentPath() {
      const { sectionType, sectionId, blockId } = this.props;

      if (blockId)
        return sectionId ?
          `/dropzone_sections/${sectionType}/${sectionId}/edit` :
          `/sections/${sectionType}/edit`;
      else
        return '/sections';
    }

    getEditBlockPath(blockType, blockId) {
      const { sectionType, sectionId } = this.props;
      const _blockType  = blockType || this.props.blockType;
      const _blockId    = blockId || this.props.blockId;

      const prefix = sectionId ?
      `/dropzone_sections/${sectionType}/${sectionId}` :
      `/sections/${sectionType}`;

      return `${prefix}/blocks/${_blockType}/${_blockId}/edit`;
    }

    buildRoutes() {
      return {
        parentPath:     this.getParentPath,
        editBlockPath:  this.getEditBlockPath
      }
    }

    render() {
      return <Component
        routes={this.buildRoutes()}
        {...this.props}
      />
    }

  }

}

export default withRoutes;
