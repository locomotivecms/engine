import { configure } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';

global.Locomotive = {
  data: {
    locale: 'en'
  },
  i18n: {
    'views': {
      'startup': {
        'waiting': 'Waiting...'
      }
    }
  }
};

configure({ adapter: new Adapter() });

