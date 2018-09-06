import React from 'react';
import { Link } from 'react-router-dom';

const SlideUpLink = ({ to, children, ...props }) => (
  <Link to={{ pathname: to, state: { slideDirection: 'up' }}} {...props}>
    {children}
  </Link>
)

export default SlideUpLink;
