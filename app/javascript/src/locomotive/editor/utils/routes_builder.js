import React from 'react';
import { transform, omit } from 'lodash';

const _build = (tree, prefix, routes) => {
  return transform(tree, (result, value, key) => {
    const path = `${prefix}${key}`;

    if (typeof(value) === 'object') {
      if (value.component)
        result.push({ path, component: value.component, exact: true });

      _build(omit(value, ['component', 'exact']), path, result);
    } else
      result.push({ path, component: value });
  }, routes);
}

const buildRoutes = tree => {
  return _build(tree, '', []);
}

export default buildRoutes;
