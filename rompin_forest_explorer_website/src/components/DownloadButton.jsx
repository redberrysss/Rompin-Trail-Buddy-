import { Download } from 'lucide-react'

export default function DownloadButton({
  href = '#',
  children = 'Download',
  variant = 'primary',
  className = '',
}) {
  const baseStyles =
    'inline-flex items-center justify-center gap-2 font-semibold rounded-full transition-all duration-200 px-6 py-3 text-sm'

  const variants = {
    primary:
      'bg-forest-green text-white hover:bg-nature-green shadow-sm hover:shadow-md',
    secondary:
      'border-2 border-forest-green text-forest-green hover:bg-forest-green hover:text-white',
  }

  return (
    <a
      href={href}
      download
      className={`${baseStyles} ${variants[variant] || variants.primary} ${className}`}
      aria-label={`Download ${children}`}
    >
      <Download className="w-4 h-4" />
      {children}
    </a>
  )
}
