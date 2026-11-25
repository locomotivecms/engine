const path = require('path');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

module.exports = {
  entry: './app/javascript/src/locomotive/editor.es6',
  output: {
    path: path.resolve(__dirname, '..', '..', 'app', 'assets'),
    filename: 'javascripts/locomotive/editor.js'
  },
  module: {
    rules: [
      {
        test: /\.(js|jsx|es6)$/,
        exclude: /(node_modules|bower_components)/,
        loader: 'babel-loader'
      },
      {
        test: /\.scss$/,
        use: [ // extracted to editor.css, linked by the page
          MiniCssExtractPlugin.loader,
          { loader: 'css-loader', options: { sourceMap: false } }, // no editor.css.map next to the asset
          'postcss-loader',
          { loader: 'sass-loader', options: { sassOptions: { quietDeps: true } } } // deprecations in node_modules are not ours to fix
        ]
      }
    ]
  },
  plugins: [
    new MiniCssExtractPlugin({ filename: 'stylesheets/locomotive/editor.css' })
  ]
};
