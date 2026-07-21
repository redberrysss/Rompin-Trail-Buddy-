import { Link } from 'react-router-dom'
import { Leaf, Globe, ExternalLink, Mail } from 'lucide-react'

const quickLinks = [
  { name: 'Home', path: '/' },
  { name: 'About', path: '/about' },
  { name: 'Features', path: '/features' },
  { name: 'Activities', path: '/activities' },
]

const resourceLinks = [
  { name: 'Download', path: '/download' },
  { name: 'User Guide', path: '/user-guide' },
  { name: 'Support', path: '/support' },
  { name: 'Contact', path: '/contact' },
]

const legalLinks = [
  { name: 'Privacy Policy', path: '/privacy' },
  { name: 'Terms of Use', path: '/terms' },
]

export default function Footer() {
  const currentYear = new Date().getFullYear()

  return (
    <footer className="bg-[#1a3a0a] text-cream" role="contentinfo">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12 lg:py-16">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-10 lg:gap-8">
          <div className="space-y-4">
            <Link to="/" className="flex items-center gap-2 text-white font-bold text-xl">
              <Leaf className="w-7 h-7" />
              <span>Rompin Forest Explorer</span>
            </Link>
            <p className="text-cream/70 text-sm leading-relaxed">
              Empowering educators and students to discover the wonders of Rompin's rainforest through interactive outdoor education activities.
            </p>
          </div>

          <div>
            <h3 className="text-white font-semibold text-base mb-4">Quick Links</h3>
            <ul className="space-y-2.5">
              {quickLinks.map((link) => (
                <li key={link.path}>
                  <Link
                    to={link.path}
                    className="text-cream/70 hover:text-white text-sm transition-colors duration-200"
                  >
                    {link.name}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          <div>
            <h3 className="text-white font-semibold text-base mb-4">Resources</h3>
            <ul className="space-y-2.5">
              {resourceLinks.map((link) => (
                <li key={link.path}>
                  <Link
                    to={link.path}
                    className="text-cream/70 hover:text-white text-sm transition-colors duration-200"
                  >
                    {link.name}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          <div>
            <h3 className="text-white font-semibold text-base mb-4">Legal</h3>
            <ul className="space-y-2.5">
              {legalLinks.map((link) => (
                <li key={link.path}>
                  <Link
                    to={link.path}
                    className="text-cream/70 hover:text-white text-sm transition-colors duration-200"
                  >
                    {link.name}
                  </Link>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </div>

      <div className="border-t border-cream/10">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6 flex flex-col sm:flex-row items-center justify-between gap-4">
          <p className="text-cream/50 text-sm">
            &copy; {currentYear} Rompin Forest Explorer. All rights reserved.
          </p>
          <div className="flex items-center gap-4">
            <a
              href="https://github.com"
              target="_blank"
              rel="noopener noreferrer"
              className="text-cream/50 hover:text-white transition-colors duration-200"
              aria-label="GitHub"
            >
              <Globe className="w-5 h-5" />
            </a>
            <a
              href="https://twitter.com"
              target="_blank"
              rel="noopener noreferrer"
              className="text-cream/50 hover:text-white transition-colors duration-200"
              aria-label="Twitter"
            >
              <ExternalLink className="w-5 h-5" />
            </a>
            <a
              href="mailto:contact@rompinforestexplorer.com"
              className="text-cream/50 hover:text-white transition-colors duration-200"
              aria-label="Email us"
            >
              <Mail className="w-5 h-5" />
            </a>
          </div>
        </div>
      </div>
    </footer>
  )
}
