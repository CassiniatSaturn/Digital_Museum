const plugins = [
  require('autoprefixer'),
  require('tailwindcss'),
]

if (process.env.QUASAR_RTL) {
  plugins.push(
    require('postcss-rtl')({})
  )
}

module.exports = {
  plugins
}
