import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { ChevronDown } from 'lucide-react'

export default function FAQAccordion({ items = [] }) {
  const [openId, setOpenId] = useState(null)

  const toggle = (id) => {
    setOpenId((prev) => (prev === id ? null : id))
  }

  return (
    <div className="space-y-3" role="list">
      {items.map((item) => (
        <div
          key={item.id}
          className="bg-white rounded-xl border border-nature-light/20 shadow-sm overflow-hidden"
          role="listitem"
        >
          <button
            onClick={() => toggle(item.id)}
            className="w-full flex items-center justify-between p-5 text-left focus:outline-none focus:ring-2 focus:ring-nature-green focus:ring-inset rounded-xl"
            aria-expanded={openId === item.id}
          >
            <span className="font-semibold text-forest-green pr-4">{item.question}</span>
            <motion.span
              animate={{ rotate: openId === item.id ? 180 : 0 }}
              transition={{ duration: 0.3 }}
              className="flex-shrink-0"
            >
              <ChevronDown className="w-5 h-5 text-nature-green" />
            </motion.span>
          </button>

          <AnimatePresence>
            {openId === item.id && (
              <motion.div
                initial={{ height: 0, opacity: 0 }}
                animate={{ height: 'auto', opacity: 1 }}
                exit={{ height: 0, opacity: 0 }}
                transition={{ duration: 0.3, ease: 'easeInOut' }}
                className="overflow-hidden"
              >
                <div className="px-5 pb-5 text-earth-brown/70 leading-relaxed border-t border-nature-light/20 pt-4">
                  {item.answer}
                </div>
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      ))}
    </div>
  )
}
