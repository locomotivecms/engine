import React from 'react';
import { BrowserRouter as Router, Switch, Route, Redirect, browserHistory } from 'react-router-dom';

// HOC
import withRedux from '../hoc/with_redux';
import withHeader from '../hoc/with_header';

// Views
import _Startup from './startup.jsx';
import _EditableElementsIndex from './editable_elements/list.jsx';
import _SectionsIndex from './sections/index.jsx';
import SectionGallery from './sections/gallery.jsx';
import EditSection from './sections/edit.jsx';
import EditBlock from './blocks/edit.jsx';
import ImagesIndex from './assets/images/index.jsx';

const Startup               = withHeader(_Startup);
const SectionsIndex         = withHeader(_SectionsIndex);
const EditableElementsIndex = withHeader(_EditableElementsIndex)

const togglePreview = (event) => {
  $('.content-main').toggleClass('actionbar-closed');
}

const Main = props => (
  <div className="actionbar">
    <div className="actionbar-trigger" onClick={togglePreview}>
      <i className="fa fa-chevron-left"></i>
    </div>
    <div className="content">
      <Router history={browserHistory} basename={props.basepath}>
        <div className="container-fluid main" role="main">
          {!props.iframe.loaded && <Startup />}

          {props.iframe.loaded && (
           <Switch>
              <Route exact path="/" render={() => (
                props.hasSections ? (
                  <Redirect to="/sections" />
                ) : (
                  <Redirect to="/editable_elements" />
                )
              )} />

              <Route exact path="/sections" component={SectionsIndex} />

              <Route path="/sections/:sectionType/edit" component={EditSection} />
              <Route path="/sections/:sectionType/blocks/:blockType/:blockId/edit" component={EditBlock} />
              <Route path="/sections/:sectionType/blocks/:blockType/:blockId/:settingId/images" component={ImagesIndex} />

              <Route exact path="/dropzone_sections/pick" component={SectionGallery} />
              <Route path="/dropzone_sections/:sectionType/:sectionId/edit" component={EditSection} />
              <Route path="/dropzone_sections/:sectionType/:sectionId/blocks/:blockType/:blockId/edit" component={EditBlock} />
              <Route path="/dropzone_sections/:sectionType/:sectionId/blocks/:blockType/:blockId/:settingId/images" component={ImagesIndex} />

              <Route exact path="/editable_elements" component={EditableElementsIndex} />

              <Route render={() => <Redirect to="/" />} />
            </Switch>
          )}
        </div>
      </Router>
    </div>
  </div>
)

export default withRedux(state => ({ iframe: state.iframe }))(Main);
