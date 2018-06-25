export function waitUntil(startedAt, minDelay, callback) {
  var delay = Math.abs(new Date().getMilliseconds() - startedAt);
  delay = delay < minDelay ? minDelay - delay : 0;
  setTimeout(callback, delay);
}

export function isBlank(value) {
  return value === undefined || value === null || value === '' || value.length === 0;
}

// https://stackoverflow.com/a/8809472
export function uuid() {
  var d = new Date().getTime();
  if (typeof performance !== 'undefined' && typeof performance.now === 'function'){
      d += performance.now(); //use high-precision timer if available
  }
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
    var r = (d + Math.random() * 16) % 16 | 0;
    d = Math.floor(d / 16);
    return (c === 'x' ? r : (r & 0x3 | 0x8)).toString(16);
  });
}

// Swap an element of an array to its new position
export function arrayMove(array, oldIndex, newIndex) {
  var newArray = [];

  if (oldIndex === newIndex) return array;

  for (var index = 0; newArray.length < array.length; index++) {
    if (index === newIndex) {
      if (newIndex < oldIndex)
        newArray.push(array[oldIndex], array[index]);
      else
        newArray.push(array[index], array[oldIndex]);
    } else if (index !== oldIndex)
      newArray.push(array[index]);
  }

  return newArray
}

// parse an integer/float and returns null if it's not an integer
export function toInt(number) {
  if (number === '0') return 0;
  return parseInt(number) || null
}

export function argNames(func) {
  return func.toString().replace(/.*\(|\).*/ig, '').split(',')
}
