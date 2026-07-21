# Rompin Forest Explorer Website

A complete, modern, responsive React.js website for the **Rompin Forest Explorer** mobile application — an autism-friendly nature learning app for children.

## Features

- **10 fully-built pages**: Home, About, Features, Activities, Download, User Guide, Support, Privacy Policy, Terms of Use, Contact
- **16 reusable React components**: Navbar, Footer, HeroSection, SectionTitle, FeatureCard, ActivityCard, DownloadButton, AppScreenshot, TestimonialCard, FAQAccordion, ContactForm, SupportForm, PageHeader, ScrollToTop, BackToTopButton, TestimonialSlider
- **Responsive design**: Mobile, tablet, and desktop layouts
- **Autism-friendly design**: Calm colours, large buttons, clear typography, minimal animations
- **Nature-exploration theme**: Forest green, earth brown, sky blue, cream backgrounds
- **Smooth animations**: Framer Motion for subtle, non-overwhelming transitions
- **Accessible**: Semantic HTML, ARIA attributes, keyboard navigation, focus states
- **SEO-optimized**: Page titles, meta descriptions, Open Graph tags
- **APK download functionality**: Working download button with placeholder APK
- **Form validation**: Contact and support forms with front-end validation
- **FAQ accordions**: Interactive expand/collapse FAQ sections
- **Deployment ready**: Configuration for Firebase Hosting, Vercel, and Netlify

## Technology Stack

| Technology | Purpose |
|---|---|
| React 19 | UI framework |
| Vite 8 | Build tool and dev server |
| Tailwind CSS 4 | Utility-first styling |
| React Router 7 | Client-side routing |
| Lucide React | Icon library |
| Framer Motion | Animation library |

## Installation

### Prerequisites

- Node.js 18+ (recommended: 20+)
- npm 9+

### Setup

```bash
# Clone the repository
git clone <repository-url>

# Navigate to the project directory
cd rompin_forest_explorer_website

# Install dependencies
npm install

# Start the development server
npm run dev
```

The development server will start at `http://localhost:5173`.

## Development Commands

```bash
npm run dev      # Start development server
npm run build    # Build for production
npm run preview  # Preview production build locally
npm run lint     # Run linter
```

## Production Build

```bash
# Create production build
npm run build

# Preview the production build
npm run preview
```

The production build will be output to the `dist/` directory.

## Project Structure

```
rompin_forest_explorer_website/
├── public/
│   ├── downloads/
│   │   ├── rompin-forest-explorer.apk        # Place actual APK here
│   │   └── rompin-forest-explorer.apk.txt    # Placeholder instructions
│   ├── favicon.svg                            # App favicon
│   ├── robots.txt                             # Search engine directives
│   └── _redirects                             # Netlify SPA redirects
├── src/
│   ├── assets/                                # Static assets (images, etc.)
│   ├── components/                            # Reusable React components
│   │   ├── Navbar.jsx
│   │   ├── Footer.jsx
│   │   ├── HeroSection.jsx
│   │   ├── SectionTitle.jsx
│   │   ├── FeatureCard.jsx
│   │   ├── ActivityCard.jsx
│   │   ├── DownloadButton.jsx
│   │   ├── AppScreenshot.jsx
│   │   ├── TestimonialCard.jsx
│   │   ├── FAQAccordion.jsx
│   │   ├── ContactForm.jsx
│   │   ├── SupportForm.jsx
│   │   ├── PageHeader.jsx
│   │   ├── ScrollToTop.jsx
│   │   ├── BackToTopButton.jsx
│   │   └── TestimonialSlider.jsx
│   ├── data/                                  # Static data modules
│   │   ├── navigation.js
│   │   ├── features.js
│   │   ├── activities.js
│   │   ├── testimonials.js
│   │   ├── faqs.js
│   │   ├── userRoles.js
│   │   └── homePageData.js
│   ├── layouts/                               # Layout components (future use)
│   ├── pages/                                 # Page components
│   │   ├── Home.jsx
│   │   ├── About.jsx
│   │   ├── Features.jsx
│   │   ├── Activities.jsx
│   │   ├── Download.jsx
│   │   ├── UserGuide.jsx
│   │   ├── Support.jsx
│   │   ├── Privacy.jsx
│   │   ├── Terms.jsx
│   │   └── Contact.jsx
│   ├── routes/                                # Route definitions (future use)
│   ├── App.jsx                                # Main app with routing
│   ├── main.jsx                               # App entry point
│   └── index.css                              # Global styles and Tailwind theme
├── index.html                                 # HTML template
├── package.json                               # Project dependencies
├── vite.config.js                             # Vite configuration
├── vercel.json                                # Vercel deployment config
└── README.md                                  # This file
```

## Deployment

### Firebase Hosting

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase Hosting
firebase init hosting

# Deploy
firebase deploy
```

Configure `firebase.json` to rewrite all routes to `index.html`:

```json
{
  "hosting": {
    "public": "dist",
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

### Vercel

The project includes a `vercel.json` configuration. Simply connect your repository to Vercel:

1. Go to [vercel.com](https://vercel.com)
2. Import your repository
3. Vercel will auto-detect the Vite framework
4. Deploy

### Netlify

The project includes a `public/_redirects` file for Netlify SPA support:

1. Go to [netlify.com](https://netlify.com)
2. Connect your repository
3. Set build command: `npm run build`
4. Set publish directory: `dist`
5. Deploy

## APK Placement

To enable the APK download button:

1. Place your APK file at: `public/downloads/rompin-forest-explorer.apk`
2. The download button on the Download page will link to this file
3. Remove or keep `public/downloads/rompin-forest-explorer.apk.txt` as reference

**Note:** The placeholder `rompin-forest-explorer.apk.txt` file contains instructions for where to place the actual APK.

## Replacing Placeholder Images

The website uses CSS-based placeholders for:

- **App screenshots**: Replace the phone mockup components with actual screenshots
- **Partner logos**: Update the `TrustedBy` section in `Home.jsx` with real logos
- **QR code**: Replace the QR code placeholder on the Download page
- **Map**: Replace the map placeholder on the Contact page

### Adding Real Screenshots

1. Place screenshot images in `src/assets/` or `public/`
2. Update the `AppScreenshot` component or replace with `<img>` tags
3. Add appropriate `alt` text for accessibility

## Updating App Version Information

Update version information in `src/data/homePageData.js`:

```javascript
export const appInfo = {
  platform: 'Android',
  version: '1.0.0',        // Update this
  fileType: 'APK',
  price: 'Free',
  internet: 'Required for account and cloud synchronization',
}
```

Also update version references in:
- `src/pages/Download.jsx`
- `src/pages/Home.jsx` (in the download CTA section)

## Updating Contact Details

Contact information is defined in multiple files:

- **Footer**: `src/components/Footer.jsx` (email, social links)
- **Contact page**: `src/pages/Contact.jsx` (address, phone, email)
- **Support page**: `src/pages/Support.jsx` (support email, phone)
- **Privacy Policy**: `src/pages/Privacy.jsx` (privacy email)
- **Terms of Use**: `src/pages/Terms.jsx` (terms email)

Search for placeholder values like `@rompinforestexplorer.com` or `+60-12-345-6789` and replace with actual details.

## Firebase Configuration (Optional)

If you want to enable Firebase features (contact form submissions, support requests, analytics):

1. Create a `.env` file in the project root:

```env
VITE_FIREBASE_API_KEY=your_api_key
VITE_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
VITE_FIREBASE_PROJECT_ID=your_project_id
VITE_FIREBASE_STORAGE_BUCKET=your_project.appspot.com
VITE_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
VITE_FIREBASE_APP_ID=your_app_id
```

2. **Never commit this file to version control.**

3. The website will continue to work without Firebase — forms use local state and show success messages.

## Pages Overview

| Page | Route | Description |
|---|---|---|
| Home | `/` | Hero, features, how it works, testimonials, FAQ, download CTA |
| About | `/about` | Mission, purpose, target users, educational value |
| Features | `/features` | 16 features with category filtering |
| Activities | `/activities` | 7 nature learning activities with expandable details |
| Download | `/download` | APK download, installation guide, version notes |
| User Guide | `/user-guide` | Step-by-step usage guide for all roles |
| Support | `/support` | Troubleshooting, support form, contact info |
| Privacy Policy | `/privacy` | Complete privacy policy |
| Terms of Use | `/terms` | Terms and conditions |
| Contact | `/contact` | Contact form, info cards, map placeholder |

## Accessibility

- Semantic HTML5 elements (`<nav>`, `<main>`, `<section>`, `<footer>`)
- ARIA labels and roles on interactive elements
- Keyboard navigation support
- Visible focus states
- High colour contrast ratios
- Descriptive `alt` text for images
- Form labels for all inputs
- Skip-to-content considerations

## Browser Support

- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+
- Mobile Safari (iOS 14+)
- Chrome for Android 90+

## License

This project is for the Rompin Forest Explorer programme. All rights reserved.

## Contact

For questions or support:

- **Email**: info@rompinforestexplorer.com
- **Phone**: +60-12-345-6789
- **Website**: rompinforestexplorer.com

---

**Note:** This website uses placeholder content for organization details, contact information, app version, and screenshots. Update these values before production deployment. The privacy policy and terms of use should be reviewed by a qualified legal professional.
