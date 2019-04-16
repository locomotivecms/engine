import { toInt } from '../utils/misc';
import { each, replace } from 'lodash';

const requestOptions = (verb, data, headers) => {
  const _headers = Object.assign({
    'Content-Type':   'application/json',
    'X-CSRF-Token':   document.querySelector('meta[name="csrf-token"]').content
  }, headers);

  if (_headers['Content-Type'] === null)
    delete _headers['Content-Type'];

  var options = {
    method:       verb,
    credentials:  'same-origin',
    headers:      _headers
  }

  if (verb !== 'GET')
    options.body = data;

  return options;
}

const post = (url, data, headers) => {
  return fetch(url, requestOptions('POST', data, headers));
}

const put = (url, data, headers) => {
  return fetch(url, requestOptions('PUT', data, headers));
}

const jsonPut = (url, data, headers) => {
  return put(url, JSON.stringify(data), headers)
    .then((response) => { return response.json() })
    .then((data) => {
      if (data.errors) throw(data.errors);
      return data;
    })
}

const get = (url, query, headers) => {
  var url = new URL(url, window.location.origin);
  Object.keys(query || {}).forEach(key => url.searchParams.append(key, query[key]));
  return fetch(url.href, requestOptions('GET', null, headers));
}

const jsonGet = (url, query, headers) => {
  return get(url, query, headers)
    .then((response) => {
      const headers = response.headers;
      return response.json().then(json => { return { headers, json } });
    });
}

// CONTENT

export function saveContent(url, site, page, locale) {
  return jsonPut(url, {
    content_locale: locale,
    site: { sections_content: JSON.stringify(site.sectionsContent) },
    page: {
      title: page.title,
      slug: page.slug,
      listed: page.listed,
      published: page.published,
      seo_title: page.seo_title,
      meta_keywords: page.meta_keywords,
      meta_description: page.meta_description,
      sections_content: JSON.stringify(page.sectionsContent),
      sections_dropzone_content: JSON.stringify(page.sectionsDropzoneContent)
    }
  });
}

export function loadContent(url, pageId, contentEntryId, locale) {
  const _url = replace(url, /\/pages\/[0-9a-z]+\//, `/pages/${pageId}\/`) + '.json';
  return jsonGet(_url, { content_locale: locale, content_entry_id: contentEntryId })
  .then(response => ({ data: response.json.data, urls: response.json.urls }))
}

// SECTION

export function loadSectionHTML(url, section, content) {
  return put(url,
    JSON.stringify({ section_content: content }),
    { 'Locomotive-Section-Type': section.type }
  ).then(response => { return response.text(); })
}

// CONTENT ASSETS

export function uploadAssets(url, assets) {
  var form = new FormData();
  each(assets, asset => {
    if (typeof(asset.name) == 'string')
      form.append('content_assets[][source]', asset)
    else
      form.append('content_assets[][source]', asset.blob, asset.filename)
  })

  return post(url, form, {
    'Content-Type': null
  }).then(response => response.json())
}

export function loadAssets(url, options) {
  return jsonGet(url, {
    page:     options.pagination.page || 1,
    per_page: options.pagination.perPage || 10
  })
  .then(response => {
    return {
      list:         response.json,
      pagination:   {
        page:         toInt(response.headers.get('x-current-page')),
        perPage:      toInt(response.headers.get('x-per-page')),
        totalPages:   toInt(response.headers.get('x-total-pages')),
        totalEntries: toInt(response.headers.get('x-total-entries'))
      }
    }
  });
}

export function getThumbnail(url, imageUrl, format) {
  var _imageUrl = new URL(imageUrl, window.location.origin);
  return get(url, { image: _imageUrl, format }).
  then(response => response.text())
}

// RESOURCES

export function searchForResources(url, locale, type, q, scope) {
  return jsonGet(url, { content_locale: locale, q, type, scope })
  .then(response => ({ list: response.json }));
}

export default function ApiFactory(urls, locale) {
  return {
    loadContent:        (pageId, contentEntryId, locale) => loadContent(urls.load, pageId, contentEntryId, locale),
    saveContent:        (site, page, locale) => saveContent(urls.save, site, page, locale),

    loadAssets:         (options) => loadAssets(urls.assets, options),
    uploadAssets:       (assets) => uploadAssets(urls.bulkAssetUpload, assets),
    getThumbnail:       (imageUrl, format) => getThumbnail(urls.thumbnail, imageUrl, format),

    searchForResources: (type, query, scope) => searchForResources(urls.resources, locale, type, query, scope),

    loadSectionHTML:    (sectionType, content) => loadSectionHTML(urls.preview , sectionType, content)
  };
}
