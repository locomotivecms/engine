import React from 'react';
import { Link } from 'react-router-dom';

const Section = props => {
  const Handle = props.handleComponent;
  return (
    <div>
      <Handle />
      &nbsp;
      {props.section.name}
      &nbsp;
      <Link to={props.editPath}>Edit</Link>
      &nbsp;
      <button className="btn btn-primary btn-xs" onClick={props.removeSection}>
        Delete
      </button>
    </div>
  )
}

export default Section;
