import React, { Component } from 'react';

class Image extends Component {

  constructor(props) {
    super(props);
    this.select = this.select.bind(this);
  }

  select() {
    this.props.onSelect(this.props.id);
  }

  render() {
    return (
      <div className={`editor-image ${this.props.selected ? 'active' : ''}`}>
        <div className="editor-image-inner" onClick={this.select}>
          <img src={this.props.thumbnail_url} />
        </div>
      </div>
    )
  }

}

export default Image
