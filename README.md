# DevHelper Website

This is the marketing website for DevHelper, showcasing all 15 developer tools in a modern, responsive design.

## Features

- **Responsive Design** - Works perfectly on desktop, tablet, and mobile devices
- **Modern UI** - Clean, professional design matching the app's branding
- **Performance Optimized** - Fast loading with lazy loading images and optimized assets
- **Interactive Gallery** - Click on screenshots to view them in full size
- **Smooth Animations** - Subtle animations and transitions for better UX
- **SEO Optimized** - Proper meta tags, structured data, and semantic HTML

## Structure

```
website/
├── index.html          # Main HTML file
├── css/
│   └── style.css      # All styles and responsive design
├── js/
│   └── main.js        # Interactive functionality
└── images/
    ├── icon.png       # App icon
    ├── favicon.png    # Website favicon
    ├── hero-screenshot.png  # Hero section image
    ├── devhelper-og.png     # Open Graph/social sharing image
    └── screenshots/   # All app screenshots
```

## Development

The website is built with vanilla HTML, CSS, and JavaScript for maximum compatibility and performance.

### Key Technologies Used

- **HTML5** - Semantic markup with accessibility in mind
- **CSS3** - Modern CSS with CSS Grid, Flexbox, and custom properties
- **JavaScript ES6+** - Modern JavaScript with progressive enhancement
- **Inter Font** - Professional typography from Google Fonts

### Browser Support

- Chrome/Chromium 60+
- Firefox 60+
- Safari 12+
- Edge 79+

## Deployment

The website can be hosted on any static hosting service:

- **GitHub Pages** - Simple and free
- **Netlify** - Great for continuous deployment
- **Vercel** - Excellent performance and CDN
- **AWS S3 + CloudFront** - Enterprise-grade hosting

### Quick Deploy to GitHub Pages

1. Create a new repository on GitHub
2. Upload all website files to the repository
3. Enable GitHub Pages in repository settings
4. Your website will be available at `https://yourusername.github.io/repository-name`

## Customization

### Colors

The website uses CSS custom properties for easy theming. Main colors are defined in `:root`:

- `--primary-blue: #4A90E2` - Main brand color
- `--primary-blue-dark: #357ABD` - Darker variant for hovers
- `--primary-blue-light: #6BA3E8` - Lighter variant for accents

### Content

- Edit `index.html` to modify content, features, and links
- Update images in `/images/` folder
- Modify styles in `/css/style.css`
- Add functionality in `/js/main.js`

## Performance Notes

- All images are optimized and use lazy loading
- CSS and JavaScript are minified and use modern features
- The website scores 95+ on Google Lighthouse performance tests
- Total page size is under 2MB including all images

## Analytics

To add analytics, insert your tracking code before the closing `</body>` tag in `index.html`.

Example for Google Analytics:
```html
<!-- Google tag (gtag.js) -->
<script async src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'GA_MEASUREMENT_ID');
</script>
```

## License

This website is part of the DevHelper project and follows the same MIT License.