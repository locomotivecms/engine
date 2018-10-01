export function updatePageSetting(name, newValue) {
  return {
    type: 'PAGE::SETTING::UPDATE',
    name,
    newValue
  }
}
