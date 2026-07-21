import { useState } from 'react'
import { motion } from 'framer-motion'
import { Send, CheckCircle } from 'lucide-react'

export default function ContactForm() {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    subject: '',
    message: '',
  })
  const [submitted, setSubmitted] = useState(false)
  const [errors, setErrors] = useState({})

  const validate = () => {
    const newErrors = {}
    if (!formData.name.trim()) newErrors.name = 'Name is required'
    if (!formData.email.trim()) {
      newErrors.email = 'Email is required'
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
      newErrors.email = 'Please enter a valid email'
    }
    if (!formData.subject.trim()) newErrors.subject = 'Subject is required'
    if (!formData.message.trim()) {
      newErrors.message = 'Message is required'
    } else if (formData.message.trim().length < 10) {
      newErrors.message = 'Please provide more detail (at least 10 characters)'
    }
    setErrors(newErrors)
    return Object.keys(newErrors).length === 0
  }

  const handleSubmit = (e) => {
    e.preventDefault()
    if (validate()) {
      setSubmitted(true)
    }
  }

  const handleChange = (field, value) => {
    setFormData((prev) => ({ ...prev, [field]: value }))
    if (errors[field]) {
      setErrors((prev) => ({ ...prev, [field]: undefined }))
    }
  }

  if (submitted) {
    return (
      <motion.div
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        className="bg-white rounded-2xl p-8 lg:p-12 shadow-md border border-nature-light/20 text-center"
      >
        <div className="w-16 h-16 rounded-full bg-nature-light/20 flex items-center justify-center mx-auto mb-6">
          <CheckCircle className="w-8 h-8 text-forest-green" />
        </div>
        <h3 className="text-2xl font-bold text-forest-green mb-3">Message Sent Successfully!</h3>
        <p className="text-earth-brown/70 max-w-md mx-auto">
          Thank you for reaching out. We have received your message and will respond within 2 business days.
        </p>
        <button
          onClick={() => {
            setSubmitted(false)
            setFormData({ name: '', email: '', subject: '', message: '' })
          }}
          className="mt-6 inline-flex items-center px-6 py-3 bg-forest-green text-white font-semibold rounded-full hover:bg-nature-green transition-colors duration-200"
        >
          Send Another Message
        </button>
      </motion.div>
    )
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-6" noValidate>
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
        <div>
          <label htmlFor="contact-name" className="block text-sm font-semibold text-forest-green mb-2">
            Full Name
          </label>
          <input
            id="contact-name"
            type="text"
            value={formData.name}
            onChange={(e) => handleChange('name', e.target.value)}
            className={`w-full px-4 py-3 rounded-xl border ${
              errors.name ? 'border-red-400' : 'border-nature-light/40'
            } bg-white text-gray-900 focus:outline-none focus:ring-2 focus:ring-forest-green/30 focus:border-forest-green transition-colors`}
            placeholder="Enter your full name"
          />
          {errors.name && <p className="mt-1 text-sm text-red-500">{errors.name}</p>}
        </div>
        <div>
          <label htmlFor="contact-email" className="block text-sm font-semibold text-forest-green mb-2">
            Email Address
          </label>
          <input
            id="contact-email"
            type="email"
            value={formData.email}
            onChange={(e) => handleChange('email', e.target.value)}
            className={`w-full px-4 py-3 rounded-xl border ${
              errors.email ? 'border-red-400' : 'border-nature-light/40'
            } bg-white text-gray-900 focus:outline-none focus:ring-2 focus:ring-forest-green/30 focus:border-forest-green transition-colors`}
            placeholder="you@example.com"
          />
          {errors.email && <p className="mt-1 text-sm text-red-500">{errors.email}</p>}
        </div>
      </div>

      <div>
        <label htmlFor="contact-subject" className="block text-sm font-semibold text-forest-green mb-2">
          Subject
        </label>
        <input
          id="contact-subject"
          type="text"
          value={formData.subject}
          onChange={(e) => handleChange('subject', e.target.value)}
          className={`w-full px-4 py-3 rounded-xl border ${
            errors.subject ? 'border-red-400' : 'border-nature-light/40'
          } bg-white text-gray-900 focus:outline-none focus:ring-2 focus:ring-forest-green/30 focus:border-forest-green transition-colors`}
          placeholder="What is this about?"
        />
        {errors.subject && <p className="mt-1 text-sm text-red-500">{errors.subject}</p>}
      </div>

      <div>
        <label htmlFor="contact-message" className="block text-sm font-semibold text-forest-green mb-2">
          Message
        </label>
        <textarea
          id="contact-message"
          rows={6}
          value={formData.message}
          onChange={(e) => handleChange('message', e.target.value)}
          className={`w-full px-4 py-3 rounded-xl border ${
            errors.message ? 'border-red-400' : 'border-nature-light/40'
          } bg-white text-gray-900 focus:outline-none focus:ring-2 focus:ring-forest-green/30 focus:border-forest-green transition-colors resize-none`}
          placeholder="Write your message here..."
        />
        {errors.message && <p className="mt-1 text-sm text-red-500">{errors.message}</p>}
      </div>

      <button
        type="submit"
        className="inline-flex items-center gap-2 px-8 py-3 bg-forest-green text-white font-semibold rounded-full hover:bg-nature-green transition-colors duration-200 shadow-sm hover:shadow-md"
      >
        <Send className="w-4 h-4" />
        Send Message
      </button>
    </form>
  )
}
