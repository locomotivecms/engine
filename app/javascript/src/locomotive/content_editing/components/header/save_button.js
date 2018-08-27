import React, { Component } from 'react';
import { bindAll } from 'lodash';

class SaveButton extends React.Component {

  constructor(props) {
    super(props);
    bindAll(this, 'save');
  }

  save() {
    const { persistChanges, site, page } = this.props;

    this.props.api.saveContent(site, page)
    .then((data) => { persistChanges(true) })
    .catch((errors) => { persistChanges(false, errors) });
  }

  render() {
    return <button
      className="btn btn-primary btn-sm"
      onClick={this.save}
    >
      Save
    </button>
  }

}

export default SaveButton;
