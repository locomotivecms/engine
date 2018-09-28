import React, { Component } from 'react';
import { compose } from 'redux';
import { bindAll } from 'lodash';
import i18n from '../../../i18n';

// HOC
import withRoutes from '../../../hoc/with_routes';
import withRedux from '../../../hoc/with_redux';
import withGlobalVars from '../../../hoc/with_global_vars';

// Components
import View from '../../../components/default_view';
import Category from './category';

// Services
import { buildSection, buildCategories } from '../../../services/sections_service';

class Gallery extends Component {

  constructor(props) {
    super(props);
    this.state      = { category: null, preset: null, section: null };
    this.categories = buildCategories(props.sectionDefinitions);
    bindAll(this, 'selectPreset', 'previewPreset', 'cancel');
  }

  selectedPreset() {
    if (this.state.category === null) return null;
    return [this.state.preset.type, this.state.category.id, this.state.preset.id].join('-');
  }

  cancel() {
    this.props.cancelPreviewSection();
    this.props.redirectTo(this.props.rootPath());
  }

  selectPreset() {
    const { section } = this.state;

    this.props.addSection(section);

    // Go directly to the section edit page
    this.props.redirectTo(this.props.editSectionPath(section), 'left');
  }

  previewPreset(category, preset) {
    const section = buildSection(
      this.props.sectionDefinitions,
      preset.type,
      preset.preset
    );

    this.setState({ category, preset, section }, () => {
      this.props.previewSection(section);
    });
  }

  render() {
    return (
      <View title={i18n.t('views.sections.gallery.title')} onLeave={this.cancel}>
        <div className="editor-section-gallery">

          <div className="editor-section-gallery--list">
            {this.categories.map(category =>
              <Category
                key={category.name}
                category={category}
                selectPreset={this.selectPreset}
                previewPreset={this.previewPreset}
                selectedPreset={this.selectedPreset()}
                {...this.props}
              />
            )}
          </div>
        </div>
      </View>
    )
  }

}

export default compose(
  withRedux(),
  withGlobalVars,
  withRoutes
)(Gallery);
