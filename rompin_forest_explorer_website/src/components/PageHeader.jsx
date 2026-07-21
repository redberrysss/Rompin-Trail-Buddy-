import { Link } from 'react-router-dom'
import { ChevronRight } from 'lucide-react'

export default function PageHeader({ title, subtitle, breadcrumb = [] }) {
  return (
    <section className="relative bg-gradient-to-br from-forest-green to-nature-green py-16 lg:py-24 overflow-hidden">
      <div className="absolute inset-0 opacity-10">
        <div className="absolute top-10 left-10 w-64 h-64 bg-white/20 rounded-full blur-3xl" />
        <div className="absolute bottom-0 right-10 w-80 h-80 bg-white/10 rounded-full blur-3xl" />
      </div>

      <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {breadcrumb.length > 0 && (
          <nav aria-label="Breadcrumb" className="mb-6">
            <ol className="flex items-center flex-wrap gap-1 text-sm text-white/70">
              {breadcrumb.map((crumb, index) => (
                <li key={index} className="flex items-center gap-1">
                  {index > 0 && <ChevronRight className="w-3.5 h-3.5" />}
                  {crumb.path ? (
                    <Link
                      to={crumb.path}
                      className="hover:text-white transition-colors duration-200"
                    >
                      {crumb.label}
                    </Link>
                  ) : (
                    <span className="text-white font-medium">{crumb.label}</span>
                  )}
                </li>
              ))}
            </ol>
          </nav>
        )}

        <h1 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-white mb-4">{title}</h1>
        {subtitle && (
          <p className="text-lg sm:text-xl text-white/80 max-w-2xl">{subtitle}</p>
        )}
      </div>
    </section>
  )
}
