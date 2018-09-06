import React from 'react';
import { Link } from 'react-router-dom';

const SlideRightLink = ({ to, children, ...props }) => (
  <Link to={{ pathname: to, state: { slideDirection: 'right' }}} {...props}>
    {children}
  </Link>
)

export default SlideRightLink;
