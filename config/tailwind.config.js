const defaultTheme = require('tailwindcss/defaultTheme');

module.exports = {
  content: [
    './app/views/**/*.html.erb',        // Views
    './app/helpers/**/*.rb',           // Helpers
    './app/javascript/**/*.js',        // JavaScript
    './app/assets/stylesheets/**/*.css', // CSS files
    './app/assets/javascripts/**/*.js', // Additional JavaScript
    './config/**/*.rb',                // Configurations
    './app/components/**/*.erb',       // Optional custom components
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
  ],
};
