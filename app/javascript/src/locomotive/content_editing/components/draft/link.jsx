import React, { Component } from 'react';
import { bindAll } from 'lodash';
import classNames from 'classnames';
import { b64EncodeUnicode, b64DecodeUnicode } from '../../utils/misc';

// Components
import Option from './option.jsx';
import UrlPicker from '../url_picker';

const LINK_REGEXP = /\/#link_target=(.+)/

const stopPropagation = event => {
  event.stopPropagation();
  return false;
}

class Link extends Component {

  constructor(props) {
    super(props);
    this.state = {
      showModal: false,
      linkTarget: '',
      linkTitle: '',
      linkTargetOption: this.props.config.defaultTargetOption
    };

    bindAll(this,
      'renderAddLinkModal', 'hideModal', 'signalExpandShowModal',
      'forceExpandAndShowModal', 'onUpdate', 'removeLink'
    );
  }

  componentWillReceiveProps(props) {
    if (this.props.expanded && !props.expanded) {
      this.setState({
        showModal: false,
        linkTarget: '',
        linkTitle: '',
        linkTargetOption: this.props.config.defaultTargetOption
      });
    }
  }

  hideModal() {
    this.setState({ showModal: false });
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

  forceExpandAndShowModal() {
    const { doExpand, currentState: { link, selectionText } } = this.props;
    const { linkTargetOption } = this.state;
    doExpand();
    this.setState({
      showModal: true,
      linkTarget: link && link.target,
      linkTargetOption: (link && link.targetOption) || linkTargetOption,
      linkTitle: (link && link.title) || selectionText,
    });
  }

  encodeResource(resource) {
    const parameter = b64EncodeUnicode(JSON.stringify(resource));
    const baseUrl   = window.location.origin;
    return `${baseUrl}/#link_target=${parameter}`;
  }

  decodeResource(url) {
    const matches = url.match(LINK_REGEXP);

    if (matches && matches.length > 1)
      return JSON.parse(b64DecodeUnicode(matches[1]))
    else
      return null;
  }

  onUpdate(resource) {
    const { onChange } = this.props;
    const { linkTitle, linkTargetOption } = this.state;
    const linkTarget = this.encodeResource(resource);
    onChange('link', linkTitle, linkTarget, linkTargetOption);
  }

  removeLink() {
    const { onChange } = this.props;
    onChange('unlink');
  }

  renderAddLinkModal() {
    const { config: { popupClassName }, doCollapse, translations } = this.props;
    const { linkTitle, linkTarget, linkTargetOption } = this.state;

    return (
      <div
        className={classNames('rdw-link-modal', popupClassName)}
        onClick={stopPropagation}
      >
        <UrlPicker
          value={this.decodeResource(linkTarget) || linkTitle}
          handleChange={this.onUpdate}
        />
      </div>
    )
  }

  render() {
    const {
      config: { options, link, unlink, className },
      currentState,
      expanded,
      translations,
    } = this.props;
    const { showModal } = this.state;
    return (
      <div className={classNames('rdw-link-wrapper', className)} aria-label="rdw-link-control">
        {options.indexOf('link') >= 0 && <Option
          value="unordered-list-item"
          className={classNames(link.className)}
          onClick={this.signalExpandShowModal}
          aria-haspopup="true"
          aria-expanded={showModal}
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
          onClick={this.removeLink}
          title={unlink.title || translations['components.controls.link.unlink']}
        >
          <img
            src={unlink.icon}
            alt=""
          />
        </Option>}
        {expanded && showModal ? this.renderAddLinkModal() : undefined}
      </div>
    );
  }

}

export default Link;
