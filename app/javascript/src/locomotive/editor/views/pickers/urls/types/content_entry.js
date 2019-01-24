import React, { Component } from 'react';
import { find } from 'lodash';
import update from 'immutability-helper';
import { isBlank } from '../../../../utils/misc';
import i18n from '../../../../i18n';

// Components
import Autosuggest from './shared/autosuggest';
import Select from './shared/select';
import NewWindowCheckbox from './shared/new_window_checkbox';

// Helpers
const getContentType = (contentTypes, slug) => find(contentTypes, type => type.slug === slug) || contentTypes[0];
const getPage = (pages, id) => find(pages, page => page.id === id) || pages[0];

class ContentEntry extends Component {

  constructor(props) {
    super();
    this.state = { settings: { value: {} } };
  }

  componentDidMount() {
    const { settings, contentTypes } = this.props;
    const contentType = getContentType(contentTypes, settings?.value?.content_type_slug);
    const page        = getPage(contentType.pages, settings?.value?.page_id);

    this.setState({ settings, contentType, page });
  }

  _handleChange(settings, extraData) {
    this.setState({ ...extraData, settings }, () => this.props.handleChange(this.state.settings));
  }

  handleContentTypeChanged(newSlug) {
    this._handleChange(
      { value: { content_type_slug: newSlug }, new_window: this.state.settings.new_window }, {
      contentType: getContentType(this.props.contentTypes, newSlug)
    });
  }

  handleContentEntryChanged(newSettings) {
    this._handleChange(
      update(newSettings, { value: { page_id: { $set: this.state.contentType.pages[0].id } } })
    );
  }

  handlePageChanged(newPageId) {
    this._handleChange(
      update(this.state.settings, { value: { page_id: { $set: newPageId } } }), {
        page: getPage(this.state.contentType.pages, newPageId)
      }
    );
  }

  handleSectionChanged(newAnchor) {
    this._handleChange(
      update(this.state.settings, { anchor: { $set: newAnchor } })
    );
  }

  handleNewWindowChanged(checked) {
    this._handleChange(
      update(this.state.settings, { new_window: { $set: checked } })
    );
  }

  renderContentTypeSelect() {
    const list = this.props.contentTypes.map(data => [data.name, data.slug]);

    return (
      <Select
        label={i18n.t('views.pickers.url.content_entry.content_type_label')}
        value={this.state.settings.value?.content_type_slug}
        list={list}
        onChange={slug => this.handleContentTypeChanged(slug)}
      />
    );
  }

  renderContentEntryPicker() {
    const { settings, contentType } = this.state;

    return (
      <Autosuggest
        label={i18n.t('views.pickers.url.content_entry.label')}
        placeholder={i18n.t('views.pickers.url.content_entry.placeholder')}
        input={(settings?.label || [])[1] || ''}
        search={input => this.props.api.searchForResources('content_entry', input, contentType.slug) }
        handleChange={value => this.handleContentEntryChanged(value)}
        handleNewInput={() => this.setState({ settings: {}, page: null })}
      />
    );
  }

  renderPagePicker() {
    const list = this.state.contentType.pages.map(page => [page.title, page.id]);

    return (
      <Select
        label={i18n.t('views.pickers.url.page.label')}
        value={this.state.settings.page_id}
        list={list}
        onChange={id => this.handlePageChanged(id)}
      />
    )
  }

  renderPageSectionPicker() {
    const list = this.props.buildSectionOptions(this.state.page.sections);

    return (
      <Select
        label={i18n.t('views.pickers.url.page.section_label')}
        value={this.state.settings.anchor}
        list={list}
        includeEmpty={true}
        onChange={anchor => this.handleSectionChanged(anchor)}
      />
    )
  }

  renderNewWindowCheckbox() {
    return (
      <NewWindowCheckbox
        label={i18n.t('views.pickers.url.open_new_window')}
        checked={this.state.settings.new_window}
        onChange={checked => this.handleNewWindowChanged(checked)}
      />
    )
  }

  render() {
    const { contentType, page, settings: { value } } = this.state;

    return (
      <div className="url-picker-page-settings">
        {contentType && this.renderContentTypeSelect()}

        {contentType && this.renderContentEntryPicker()}

        {contentType && value?.id && this.renderPagePicker()}

        {contentType && value?.id && !isBlank(page?.sections) && this.renderPageSectionPicker()}

        {contentType && this.renderNewWindowCheckbox()}
      </div>
    )
  }

}

export default ContentEntry;
