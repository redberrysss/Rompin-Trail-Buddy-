import { motion } from 'framer-motion'
import { Quote, Star } from 'lucide-react'

export default function TestimonialCard({ name, role, text, rating = 5 }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true }}
      transition={{ duration: 0.5 }}
      className="bg-white rounded-2xl p-6 lg:p-8 shadow-md hover:shadow-lg transition-shadow duration-300 border border-nature-light/20"
    >
      <Quote className="w-8 h-8 text-nature-light/60 mb-4" />

      <p className="text-earth-brown/80 leading-relaxed mb-6 italic">"{text}"</p>

      <div className="flex gap-1 mb-4">
        {Array.from({ length: 5 }).map((_, i) => (
          <Star
            key={i}
            className={`w-4 h-4 ${
              i < rating ? 'text-earth-brown fill-earth-brown' : 'text-gray-200'
            }`}
          />
        ))}
      </div>

      <div>
        <p className="font-semibold text-forest-green">{name}</p>
        {role && <p className="text-sm text-earth-brown/60">{role}</p>}
      </div>
    </motion.div>
  )
}
