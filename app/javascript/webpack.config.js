const path = require('path');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

module.exports = {
  entry: './src/locomotive/content_editing.es6',
  output: {
    path: path.resolve(__dirname, '..', '..', 'app', 'assets'),
    filename: 'javascripts/locomotive/content_editing.js'
  },
  module: {
    rules: [
      {
        test: /\.(js|jsx|es6)$/,
        exclude: /(node_modules|bower_components)/,
        loader: 'babel-loader',
        query: { presets: ['react', 'es2015'] }
      },
      {
        test: /\.scss$/,
        use: ['style-loader', MiniCssExtractPlugin.loader, 'css-loader', 'postcss-loader', 'sass-loader']
      }
    ]
  },
  plugins: [
    new MiniCssExtractPlugin({ filename: 'stylesheets/locomotive/content_editing.css' })
  ]
};
