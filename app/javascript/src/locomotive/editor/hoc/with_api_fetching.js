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
        source:       props.source,
        searchParams: null,
        pagination:   {
          page:         _options.page,
          perPage:      _options.perPage,
          totalEntries: null,
          totalPages:   null
        }
      };

      bindAll(this, 'handlePageChange', 'handleSearchParamsChange');
    }

    handlePageChange(page) {
      this.setState({ pagination: Object.assign(this.state.pagination, { page }) }, () => {
        this.fetch();
      });
    }

    handleSearchParamsChange(searchParams) {
      this.setState({ searchParams }, () => {
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
      let options = _options.pagination ? { pagination: this.state.pagination } : {};

      if (this.state.searchParams)
        options = { ...options, ...this.state.searchParams };

      return options;
    }

    render() {
      return <Component
        handlePageChange={this.handlePageChange}
        handleSearchParamsChange={this.handleSearchParamsChange}
        { ...this.props }
        { ...this.state }
      />
    }
  }

}

export default withApiFetching;
