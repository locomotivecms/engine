import React, { Component } from 'react';
import { Provider } from 'react-redux';
import { BrowserRouter as Router, browserHistory } from 'react-router-dom';
import { pick } from 'lodash';

import store from './store';
// import GlobalContext from './context';

import withRedux from './hoc/with_redux';

// Views/Components
import Main from './views/main.jsx';
import Preview from './views/preview.jsx';

const App = props => (
  <Provider store={store}>
    <Router history={browserHistory} basename={props.basePath}>
      <div>
        <Main />
        <Preview src={props.previewPath} />
      </div>
    </Router>
  </Provider>
)

// class _App extends Component {
//   render() {
//     console.log('_App rendering!')
//     return (
//       <Router history={browserHistory} basename={this.props.basePath}>
//         <div>
//           <Main />
//           <Preview src={this.props.previewPath} />
//         </div>
//       </Router>
//     )
//   }
// }

// const __App = withRedux(state => ({
//   basePath:     state.editor.urls.base
//   // previewPath:  state.editor.urls.preview
// }))(_App);


// const App = props => (
//   <Provider store={store}>
//     <__App {...props} />
//   </Provider>
// )

export default App;
