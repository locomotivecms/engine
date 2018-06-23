import { compose } from 'redux';

import withRedux from './with_redux';
import withGlobalVars from './with_global_vars';
import withNavParams from './with_nav_params';
import withRoutes from './with_routes';

export default compose(
  withRedux(state => { return {
    staticContent:  state.site.sectionsContent,
    content:        state.page.sectionsContent
  } }),
  withGlobalVars,
  withNavParams,
  withRoutes
);
