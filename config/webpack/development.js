// The source code including full typescript support is available at: 
// https://github.com/shakacode/react_on_rails_demo_ssr_hmr/blob/master/config/webpack/development.js

const { devServer, inliningCss } = require('shakapacker');

const webpackConfig = require('./webpackConfig');

const { join } = require('path');

const developmentEnvOnly = (clientWebpackConfig, _serverWebpackConfig) => {
  clientWebpackConfig.resolve.alias = {
	  images: join(process.cwd(), 'app', 'assets', 'images'),
    geographies: join(process.cwd(), 'app', 'assets', 'geographies')
  }

  clientWebpackConfig.externals = { config: JSON.stringify(require('../config.dev.json')) };

  // plugins
  if (inliningCss) {
    // Note, when this is run, we're building the server and client bundles in separate processes.
    // Thus, this plugin is not applied to the server bundle.

    // eslint-disable-next-line global-require
    const ReactRefreshWebpackPlugin = require('@pmmmwh/react-refresh-webpack-plugin');
    clientWebpackConfig.plugins.push(
      new ReactRefreshWebpackPlugin({
        overlay: {
          sockPort: devServer.port,
        },
      }),
    );
  }
};

module.exports = webpackConfig(developmentEnvOnly);
