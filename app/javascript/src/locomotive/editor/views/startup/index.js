import React from 'react';
import i18n from '../../i18n';

// Components
import View from '../../components/default_view';

const Startup = props => (
  <View>
    <div className="editor-startup">
      <div>
        {i18n.t('views.startup.waiting')}
      </div>
    </div>
  </View>
)

export default Startup;
