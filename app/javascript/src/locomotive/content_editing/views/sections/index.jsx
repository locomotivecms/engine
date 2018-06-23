import React, { Component } from 'react';

// Components
import StaticList from './index/static_list.jsx';
import List from './index/list.jsx';

class Index extends Component {

  render() {
    const { all, top, dropzone, bottom } = this.props.sections;

    return (
      <div className="editor-all-sections">
        {!dropzone && <StaticList list={all} />}

        {dropzone && (
          <div>
            {top.length > 0 && <StaticList list={top} />}

            <List />

            {bottom.length > 0 && <StaticList list={bottom} />}
          </div>
        )}
      </div>
    )
  }

}

export default Index;
