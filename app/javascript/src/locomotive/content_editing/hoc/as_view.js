import { compose } from 'redux';

import withRedux from './with_redux';
import withNavParams from './with_nav_params';
import withRoutes from './with_routes';

export default compose(
  withRedux(state => { return {
    staticContent:  state.site.sectionsContent,
    content:        state.page.sectionsContent,
    definitions:    state.sectionDefinitions
  } }),
  withNavParams,
  withRoutes
);
