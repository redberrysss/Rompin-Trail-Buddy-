import { useState } from 'react'
import { motion } from 'framer-motion'
import {
  AlertTriangle, Smartphone, LogIn, MapPin, WifiOff,
  ChevronDown, Mail, Phone, Clock,
} from 'lucide-react'
import PageHeader from '../components/PageHeader'
import SupportForm from '../components/SupportForm'

const troubleshootingTopics = [
  {
    icon: Smartphone,
    title: 'App Installation Issues',
    items: [
      {
        q: 'I cannot install the app from the Play Store.',
        a: 'Ensure your device is running Android 8.0 or newer. Check that you have a stable internet connection and sufficient storage space. If the Play Store shows compatibility issues, your device may not meet the minimum requirements.',
      },
      {
        q: 'My device storage is full. How can I free up space?',
        a: 'Go to your device Settings > Storage to see what is using space. Consider clearing app caches, deleting unused apps, or moving photos and videos to cloud storage or an SD card to free up space for the installation.',
      },
      {
        q: 'The app is incompatible with my device.',
        a: 'Rompin Forest Explorer requires Android 8.0 or newer. If your device is running an older version, consider updating your device software or using a compatible device. Contact us if you believe your device should be supported.',
      },
    ],
  },
  {
    icon: LogIn,
    title: 'Login and Account Issues',
    items: [
      {
        q: 'I forgot my password.',
        a: 'Tap "Forgot Password" on the login screen and enter your registered email address. You will receive a password reset link within a few minutes. Check your spam or junk folder if you do not see the email.',
      },
      {
        q: 'My account is locked after too many failed attempts.',
        a: 'For security, accounts are temporarily locked after multiple failed login attempts. Wait 15 minutes and try again with your correct credentials. If you continue to have issues, contact support for assistance.',
      },
      {
        q: 'I did not receive the email verification link.',
        a: 'Check your spam or junk folder first. You can also tap "Resend Verification Email" on the login screen. Make sure you entered the correct email address during registration. Contact support if the issue persists.',
      },
    ],
  },
  {
    icon: MapPin,
    title: 'Activity Issues',
    items: [
      {
        q: 'An activity will not load or is stuck on the loading screen.',
        a: 'Check your internet connection and try refreshing the app. If the problem persists, close and reopen the app. Clear the app cache from your device settings. Contact support if the issue continues.',
      },
      {
        q: 'The camera is not working during an activity.',
        a: 'Ensure you have granted camera permissions to the app in your device settings. Go to Settings > Apps > Rompin Forest Explorer > Permissions and enable Camera access. Restart the app after changing permissions.',
      },
      {
        q: 'My photos are not saving to the observation.',
        a: 'Check that you have granted both camera and storage permissions. Ensure you have sufficient device storage available. Try tapping the save button again after a few seconds. The photos will sync to the cloud when you are online.',
      },
    ],
  },
  {
    icon: WifiOff,
    title: 'Sync and Data Issues',
    items: [
      {
        q: 'My data is not syncing to the cloud.',
        a: 'Data syncs automatically when you have an active internet connection. Connect to Wi-Fi or enable mobile data and wait a few minutes. You can also try logging out and logging back in to force a sync.',
      },
      {
        q: 'Some of my observations appear to be missing.',
        a: 'Check if your device was offline when the observations were created. They may be pending sync. Ensure you are logged into the correct account. Contact support with your account details if observations are still missing.',
      },
      {
        q: 'The app is running slowly or crashing.',
        a: 'Close other running apps to free up memory. Clear the app cache from your device settings. Ensure the app is updated to the latest version. Restart your device if the issue persists.',
      },
    ],
  },
]

const supportFaqs = [
  {
    question: 'Is Rompin Forest Explorer free to use?',
    answer: 'Yes, the app is completely free to download and use. There are no subscription fees, hidden charges, or in-app purchases required.',
  },
  {
    question: 'What devices are compatible with the app?',
    answer: 'The app is available for Android devices running Android 8.0 (Oreo) or newer. We recommend using a device with at least 3 GB of RAM for the best experience.',
  },
  {
    question: 'Does the app work without an internet connection?',
    answer: 'Core features including activities, camera, and observation recording are designed to work with limited connectivity. Data automatically syncs to the cloud when an internet connection becomes available.',
  },
  {
    question: 'How do I report a bug or suggest a feature?',
    answer: 'You can report bugs or suggest features through the support form on this page, or by emailing our team directly. Please include as much detail as possible about the issue or suggestion.',
  },
  {
    question: 'How do I delete my account and data?',
    answer: 'Contact our support team to request account deletion. We will process your request within 30 days and permanently remove all your personal data from our servers in accordance with our privacy policy.',
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

export default function Support() {
  const [expandedTopic, setExpandedTopic] = useState(null)
  const [expandedFaq, setExpandedFaq] = useState(null)

  return (
    <div>
      <PageHeader
        title="Support & Help"
        subtitle="Get help with Rompin Forest Explorer"
      />

      <section className="py-16 lg:py-20">
        <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5 }}
            className="max-w-3xl mx-auto text-center mb-16"
          >
            <p className="text-earth-brown/80 text-lg leading-relaxed">
              We are here to help you get the most out of Rompin Forest Explorer. 
              Browse our troubleshooting guides below or reach out to our support team 
              for personalized assistance with any issue you may encounter.
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
                Common Troubleshooting Topics
              </h2>
              <div className="w-20 h-1 bg-nature-green mx-auto rounded-full" />
            </motion.div>

            <motion.div
              variants={containerVariants}
              initial="hidden"
              whileInView="visible"
              viewport={{ once: true, margin: '-50px' }}
              className="space-y-6"
            >
              {troubleshootingTopics.map((topic, topicIndex) => {
                const TopicIcon = topic.icon
                const isExpanded = expandedTopic === topicIndex
                return (
                  <motion.div
                    key={topicIndex}
                    variants={itemVariants}
                    className="bg-white rounded-2xl shadow-md border border-nature-light/20 overflow-hidden"
                  >
                    <button
                      onClick={() => setExpandedTopic(isExpanded ? null : topicIndex)}
                      className="w-full flex items-center gap-4 px-6 py-5 text-left hover:bg-cream/30 transition-colors duration-200"
                      aria-expanded={isExpanded}
                    >
                      <div className="w-12 h-12 rounded-full bg-nature-light/20 flex items-center justify-center flex-shrink-0">
                        <TopicIcon className="w-6 h-6 text-forest-green" />
                      </div>
                      <h3 className="text-lg lg:text-xl font-bold text-forest-green flex-1">
                        {topic.title}
                      </h3>
                      <ChevronDown
                        className={`w-5 h-5 text-earth-brown/60 flex-shrink-0 transition-transform duration-200 ${
                          isExpanded ? 'rotate-180' : ''
                        }`}
                      />
                    </button>
                    {isExpanded && (
                      <motion.div
                        initial={{ height: 0, opacity: 0 }}
                        animate={{ height: 'auto', opacity: 1 }}
                        transition={{ duration: 0.3 }}
                        className="px-6 pb-6"
                      >
                        <div className="space-y-4 border-t border-nature-light/20 pt-4">
                          {topic.items.map((item, itemIndex) => (
                            <div key={itemIndex} className="bg-cream/50 rounded-xl p-4">
                              <h4 className="font-semibold text-forest-green mb-2 flex items-start gap-2">
                                <AlertTriangle className="w-4 h-4 mt-0.5 flex-shrink-0 text-sunset" />
                                {item.q}
                              </h4>
                              <p className="text-earth-brown/80 leading-relaxed pl-6">
                                {item.a}
                              </p>
                            </div>
                          ))}
                        </div>
                      </motion.div>
                    )}
                  </motion.div>
                )
              })}
            </motion.div>
          </div>

          <div className="mb-20">
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              className="text-center mb-10"
            >
              <h2 className="text-3xl sm:text-4xl font-bold text-forest-green mb-4">
                Contact Support
              </h2>
              <div className="w-20 h-1 bg-nature-green mx-auto rounded-full mb-6" />
              <p className="text-earth-brown/70 max-w-2xl mx-auto">
                Can not find what you are looking for? Fill out the form below and our support 
                team will get back to you within 2 business days.
              </p>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              className="max-w-2xl mx-auto"
            >
              <div className="bg-white rounded-2xl p-6 lg:p-8 shadow-md border border-nature-light/20">
                <SupportForm />
              </div>
            </motion.div>
          </div>

          <div className="mb-20">
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              className="text-center mb-10"
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
              className="grid grid-cols-1 md:grid-cols-3 gap-6"
            >
              {[
                {
                  icon: Mail,
                  title: 'Email',
                  detail: 'support@rompinforestexplorer.com',
                  sub: 'We respond within 2 business days',
                },
                {
                  icon: Phone,
                  title: 'Phone',
                  detail: '+60-12-345-6789',
                  sub: 'Available during office hours',
                },
                {
                  icon: Clock,
                  title: 'Operating Hours',
                  detail: 'Monday - Friday',
                  sub: '9:00 AM - 5:00 PM MYT',
                },
              ].map((contact, index) => {
                const ContactIcon = contact.icon
                return (
                  <motion.div
                    key={index}
                    variants={itemVariants}
                    className="bg-white rounded-2xl p-6 shadow-md border border-nature-light/20 text-center"
                  >
                    <div className="w-12 h-12 rounded-full bg-nature-light/20 flex items-center justify-center mx-auto mb-4">
                      <ContactIcon className="w-6 h-6 text-forest-green" />
                    </div>
                    <h3 className="text-lg font-bold text-forest-green mb-1">{contact.title}</h3>
                    <p className="text-earth-brown font-medium mb-1">{contact.detail}</p>
                    <p className="text-earth-brown/60 text-sm">{contact.sub}</p>
                  </motion.div>
                )
              })}
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
              {supportFaqs.map((faq, index) => (
                <motion.div
                  key={index}
                  initial={{ opacity: 0, y: 20 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  viewport={{ once: true }}
                  transition={{ delay: index * 0.05, duration: 0.4 }}
                  className="border border-nature-light/30 rounded-xl overflow-hidden"
                >
                  <button
                    onClick={() => setExpandedFaq(expandedFaq === index ? null : index)}
                    className="w-full flex items-center justify-between px-6 py-4 text-left bg-cream/50 hover:bg-cream transition-colors duration-200"
                    aria-expanded={expandedFaq === index}
                  >
                    <span className="font-semibold text-forest-green pr-4">
                      {faq.question}
                    </span>
                    <ChevronDown
                      className={`w-5 h-5 text-earth-brown/60 flex-shrink-0 transition-transform duration-200 ${
                        expandedFaq === index ? 'rotate-180' : ''
                      }`}
                    />
                  </button>
                  {expandedFaq === index && (
                    <motion.div
                      initial={{ height: 0, opacity: 0 }}
                      animate={{ height: 'auto', opacity: 1 }}
                      transition={{ duration: 0.3 }}
                      className="px-6 pb-5 text-earth-brown/80 leading-relaxed"
                    >
                      {faq.answer}
                    </motion.div>
                  )}
                </motion.div>
              ))}
            </div>
          </div>
        </div>
      </section>
    </div>
  )
}
