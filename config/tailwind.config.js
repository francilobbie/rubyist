const defaultTheme = require('tailwindcss/defaultTheme');

module.exports = {
  content: [
    './app/views/**/*.html.erb',        // Views (HTML templates)
    './app/helpers/**/*.rb',           // Helpers
    './app/javascript/**/*.js',        // JavaScript files
    './app/assets/stylesheets/**/*.css', // CSS files
    './app/assets/javascripts/**/*.js', // Additional JavaScript files
    './config/**/*.rb',                // Config files
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...require('tailwindcss/defaultTheme').fontFamily.sans],
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
  ],
};
