import React, { Component } from 'react';
import Pagination from 'react-js-pagination';
import { compose } from 'redux';
import { bindAll } from 'lodash';
import i18n from '../../../i18n';

// HOC
import asView from '../../../hoc/as_view';
import withApiFetching from '../../../hoc/with_api_fetching';

// Components
import View from '../../../components/default_view';
import Uploader from './uploader';
import Image from './image';

class Index extends Component {

  constructor(props) {
    super(props);
    this.state = { imageId: null };
    bindAll(this, 'handleSelect', 'handleUpload');
  }

  handleSelect(image) {
    this.setState({ imageId: image.id }, () => {
      const { handleChange, settingType, settingId } = this.props;
      handleChange(settingType, settingId, {
        source: image.source.url,
        width:  image.width,
        height: image.height
      });
    });
  }

  handleUpload(image) {
    this.handleSelect(image);
    this.props.handlePageChange(1);
  }

  render() {
    return (
      <View
        title={i18n.t('views.pickers.images.title')}
        subTitle={this.props.blockLabel || this.props.sectionLabel}
        onLeave={this.props.leaveView}
      >
        {this.props.isLoading ? (
          <div className="editor-image-list--loading">
            <div className="editor-image-list--loading-text">
              {i18n.t('views.pickers.images.loading')}
            </div>
          </div>
        ) : (
          <div className="editor-image-list">
            <div className="editor-image-list--container">
              <Uploader
                handleUpload={this.handleUpload}
                uploadAssets={this.props.api.uploadAssets}
                compress={this.props.setting.compress}
              />

              {this.props.list.map(image =>
                <Image
                  key={image.id}
                  selected={image.id === this.state.imageId}
                  handleSelect={this.handleSelect.bind(null, image)}
                  {...image}
                />
              )}
            </div>

            <div className="editor-image-list--pagination">
              <Pagination
                innerClass="pagination pagination-sm"
                activePage={this.props.pagination.page}
                itemsCountPerPage={this.props.pagination.perPage}
                totalItemsCount={this.props.pagination.totalEntries}
                pageRangeDisplayed={5}
                onChange={this.props.handlePageChange}
              />
            </div>
          </div>
        )}
      </View>
    )
  }

}

export default compose(
  asView,
  withApiFetching('loadAssets', { pagination: true, perPage: 11 })
)(Index);
