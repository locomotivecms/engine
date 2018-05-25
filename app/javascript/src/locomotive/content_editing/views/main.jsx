import React, { Component } from 'react';
import { BrowserRouter as Router, Route, Link, browserHistory } from 'react-router-dom';
import withRedux from '../utils/with_redux';

// Views
import Startup from './startup.jsx';
import ListSections from './sections/list.jsx';
import EditSection from './sections/edit.jsx';
import EditBlock from './blocks/edit.jsx';

// Components
import Header from '../components/header.jsx';

class Main extends React.Component {

  constructor(props) {
    super(props);
    this.togglePreview = this.togglePreview.bind(this);
  }

  togglePreview(event) {
    $('.content-main').toggleClass('actionbar-closed');
  }

  render() {
    return (
      <div className="actionbar">
        <div className="actionbar-trigger" onClick={this.togglePreview}>
          <i className="fa fa-chevron-left"></i>
        </div>
        <div className="content">
          <Router history={browserHistory} basename={this.props.basepath}>
            <div className="container-fluid main" role="main">
              <Header />
              {!this.props.iframe.loaded && <Startup />}
              {this.props.iframe.loaded &&
                <div>
                  <Route exact path="/" component={ListSections} />
                  <Route path="/sections/:type/edit" component={EditSection}/>
                  <Route path="/sections/:type/blocks/:blockId/edit" component={EditBlock}/>
                </div>
              }
            </div>
          </Router>
        </div>
      </div>
    )
  }

}

export default withRedux(Main, state => { return { iframe: state.iframe } })
