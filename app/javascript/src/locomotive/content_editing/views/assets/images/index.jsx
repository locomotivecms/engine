import React, { Component } from 'react';
import Pagination from "react-js-pagination";

import withApiFetching from '../../../hoc/with_api_fetching';

import Uploader from './uploader.jsx';
import Image from './image.jsx';

class Index extends Component {

  constructor(props) {
    super(props);

    this.state = { imageId: null };

    this.exit         = this.exit.bind(this);
    this.onSelect     = this.onSelect.bind(this);
    this.onPageChange = this.onPageChange.bind(this);
    this.onUpload     = this.onUpload.bind(this);
  }

  exit() {
    this.props.history.goBack();
  }

  onPageChange(page) {
    this.props.onPageChange(page);
  }

  onSelect(imageId) {
    this.setState({ imageId }, () => {
      console.log('TODO: notify someone the we pick an image!');
    });
  }

  onUpload(imageId) {
    this.setState({ imageId });
    this.props.onPageChange(1);
  }

  render() {
    return (
      <div className="editor-image-picker">
        <div className="editor-image-picker-header">
          <div className="row header-row">
            <div className="col-md-12">
              <h1>
                Images
                &nbsp;
                <small>
                  <a onClick={this.exit}>Back</a>
                </small>
              </h1>
            </div>
          </div>

          <Uploader onUpload={this.onUpload} />
        </div>

        {this.props.isLoading ? (
          <p>Loading the assets</p>
        ) : (
          <div className="editor-image-list">
            <div className="editor-image-inner-list">
              {this.props.list.map(image =>
                <Image
                  key={image.id}
                  selected={image.id === this.state.imageId}
                  onSelect={this.onSelect}
                  {...image}
                />
              )}
            </div>
          </div>
        )}

        {!this.props.isLoading && (
          <div className="editor-image-pagination">
            <Pagination
              innerClass="pagination pagination-sm"
              activePage={this.props.pagination.page}
              itemsCountPerPage={this.props.pagination.perPage}
              totalItemsCount={this.props.pagination.totalEntries}
              pageRangeDisplayed={5}
              onChange={this.onPageChange}
            />
          </div>
        )}
      </div>
    )
  }

}

export default withApiFetching('loadAssets', { pagination: true, perPage: 18 })(Index);
