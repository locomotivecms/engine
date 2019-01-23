import React, { Component, Fragment } from 'react';
import { compose } from 'redux';
import classNames from 'classnames';
import { isBlank, encodeLinkResource, decodeLinkResource, findParentElement } from '../../utils/misc';
import i18n from '../../i18n';

// HOC
import withRedux from '../../hoc/with_redux';
import withGlobalVars from '../../hoc/with_global_vars';

// Components
import Option from './option.jsx';
import Modal from '../modal';
import UrlPicker from '../../views/pickers/urls/main';

class Link extends Component {

  constructor(props) {
    super(props);
    this.state = {
      showModal: false,
      resource: null,
      linkTarget: '',
      linkTitle: '',
      linkTargetOption: this.props.config.defaultTargetOption
    };
  }

  componentDidMount() {
    // FIXME: little hack to make the select tags work inside a modal
    document.addEventListener('mousedown', event => {
      if (event.target.tagName === 'SELECT') event.stopPropagation();
    }, true);
  }

  signalExpandShowModal() {
    const { onExpandEvent, currentState: { link, selectionText } } = this.props;
    const { linkTargetOption } = this.state;
    onExpandEvent();
    this.setState({
      showModal: true,
      linkTarget: (link && link.target) || '',
      linkTargetOption: (link && link.targetOption) || linkTargetOption,
      linkTitle: (link && link.title) || selectionText,
    });
  }

  hideModal() {
    this.setState({ showModal: false, resource: null });
  }

  onUpdate(type, resource) {
    this.setState({ resource: Object.assign({}, resource, { type }) });
  }

  insertLink() {
    const { linkTitle, resource } = this.state;

    if (!isBlank(resource?.value)) {
      const target        = encodeLinkResource(resource);
      const { onChange }  = this.props;
      const targetOption  = resource.new_window ? '_blank' : null;

      // insert/change the link
      onChange('link', linkTitle, target, targetOption);

      // close the modal
      this.hideModal();
    }
  }

  removeLink() {
    this.props.onChange('unlink');
  }

  renderAddLinkModal() {
    const { showModal, linkTitle, linkTarget, linkTargetOption } = this.state;

    return (
      <Modal
        title={i18n.t('components.draft.link.title')}
        isOpen={showModal}
        onClose={() => this.hideModal()}
      >
        <UrlPicker
          api={this.props.api}
          url={showModal ? decodeLinkResource(linkTarget) || linkTitle : ''}
          contentTypes={this.props.contentTypes}
          findSectionDefinition={this.props.findSectionDefinition}
          updateContent={(type, resource) => this.onUpdate(type, resource)}
        />

        <div className="rdw-link-modal-actions">
          <button className="btn btn-default btn-sm" onClick={event => this.insertLink()}>
            {i18n.t('components.draft.link.insert_link')}
          </button>
        </div>
      </Modal>
    );
  }

  render() {
    const {
      config: { options, link, unlink, className },
      currentState,
      expanded,
      translations,
    } = this.props;

    return (
      <div className={classNames('rdw-link-wrapper', className)} aria-label="rdw-link-control">
        {options.indexOf('link') >= 0 && <Option
          value="unordered-list-item"
          className={classNames(link.className)}
          onClick={e => this.signalExpandShowModal()}
          aria-haspopup="true"
          aria-expanded={this.state.showModal}
          title={link.title || translations['components.controls.link.link']}
        >
          <img
            src={link.icon}
            alt=""
          />
        </Option>}

        {options.indexOf('unlink') >= 0 && <Option
          disabled={!currentState.link}
          value="ordered-list-item"
          className={classNames(unlink.className)}
          onClick={e => this.removeLink()}
          title={unlink.title || translations['components.controls.link.unlink']}
        >
          <img
            src={unlink.icon}
            alt=""
          />
        </Option>}

        {this.renderAddLinkModal()}
      </div>
    );
  }

}

export default compose(
  withGlobalVars,
  withRedux(state => ({ contentTypes: state.editor.contentTypes }))
)(Link);
