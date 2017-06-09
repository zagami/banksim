const HtmlWebpackPlugin = require('html-webpack-plugin'); //installed via npm
const webpack = require('webpack'); //to access built-in plugins
const path = require('path');

module.exports = {
	entry: "./src/entry.js",
	output: {
	  filename: 'bundle.js',
	  path: __dirname
	  // path: path.resolve(__dirname, 'dist')
    // the target directory for all output files
    // must be an absolute path (use the Node.js path module)
	},
	module: {
		rules: [
			{
				test: /\.md$/, 
				use: [
					{
						loader: 'html-loader',
					},
					{
						loader: 'markdown-loader',
					}					
				]
			},
			{
				test: /\.coffee$/, 
				use: [
					{
						loader: 'coffee-loader',
					}
				],
				include: [
					path.resolve(__dirname, "src")
				]
			},
			{
				test: /\.(js|jsx)$/, 
				use: [
					{
						loader: 'babel-loader',
						options: {
							presets: ["es2015", "react"]
						},
					}
				],
				include: [
					path.resolve(__dirname, "src")
				]
			},
			{
				test: /\.css$/, 
				use: [
					"style-loader",
					"css-loader"
				]
			}
		]
    },
	plugins: [
		//new webpack.optimize.UglifyJsPlugin(),
		new HtmlWebpackPlugin({template: './src/index.html'})
	]
}
