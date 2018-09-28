import update from 'immutability-helper';
import { arrayMove } from './misc';

// Extending immutability-helper
// https://github.com/kolodny/immutability-helper#adding-your-own-commands

update.extend('$arrayMove', function({ oldIndex, newIndex }, array) {
  return arrayMove(array, oldIndex, newIndex);
});

export default update;
