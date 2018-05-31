export function updateSection(_window, sectionType, html) {
  return new Promise(resolve => {
    const domID = `locomotive-section-${sectionType}`;

    $(_window.document)
      .find(`#${domID}.locomotive-section`)
      .html(html);

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

export function previewSection(_window, html, previousSectionId) {
  return new Promise(resolve => {
    $(_window.document)
      .find(`#locomotive-section-${previousSectionId}`)
      .remove();

    $(_window.document)
      .find('.locomotive-sections')
      .append(html)

    resolve(true);
  });
}

export function moveSection(_window, sectionId, targetSectionId, direction) {
  return new Promise(resolve => {
    const section  = $(_window.document).find(`#locomotive-section-${sectionId}`);
    const pivot    = $(_window.document).find(`#locomotive-section-${targetSectionId}`);

    if (direction === 'before')
      section.insertBefore(pivot);
    else
      section.insertAfter(pivot);

    resolve(true);
  });
}

export function removeSection(_window, sectionId) {
  return new Promise(resolve => {
    $(_window.document)
      .find(`#locomotive-section-${sectionId}`)
      .remove();

    resolve(true);
  });
}
