import React from 'react';
import { bindAll } from 'lodash';

const withApiFetching = (source, options) => (Component) => {

  const _options = Object.assign({ pagination: false }, options);

  return class WithFetching extends React.Component {

    constructor(props) {
      super(props);

      this.state = {
        isLoading:    true,
        error:        null,
        pagination:   {
          page:         _options.page,
          perPage:      _options.perPage,
          totalEntries: null,
          totalPages:   null
        }
      };

      bindAll(this, 'handlePageChange');
    }

    handlePageChange(page) {
      this.setState({ pagination: Object.assign(this.state.pagination, { page }) }, () => {
        this.fetch();
      });
    }

    componentDidMount() {
      this.fetch();
    }

    fetch() {
      // this.setState({ isLoading: true }, () => {
        this.props.api[source](this.fetchOptions())
        .then(data => this.setState({ ...data, isLoading: false }))
        .catch(error => this.setState({ error, isLoading: false }));
      // });
    }

    fetchOptions() {
      return _options.pagination ? { pagination: this.state.pagination } : {};
    }

    render() {
      return <Component
        handlePageChange={this.handlePageChange}
        { ...this.props }
        { ...this.state }
      />
    }
  }

}

export default withApiFetching;
