import React, { Component } from 'react';
import { BrowserRouter as Router, Switch, Route, Redirect, Link, browserHistory } from 'react-router-dom';
import withRedux from '../hoc/with_redux';

// Views
import Startup from './startup.jsx';
import ListEditableElements from './editable_elements/list.jsx';
import SectionIndex from './sections/index.jsx';
import SectionGallery from './sections/gallery.jsx';
import EditSection from './sections/edit.jsx';
import EditBlock from './blocks/edit.jsx';
import ImagesIndex from './assets/images/index.jsx';

// Components
import Header from '../components/header.jsx';

const withHeader = (View, _props) => props => (
  <div className="editor-view">
    <Header
      urls={_props.urls}
      withSections={_props.sections.all.length > 0}
      withEditableElements={_props.editableElements.length > 0}
      {...props}
    />
    <View {..._props} {...props} />
  </div>
)

const NoMatch = props => (
  <Redirect to="/" />
)

export class Main extends React.Component {

  constructor(props) {
    super(props);
    this.togglePreview = this.togglePreview.bind(this);
  }

  togglePreview(event) {
    $('.content-main').toggleClass('actionbar-closed');
  }

  hasEditableElements() {
    return this.props.sections.all.length > 0;
  }

  hasSections() {
    return this.props.sections.all.length > 0 || this.props.sections.dropzone;
  }

  getHomeComponent() {
    return this.hasSections() ? SectionIndex : ListEditableElements;
  }

  render() {
    const Home = withHeader(this.getHomeComponent(), this.props);

    return (
      <div className="actionbar">
        <div className="actionbar-trigger" onClick={this.togglePreview}>
          <i className="fa fa-chevron-left"></i>
        </div>
        <div className="content">
          <Router history={browserHistory} basename={this.props.basepath}>
            <div className="container-fluid main" role="main">
              {!this.props.iframe.loaded && withHeader(Startup, this.props)({})}

              {this.props.iframe.loaded && (
               <Switch>
                  <Route exact path="/" render={Home} />

                  <Route exact path="/sections" render={withHeader(SectionIndex, this.props)} />

                  <Route path="/sections/:type/edit" component={EditSection} />
                  <Route path="/sections/:type/blocks/:blockType/:blockId/edit" component={EditBlock} />
                  <Route path="/sections/:type/blocks/:blockType/:blockId/:settingId/images" component={ImagesIndex} />

                  <Route exact path="/dropzone_sections/pick" component={SectionGallery} />
                  <Route path="/dropzone_sections/:sectionType/:sectionId/edit" component={EditSection} />
                  <Route path="/dropzone_sections/:sectionType/:sectionId/blocks/:blockType/:blockId/edit" component={EditBlock} />

                  <Route exact path="/editable_elements" render={withHeader(ListEditableElements, this.props)} />
                  <Route render={NoMatch} />
                </Switch>
              )}
            </div>
          </Router>
        </div>
      </div>
    )
  }

}

export default withRedux(state => { return { iframe: state.iframe } })(Main);
