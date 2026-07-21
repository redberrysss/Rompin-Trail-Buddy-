import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { ChevronDown, Clock, Users } from 'lucide-react'

export default function ActivityCard({ activity }) {
  const [isExpanded, setIsExpanded] = useState(false)

  const {
    title,
    malayName,
    objective,
    duration,
    groupSize,
    materials = [],
    steps = [],
    modifications = [],
    icon,
  } = activity

  return (
    <div className="bg-white rounded-2xl shadow-md hover:shadow-lg transition-shadow duration-300 border border-nature-light/20 overflow-hidden">
      <button
        onClick={() => setIsExpanded(!isExpanded)}
        className="w-full text-left p-6 lg:p-8 focus:outline-none focus:ring-2 focus:ring-nature-green focus:ring-inset rounded-2xl"
        aria-expanded={isExpanded}
      >
        <div className="flex items-start justify-between gap-4">
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-3 mb-2">
              {icon && <span className="text-2xl">{icon}</span>}
              <h3 className="text-xl font-bold text-forest-green">{title}</h3>
            </div>
            {malayName && (
              <p className="text-sm text-nature-green italic mb-3">{malayName}</p>
            )}
            <p className="text-earth-brown/70 text-sm leading-relaxed mb-4">{objective}</p>
            <div className="flex flex-wrap gap-4 text-sm text-earth-brown/60">
              {duration && (
                <span className="flex items-center gap-1.5">
                  <Clock className="w-4 h-4" />
                  {duration}
                </span>
              )}
              {groupSize && (
                <span className="flex items-center gap-1.5">
                  <Users className="w-4 h-4" />
                  {groupSize}
                </span>
              )}
            </div>
          </div>
          <motion.div
            animate={{ rotate: isExpanded ? 180 : 0 }}
            transition={{ duration: 0.3 }}
            className="flex-shrink-0 mt-1"
          >
            <ChevronDown className="w-5 h-5 text-forest-green" />
          </motion.div>
        </div>
      </button>

      <AnimatePresence>
        {isExpanded && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: 'auto', opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            transition={{ duration: 0.35, ease: 'easeInOut' }}
            className="overflow-hidden"
          >
            <div className="px-6 lg:px-8 pb-6 lg:pb-8 border-t border-nature-light/20 pt-6 space-y-6">
              {materials.length > 0 && (
                <div>
                  <h4 className="font-semibold text-forest-green mb-2">Materials Needed</h4>
                  <ul className="list-disc list-inside text-sm text-earth-brown/70 space-y-1">
                    {materials.map((item, i) => (
                      <li key={i}>{item}</li>
                    ))}
                  </ul>
                </div>
              )}

              {steps.length > 0 && (
                <div>
                  <h4 className="font-semibold text-forest-green mb-2">Steps</h4>
                  <ol className="list-decimal list-inside text-sm text-earth-brown/70 space-y-1.5">
                    {steps.map((step, i) => (
                      <li key={i}>{step}</li>
                    ))}
                  </ol>
                </div>
              )}

              {modifications.length > 0 && (
                <div>
                  <h4 className="font-semibold text-forest-green mb-2">Modifications</h4>
                  <ul className="list-disc list-inside text-sm text-earth-brown/70 space-y-1">
                    {modifications.map((item, i) => (
                      <li key={i}>{item}</li>
                    ))}
                  </ul>
                </div>
              )}
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
}
