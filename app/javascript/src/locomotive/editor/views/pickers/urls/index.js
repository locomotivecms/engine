import React, { Component } from 'react';
import Pagination from 'react-js-pagination';
import { compose } from 'redux';
import { bindAll } from 'lodash';
import i18n from '../../../i18n';

// HOC
import asView from '../../../hoc/as_view';
// import withApiFetching from '../../../hoc/with_api_fetching';

// Components
import View from '../../../components/default_view';
// import Uploader from './uploader';
// import Image from './image';

class Index extends Component {

  constructor(props) {
    super(props);
    // this.state = { imageId: null };
    // bindAll(this, 'handleSelect', 'handleUpload');
  }

  // handleSelect(image) {
    // this.setState({ imageId: image.id }, () => {
    //   const { handleChange, settingType, settingId } = this.props;
    //   handleChange(settingType, settingId, {
    //     source: image.source.url,
    //     width:  image.width,
    //     height: image.height
    //   });
    // });
  // }

  // handleUpload(image) {
  //   this.handleSelect(image);
  //   this.props.handlePageChange(1);
  // }

  getValue() {
    return this.props.currentContent.settings[this.props.settingId];
  }

  render() {
    return (
      <View
        title={i18n.t('views.pickers.urls.title')}
        subTitle={this.props.blockLabel || this.props.sectionLabel}
        onLeave={this.props.leaveView}
      >
        <p>{this.getValue()}</p>
      </View>
    )
  }

}

export default compose(
  asView,
//   withApiFetching('loadAssets', { pagination: true, perPage: 11 })
)(Index);
