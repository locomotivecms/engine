import React from 'react';
import { Link } from 'react-router-dom';

const SlideLeftLink = ({ to, children, ...props }) => (
  <Link to={{ pathname: to, state: { slideDirection: 'left' }}} {...props}>
    {children}
  </Link>
)

export default SlideLeftLink;
