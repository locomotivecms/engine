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
        use: ['style-loader', MiniCssExtractPlugin.loader, 'css-loader', 'postcss-loader', 'sass-loader']
      }
    ]
  },
  plugins: [
    new MiniCssExtractPlugin({ filename: 'stylesheets/locomotive/editor.css' })
  ]
};
