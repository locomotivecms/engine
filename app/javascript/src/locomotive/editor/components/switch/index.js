import React from 'react';
import CoreSwitch from 'rc-switch';

const Switch = ({ onChange, checked }) => (
  <CoreSwitch
    onChange={onChange}
    checked={checked}
    checkedChildren={<i className="fas fa-check" />}
    unCheckedChildren=" "
  />
)

export default Switch;
