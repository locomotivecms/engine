import React from 'react';
import { UrlsContext } from '../context';

export default function withUrls(Component) {
  return function WrappedComponent(props) {
    return (
      <UrlsContext.Consumer>
        {urls => <Component {...props} urls={urls} />}
      </UrlsContext.Consumer>
    );
  };
}
