export function updateTextValue(window, sectionType, settingId, value) {
  const dataValue = `section-${sectionType}.${settingId}`;

  $(window.document)
    .find(`[data-locomotive-editor-setting='${dataValue}']`)
    .html(value);
}

export function updateBlockTextValue(window, sectionType, blockId, settingId, value) {
  const dataValue = `section-${sectionType}-block.${blockId}.${settingId}`;

  $(window.document)
    .find(`[data-locomotive-editor-setting='${dataValue}']`)
    .html(value);
}

export function updateStaticSection(window, sectionType, html) {
  const domID   = `locomotive-section-${sectionType}`;

  $(window.document)
    .find(`#${domID}.locomotive-section`)
    .html(html);
}
