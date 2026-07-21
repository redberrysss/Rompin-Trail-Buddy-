import { useState, useEffect } from 'react'
import { Link, useLocation } from 'react-router-dom'
import { Menu, X, Leaf } from 'lucide-react'
import { motion, AnimatePresence } from 'framer-motion'
import { navLinks } from '../data/navigation'

export default function Navbar() {
  const [isOpen, setIsOpen] = useState(false)
  const [scrolled, setScrolled] = useState(false)
  const location = useLocation()

  useEffect(() => {
    const handleScroll = () => setScrolled(window.scrollY > 10)
    window.addEventListener('scroll', handleScroll)
    return () => window.removeEventListener('scroll', handleScroll)
  }, [])

  useEffect(() => {
    setIsOpen(false)
  }, [location])

  useEffect(() => {
    document.body.style.overflow = isOpen ? 'hidden' : ''
    return () => { document.body.style.overflow = '' }
  }, [isOpen])

  return (
    <nav
      className={`sticky top-0 z-50 transition-all duration-300 ${
        scrolled
          ? 'bg-cream/95 backdrop-blur-sm shadow-md'
          : 'bg-cream shadow-sm'
      }`}
      role="navigation"
      aria-label="Main navigation"
    >
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16 lg:h-20">
          <Link
            to="/"
            className="flex items-center gap-2 text-forest-green font-bold text-xl lg:text-2xl"
            aria-label="Rompin Forest Explorer - Home"
          >
            <Leaf className="w-7 h-7 lg:w-8 lg:h-8" />
            <span>Rompin Forest Explorer</span>
          </Link>

          <div className="hidden lg:flex items-center gap-1">
            {navLinks.map((link) => (
              <Link
                key={link.path}
                to={link.path}
                className={`relative px-4 py-2 text-sm font-medium transition-colors duration-200 rounded-md ${
                  location.pathname === link.path
                    ? 'text-forest-green bg-nature-light/20'
                    : 'text-earth-brown hover:text-forest-green hover:bg-nature-light/10'
                }`}
                aria-current={location.pathname === link.path ? 'page' : undefined}
              >
                {link.name}
                {location.pathname === link.path && (
                  <motion.span
                    layoutId="nav-underline"
                    className="absolute bottom-0 left-2 right-2 h-0.5 bg-forest-green rounded-full"
                    transition={{ type: 'spring', stiffness: 380, damping: 30 }}
                  />
                )}
              </Link>
            ))}
          </div>

          <div className="hidden lg:flex items-center">
            <Link
              to="/download"
              className="inline-flex items-center px-6 py-2.5 bg-forest-green text-white font-semibold text-sm rounded-full hover:bg-nature-green transition-colors duration-200 shadow-sm hover:shadow-md"
            >
              Download App
            </Link>
          </div>

          <button
            className="lg:hidden p-2 rounded-md text-earth-brown hover:text-forest-green hover:bg-nature-light/10 transition-colors"
            onClick={() => setIsOpen(!isOpen)}
            aria-label={isOpen ? 'Close menu' : 'Open menu'}
            aria-expanded={isOpen}
            aria-controls="mobile-menu"
          >
            {isOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
          </button>
        </div>
      </div>

      <AnimatePresence>
        {isOpen && (
          <motion.div
            id="mobile-menu"
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: 'auto', opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            transition={{ duration: 0.3, ease: 'easeInOut' }}
            className="lg:hidden overflow-hidden bg-cream border-t border-nature-light/30"
            role="menu"
          >
            <div className="px-4 py-4 space-y-1">
              {navLinks.map((link) => (
                <Link
                  key={link.path}
                  to={link.path}
                  className={`block px-4 py-3 rounded-lg text-base font-medium transition-colors duration-200 ${
                    location.pathname === link.path
                      ? 'text-forest-green bg-nature-light/20'
                      : 'text-earth-brown hover:text-forest-green hover:bg-nature-light/10'
                  }`}
                  role="menuitem"
                  aria-current={location.pathname === link.path ? 'page' : undefined}
                >
                  {link.name}
                </Link>
              ))}
              <div className="pt-3">
                <Link
                  to="/download"
                  className="block text-center px-6 py-3 bg-forest-green text-white font-semibold rounded-full hover:bg-nature-green transition-colors duration-200"
                  role="menuitem"
                >
                  Download App
                </Link>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </nav>
  )
}
