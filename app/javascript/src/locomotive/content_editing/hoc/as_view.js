import { compose } from 'redux';

import withRoutes from './with_routes';
import withRedux from './with_redux';
import withGlobalVars from './with_global_vars';
import withEditingSection from './with_editing_section';

export default compose(
  withRoutes,
  withRedux(state => { return {
    staticContent:  state.site.sectionsContent,
    content:        state.page.sectionsContent
  } }),
  withGlobalVars,
  withEditingSection
);
