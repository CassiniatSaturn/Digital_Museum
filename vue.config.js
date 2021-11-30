module.exports = {
  pluginOptions: {
    quasar: {
      importStrategy: 'kebab',
      rtlSupport: true
    }
  },
  transpileDependencies: [
    'quasar'
  ],
  https:true,
  devServer: {
    proxy: {
        "/ipfsApi": {
            target: 'http://127.0.0.1:5001',
            changeOrigin: true,
           
        },
    },
},
}
