const sendEvent = (elem, type, data) => {
  if (elem === null || elem === undefined) return false;

  console.log('firing', `locomotive::${type}`);

  var event = new CustomEvent(
    `locomotive::${type}`,
    { bubbles: true, detail: data || {} }
  );

  elem.dispatchEvent(event);
}

const scrollTo = (_window, $elem) => {
  if ($elem[0] === undefined) return false;

  $(_window.document).find('html, body').animate({
    scrollTop: $elem.offset().top
  }, 400);
}

const popSection = (_window, action, sectionId) => {
  return new Promise(resolve => {
    const $elem = $(_window.document).find(`#locomotive-section-${sectionId}`);

    if (action === 'select') scrollTo(_window, $elem);

    sendEvent($elem[0], `section::${action}`, { sectionId });
    resolve(true);
  });
}

const popBlock = (_window, action, sectionId, blockId) => {
  return new Promise(resolve => {
    const value = `section-${sectionId}-block-${blockId}`;
    const $elem = $(_window.document).find(`[data-locomotive-block='${value}']`);

    if (action === 'select') scrollTo(_window, $elem);

    sendEvent($elem[0], `block::${action}`, { sectionId, blockId });
    resolve(true);
  });
}

// Actions

export function updateSection(_window, sectionId, html) {
  return new Promise(resolve => {
    const $elem = $(_window.document).find(`#locomotive-section-${sectionId}`);

    sendEvent($elem[0], 'section::unload', { sectionId });
    $elem.html(html);
    sendEvent($elem[0], 'section::load', { sectionId });

    resolve(true);
  });
}

// Refresh the HTML of any text input elements, no matter if it belongs to a section
export function updateSectionText(_window, sectionType, sectionId, blockId, settingId, value) {
  return new Promise(resolve => {
    var dataValue = 'section-';

    dataValue += sectionId ? sectionId : sectionType;

    if (blockId)
      dataValue = `${dataValue}-block.${blockId}.${settingId}`;
    else
      dataValue = `${dataValue}.${settingId}`;

    $(_window.document)
      .find(`[data-locomotive-editor-setting='${dataValue}']`)
      .html(value);

    resolve(true);
  });
}

// Append a new section to the dropzone container. If another previewed section
// exists, it will be removed first.
export function previewSection(_window, html, sectionId, previousSectionId) {
  return new Promise(resolve => {
    // remove the previous previewed section
    const $previous = $(_window.document).find(`#locomotive-section-${previousSectionId}`);
    sendEvent($previous[0], 'section::unload', { sectionId: previousSectionId });
    $previous.remove();

    // append the new one
    const $elem = $(html);
    $(_window.document).find('.locomotive-sections').append($elem)
    sendEvent($elem[0], 'section::load', { sectionId });

    resolve(true);
  });
}

export function moveSection(_window, sectionId, targetSectionId, direction) {
  return new Promise(resolve => {
    const $elem  = $(_window.document).find(`#locomotive-section-${sectionId}`);
    const $pivot = $(_window.document).find(`#locomotive-section-${targetSectionId}`);

    if (direction === 'before')
      $elem.insertBefore($pivot);
    else
      $elem.insertAfter($pivot);

    sendEvent($elem[0], 'section::reorder', { sectionId });

    resolve(true);
  });
}

export function removeSection(_window, sectionId) {
  return new Promise(resolve => {
    const $elem = $(_window.document).find(`#locomotive-section-${sectionId}`);
    sendEvent($elem[0], 'section::unload', { sectionId });
    $elem.remove();

    resolve(true);
  });
}

export function selectSection(_window, sectionId) {
  return popSection(_window, 'select', sectionId);
}

export function deselectSection(_window, sectionId) {
  return popSection(_window, 'deselect', sectionId);
}

export function selectSectionBlock(_window, sectionId, blockId) {
  return popBlock(_window, 'select', sectionId, blockId);
}

export function deselectSectionBlock(_window, sectionId, blockId) {
  return popBlock(_window, 'select', sectionId, blockId);
}
