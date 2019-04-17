import React, { Component } from 'react';
import { isBlank, presence } from '../../../utils/misc';
import { bindAll } from 'lodash';
import classnames from 'classnames';
import i18n from '../../../i18n';

// HOC
import asView from '../../../hoc/as_view';

// Services
import { build as buildBlock } from '../../../services/blocks_service';

// Components
import View from '../../../components/default_view';
import Input from '../../../inputs/base';
import BlockList from './block_list';
import NewBlockPicker from './new_block_picker';

class Edit extends Component {

  constructor(props) {
    super(props);
    bindAll(this, 'addBlock', 'moveBlock', 'removeSection', 'renderRemoveButton');
  }

  // Called when an editor adds a new block
  addBlock(blockType) {
    this.props.addSectionBlock(
      this.props.section,
      buildBlock(
        this.props.sectionDefinition,
        blockType || this.props.sectionDefinition.blocks[0].type
      )
    )
  }

  // Called when an editor changes the block order
  moveBlock({ oldIndex, newIndex }) {
    this.props.moveSectionBlock(
      this.props.section,
      oldIndex,
      newIndex
    )
  }

  removeSection() {
    if (confirm(i18n.t('shared.confirm'))) {
      this.props.removeSection(this.props.section);
      this.props.redirectTo(this.props.rootPath());
    }
  }

  renderRemoveButton() {
    // don't display the button for non-dropable sections
    if (this.props.section.source !== 'dropzone') return null;

    return (
      <a href="#" onClick={this.removeSection}>
        <i className="far fa-trash-alt"></i>
      </a>
    )
  }

  render() {
    const { translate } = this.props;

    return (
      <View
        title={translate(presence(this.props.sectionLabel) || this.props.sectionDefinition.name)}
        onLeave={this.props.leaveView}
        renderAction={this.renderRemoveButton}
      >
        <div className="editor-edit-section">

          <div className="editor-section-settings">
            {this.props.sectionDefinition.settings.map((setting, index) =>
              <Input
                key={`section-section-input-${setting.id}-${index}`}
                value={this.props.sectionContent.settings[setting.id]}
                onChange={this.props.handleChange}
                isVisible={setting.only_if === undefined || this.props.sectionContent.settings[setting.only_if] === true}
                {...this.props}
                setting={setting}
              />
            )}
          </div>

          {!isBlank(this.props.sectionDefinition.blocks) && (
            <div className={classnames('editor-section-blocks', this.props.sectionDefinition.settings.length === 0 && 'editor-section-blocks-standalone')}>
              <h3 className="editor-section-blocks--title">
                {translate(this.props.sectionDefinition.blocks_label, i18n.t('views.sections.edit.default_block_label'))}
              </h3>

              <div className="editor-section-blocks--list">
                <BlockList
                  moveBlock={this.moveBlock}
                  {...this.props}
                />
              </div>

              <NewBlockPicker
                addBlock={this.addBlock}
                {...this.props}
              />

            </div>
          )}

        </div>
      </View>
    )
  }
}

export default asView(Edit);
