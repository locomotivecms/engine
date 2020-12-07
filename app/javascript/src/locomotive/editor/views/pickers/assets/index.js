import React, { Component } from 'react';
import Pagination from 'react-js-pagination';
import { compose } from 'redux';
import { bindAll, debounce } from 'lodash'
import i18n from '../../../i18n';

// HOC
import asView from '../../../hoc/as_view';
import withApiFetching from '../../../hoc/with_api_fetching';

// Components
import View from '../../../components/default_view';
import Uploader from './uploader';
import Asset from './asset';

class Index extends Component {

  constructor(props) {
    super(props);
    this.state = { query: '' };
    this.handleSearchParamsChange = debounce(this.props.handleSearchParamsChange, 500);
    bindAll(this, 'handleSelect', 'handleUpload', 'handleSearch');
  }

  handleSelect(asset) {
    const { handleChange, settingType, settingId } = this.props;
    const { source: { url }, type, size } = asset;
    handleChange(settingType, settingId, { url, type, size });
    this.props.leaveView();
  }

  handleUpload(image) {
    this.handleSelect(image);
    this.props.handlePageChange(1);
  }

  handleSearch(event) {
    const { target: { value: query } } = event;
    this.setState({ query });
    this.handleSearchParamsChange({ query }); 
  }

  render() {
    return (
      <View
        title={i18n.t('views.pickers.assets.title')}
        subTitle={this.props.blockLabel || this.props.sectionLabel}
        onLeave={this.props.leaveView}
      >
        {this.props.isLoading ? (
          <div className="editor-image-list--loading">
            <div className="editor-image-list--loading-text">
              {i18n.t('views.pickers.assets.loading')}
            </div>
          </div>
        ) : (                
          <div className="editor-asset-list">
            <div className="editor-asset-list--search">
              <input 
                type="text" 
                placeholder={i18n.t('views.pickers.assets.search_placeholder')} 
                value={this.state.query} 
                onChange={this.handleSearch} 
                className="editor-input--text"
              />
            </div>
            <div className="editor-asset-list--container">
              <Uploader
                handleUpload={this.handleUpload}
                uploadAssets={this.props.api.uploadAssets}
              />

              {this.props.list.map(asset =>
                <Asset
                  key={asset.id}
                  handleSelect={this.handleSelect.bind(null, asset)}
                  {...asset}
                />
              )}
            </div>

            <div className="editor-asset-list--pagination">
              <Pagination
                innerClass="pagination pagination-sm"
                activePage={this.props.pagination.page}
                itemsCountPerPage={this.props.pagination.perPage}
                totalItemsCount={this.props.pagination.totalEntries}
                pageRangeDisplayed={10}
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
