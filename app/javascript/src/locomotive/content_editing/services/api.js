const requestOptions = (verb, data) => {
  return {
    method:       verb,
    body:         JSON.stringify(data),
    credentials: 'same-origin',
    headers: {
      'Content-Type':   'application/json',
      'X-CSRF-Token':   document.querySelector('meta[name="csrf-token"]').content
    }
  }
}

const put = (url, data) => {
  return fetch(url, requestOptions('PUT', data));
}

const jsonPut = (url, data) => {
  return put(url, data)
    .then((response) => { return response.json() })
    .then((data) => {
      if (data.errors) throw(data.errors);
      return data;
    })
}

export function saveContent(site, page) {
  return jsonPut(window.Locomotive.urls.save, {
    site: { sections_content: JSON.stringify(site.sectionsContent) },
    page: { sections_content: JSON.stringify(page.sectionsContent) }
  });
}

export function loadSectionHTML(sectionType, content) {
  const url = `${window.Locomotive.urls.preview}/_sections/${sectionType}`;
  return put(url, { section_content: content[sectionType] })
    .then(response => { return response.text(); })
}
