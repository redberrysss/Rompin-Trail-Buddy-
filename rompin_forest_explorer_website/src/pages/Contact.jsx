import { motion } from 'framer-motion'
import { Link } from 'react-router-dom'
import {
  Mail, Phone, MapPin, Clock, Building2, Globe, ExternalLink,
  ChevronRight,
} from 'lucide-react'
import PageHeader from '../components/PageHeader'
import ContactForm from '../components/ContactForm'

const contactInfo = [
  {
    icon: Building2,
    title: 'Organization',
    detail: 'Rompin Forest Explorer Programme',
    sub: 'Outdoor Education Initiative',
  },
  {
    icon: Mail,
    title: 'Email',
    detail: 'info@rompinforestexplorer.com',
    sub: 'We respond within 2 business days',
  },
  {
    icon: Phone,
    title: 'Phone',
    detail: '+60-12-345-6789',
    sub: 'Available during office hours',
  },
  {
    icon: MapPin,
    title: 'Address',
    detail: 'Rompin, Pahang, Malaysia',
    sub: 'Visits by appointment only',
  },
  {
    icon: Clock,
    title: 'Office Hours',
    detail: 'Monday - Friday',
    sub: '9:00 AM - 5:00 PM MYT',
  },
]

const quickFaqs = [
  {
    question: 'How do I download the app?',
    answer: 'Visit the Google Play Store on your Android device, search for "Rompin Forest Explorer," and tap Install. The app requires Android 8.0 or newer.',
  },
  {
    question: 'Is the app free to use?',
    answer: 'Yes, Rompin Forest Explorer is completely free to download and use. There are no subscription fees or in-app purchases.',
  },
  {
    question: 'How do I reset my password?',
    answer: 'On the login screen, tap "Forgot Password" and enter your registered email address. Follow the link in the email to create a new password.',
  },
  {
    question: 'Can I use the app offline?',
    answer: 'Core features work with limited connectivity. Your data will sync to the cloud automatically when an internet connection is available.',
  },
  {
    question: 'How do I report a problem?',
    answer: 'Use the contact form on this page or email us directly at support@rompinforestexplorer.com with details about the issue you are experiencing.',
  },
]

const containerVariants = {
  hidden: {},
  visible: { transition: { staggerChildren: 0.1 } },
}

const itemVariants = {
  hidden: { opacity: 0, y: 30 },
  visible: { opacity: 1, y: 0, transition: { duration: 0.5 } },
}

export default function Contact() {
  return (
    <div>
      <PageHeader
        title="Contact Us"
        subtitle="We'd love to hear from you"
      />

      <section className="py-16 lg:py-20">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            className="text-center mb-16"
          >
            <p className="text-earth-brown/80 text-lg max-w-3xl mx-auto leading-relaxed">
              Whether you have a question about our activities, need technical support, or want to 
              partner with us, our team is ready to help. Reach out and we will get back to you as 
              soon as possible.
            </p>
          </motion.div>

          <div className="mb-20">
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              className="text-center mb-12"
            >
              <h2 className="text-3xl sm:text-4xl font-bold text-forest-green mb-4">
                Contact Information
              </h2>
              <div className="w-20 h-1 bg-nature-green mx-auto rounded-full" />
            </motion.div>

            <motion.div
              variants={containerVariants}
              initial="hidden"
              whileInView="visible"
              viewport={{ once: true, margin: '-50px' }}
              className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6"
            >
              {contactInfo.map((item, index) => {
                const Icon = item.icon
                return (
                  <motion.div
                    key={index}
                    variants={itemVariants}
                    whileHover={{ y: -4, transition: { duration: 0.2 } }}
                    className="bg-white rounded-2xl p-6 shadow-md border border-nature-light/20 text-center"
                  >
                    <div className="w-14 h-14 rounded-full bg-nature-light/20 flex items-center justify-center mx-auto mb-4">
                      <Icon className="w-7 h-7 text-forest-green" />
                    </div>
                    <h3 className="text-lg font-bold text-forest-green mb-1">{item.title}</h3>
                    <p className="text-earth-brown font-medium mb-1">{item.detail}</p>
                    <p className="text-earth-brown/60 text-sm">{item.sub}</p>
                  </motion.div>
                )
              })}
            </motion.div>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 lg:gap-16 mb-20">
            <motion.div
              initial={{ opacity: 0, x: -20 }}
              whileInView={{ opacity: 1, x: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5 }}
            >
              <h2 className="text-3xl sm:text-4xl font-bold text-forest-green mb-4">
                Send Us a Message
              </h2>
              <div className="w-20 h-1 bg-nature-green rounded-full mb-6" />
              <p className="text-earth-brown/70 mb-8 leading-relaxed">
                Fill out the form below and our team will respond within 2 business days. 
                For urgent matters, please reach out by phone during office hours.
              </p>
              <div className="bg-white rounded-2xl p-6 lg:p-8 shadow-md border border-nature-light/20">
                <ContactForm />
              </div>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, x: 20 }}
              whileInView={{ opacity: 1, x: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: 0.1 }}
              className="space-y-8"
            >
              <div>
                <h2 className="text-3xl sm:text-4xl font-bold text-forest-green mb-4">
                  Find Us
                </h2>
                <div className="w-20 h-1 bg-nature-green rounded-full mb-6" />
                <div className="bg-white rounded-2xl p-8 shadow-md border border-nature-light/20 flex flex-col items-center justify-center min-h-[220px]">
                  <div className="w-16 h-16 rounded-full bg-nature-light/20 flex items-center justify-center mb-4">
                    <MapPin className="w-8 h-8 text-forest-green" />
                  </div>
                  <p className="text-forest-green font-semibold text-lg mb-1">Map Coming Soon</p>
                  <p className="text-earth-brown/60 text-sm text-center">
                    We are working on adding an interactive map to help you find our location in Rompin, Pahang.
                  </p>
                </div>
              </div>

              <div>
                <h2 className="text-2xl font-bold text-forest-green mb-4">
                  Quick Links
                </h2>
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  {[
                    { label: 'User Guide', path: '/user-guide' },
                    { label: 'Support & Help', path: '/support' },
                    { label: 'Privacy Policy', path: '/privacy' },
                    { label: 'Terms of Use', path: '/terms' },
                  ].map((link) => (
                    <Link
                      key={link.path}
                      to={link.path}
                      className="flex items-center gap-2 px-4 py-3 bg-white rounded-xl border border-nature-light/30 hover:border-forest-green/30 hover:bg-cream/50 transition-all duration-200 group"
                    >
                      <ChevronRight className="w-4 h-4 text-nature group-hover:text-forest-green transition-colors" />
                      <span className="text-earth-brown group-hover:text-forest-green font-medium transition-colors">
                        {link.label}
                      </span>
                    </Link>
                  ))}
                </div>
              </div>

              <div>
                <h2 className="text-2xl font-bold text-forest-green mb-4">
                  Connect With Us
                </h2>
                <div className="flex gap-4">
                  <a
                    href="https://github.com"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="w-12 h-12 rounded-full bg-white border border-nature-light/30 flex items-center justify-center text-earth-brown hover:text-forest-green hover:border-forest-green/30 transition-all duration-200"
                    aria-label="GitHub"
                  >
                    <Globe className="w-5 h-5" />
                  </a>
                  <a
                    href="https://twitter.com"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="w-12 h-12 rounded-full bg-white border border-nature-light/30 flex items-center justify-center text-earth-brown hover:text-forest-green hover:border-forest-green/30 transition-all duration-200"
                    aria-label="Twitter"
                  >
                    <ExternalLink className="w-5 h-5" />
                  </a>
                  <a
                    href="mailto:info@rompinforestexplorer.com"
                    className="w-12 h-12 rounded-full bg-white border border-nature-light/30 flex items-center justify-center text-earth-brown hover:text-forest-green hover:border-forest-green/30 transition-all duration-200"
                    aria-label="Email us"
                  >
                    <Mail className="w-5 h-5" />
                  </a>
                </div>
              </div>
            </motion.div>
          </div>

          <div>
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              className="text-center mb-10"
            >
              <h2 className="text-3xl sm:text-4xl font-bold text-forest-green mb-4">
                Frequently Asked Questions
              </h2>
              <div className="w-20 h-1 bg-nature-green mx-auto rounded-full" />
            </motion.div>

            <div className="max-w-3xl mx-auto space-y-4">
              {quickFaqs.map((faq, index) => (
                <motion.div
                  key={index}
                  initial={{ opacity: 0, y: 20 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  viewport={{ once: true }}
                  transition={{ delay: index * 0.05, duration: 0.4 }}
                  className="bg-white rounded-xl p-5 border border-nature-light/30 shadow-sm"
                >
                  <h3 className="font-semibold text-forest-green mb-2">{faq.question}</h3>
                  <p className="text-earth-brown/70 leading-relaxed text-sm">{faq.answer}</p>
                </motion.div>
              ))}
            </div>
          </div>
        </div>
      </section>
    </div>
  )
}
