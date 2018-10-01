import React from "react";

const Sections = props => (
  <svg
    xmlnsXlink="http://www.w3.org/1999/xlink"
    width={12}
    height={11}
    {...props}
  >
    <defs>
      <path id="a" d="M0 8h12v3H0z" />
      <mask id="b" width={12} height={3} x={0} y={0} fill="#fff">
        <use xlinkHref="#a" />
      </mask>
    </defs>
    <g fill="none" fillRule="evenodd" stroke={props.color || '#000'}>
      <path d="M.5.5h11v2H.5zm0 4h11v2H.5z" />
      <use
        strokeDasharray="2,1,2,1"
        strokeWidth={2}
        mask="url(#b)"
        xlinkHref="#a"
      />
    </g>
  </svg>
);

export default Sections;
