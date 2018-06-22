import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import * as actionCreators from '../actions/action_creators.js';

// Easy shortcut to connect a React component to the global store + actions
const withRedux = mapStateToProps => {

  function mapDispachToProps(dispatch) {
    return bindActionCreators(actionCreators, dispatch);
  }

  return connect(mapStateToProps, mapDispachToProps);
}

export default withRedux;
