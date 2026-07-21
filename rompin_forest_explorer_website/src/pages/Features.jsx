import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import {
  Leaf,
  BookOpen,
  ListChecks,
  Camera,
  Save,
  BarChart3,
  LayoutDashboard,
  Users,
  Shield,
  Award,
  WifiOff,
  Cloud,
  Navigation,
  Heart,
  ClipboardList,
  Calendar,
} from 'lucide-react'
import { features } from '../data/features'

const iconMap = {
  BookOpen,
  ListChecks,
  Camera,
  Leaf,
  Save,
  BarChart3,
  LayoutDashboard,
  Users,
  Shield,
  Award,
  WifiOff,
  Cloud,
  Navigation,
  Heart,
  ClipboardList,
  Calendar,
}

const fadeInUp = {
  hidden: { opacity: 0, y: 30 },
  visible: { opacity: 1, y: 0, transition: { duration: 0.6, ease: 'easeOut' } },
}

const staggerContainer = {
  hidden: {},
  visible: { transition: { staggerChildren: 0.07 } },
}

function PageHeader({ title, subtitle }) {
  return (
    <section className="bg-gradient-to-br from-forest-dark via-forest to-forest-light py-20 md:py-28">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <motion.h1
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
          className="text-4xl md:text-5xl font-bold text-white mb-4"
        >
          {title}
        </motion.h1>
        <motion.p
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.15 }}
          className="text-lg text-white/80 max-w-2xl mx-auto"
        >
          {subtitle}
        </motion.p>
      </div>
    </section>
  )
}

const categories = [
  { key: 'all', label: 'All Features' },
  { key: 'core', label: 'Core' },
  { key: 'accessibility', label: 'Accessibility' },
  { key: 'technical', label: 'Technical' },
]

const categoryDescriptions = {
  core: {
    title: 'Core Features',
    desc: 'The essential tools that power structured nature learning — from visual instructions and observation checklists to photo capture, progress tracking, and the facilitator dashboard.',
  },
  accessibility: {
    title: 'Accessibility Features',
    desc: 'Design elements specifically crafted to support children with autism and other accessibility needs, including simple navigation, visual schedules, and calming design choices.',
  },
  technical: {
    title: 'Technical Features',
    desc: 'Behind-the-scenes capabilities that ensure reliability, security, and seamless performance — including role-based access, cloud storage, and offline-friendly design.',
  },
}

export default function Features() {
  const [filter, setFilter] = useState('all')
  const filtered = filter === 'all' ? features : features.filter((f) => f.category === filter)

  return (
    <div>
      <PageHeader
        title="App Features"
        subtitle="Discover the tools that make nature learning accessible and engaging"
      />

      <section className="bg-white py-20">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex flex-wrap justify-center gap-3 mb-12">
            {categories.map((cat) => (
              <button
                key={cat.key}
                onClick={() => setFilter(cat.key)}
                className={`px-6 py-2.5 rounded-full text-sm font-semibold transition-colors ${
                  filter === cat.key
                    ? 'bg-forest text-white shadow-md'
                    : 'bg-cream text-nature/70 hover:bg-cream-dark border border-cream-dark'
                }`}
              >
                {cat.label}
              </button>
            ))}
          </div>

          {filter !== 'all' && categoryDescriptions[filter] && (
            <motion.div
              key={filter}
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.3 }}
              className="max-w-2xl mx-auto text-center mb-12"
            >
              <h3 className="text-xl font-bold text-forest-dark mb-2">
                {categoryDescriptions[filter].title}
              </h3>
              <p className="text-nature/70 leading-relaxed">
                {categoryDescriptions[filter].desc}
              </p>
            </motion.div>
          )}

          <AnimatePresence mode="wait">
            <motion.div
              key={filter}
              initial="hidden"
              animate="visible"
              exit="hidden"
              variants={staggerContainer}
              className="grid sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6"
            >
              {filtered.map((feature) => {
                const Icon = iconMap[feature.icon] || Leaf
                return (
                  <motion.div
                    key={feature.id}
                    variants={fadeInUp}
                    className="bg-cream rounded-2xl p-7 border border-cream-dark hover:shadow-lg transition-shadow group"
                  >
                    <div className="w-12 h-12 bg-nature/10 rounded-xl flex items-center justify-center mb-4 group-hover:bg-nature/20 transition-colors">
                      <Icon className="w-6 h-6 text-nature" />
                    </div>
                    <span className="inline-block text-xs font-medium text-nature/50 uppercase tracking-wider mb-2">
                      {feature.category}
                    </span>
                    <h3 className="font-semibold text-forest-dark mb-2">
                      {feature.title}
                    </h3>
                    <p className="text-sm text-nature/70 leading-relaxed">
                      {feature.description}
                    </p>
                  </motion.div>
                )
              })}
            </motion.div>
          </AnimatePresence>

          {filtered.length === 0 && (
            <div className="text-center py-16 text-nature/50">
              <Leaf className="w-12 h-12 mx-auto mb-4 opacity-40" />
              <p>No features found for this category.</p>
            </div>
          )}
        </div>
      </section>

      <section className="bg-cream py-20">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-3xl mx-auto mb-12">
            <h2 className="text-3xl md:text-4xl font-bold text-forest-dark mb-4">
              Every Feature, Thoughtfully Designed
            </h2>
            <p className="text-lg text-nature/80">
              From the visual instructions that guide each step to the cloud storage that
              preserves every observation, Rompin Forest Explorer is built with purpose at every layer.
            </p>
          </div>
          <div className="grid md:grid-cols-3 gap-8">
            {[
              {
                title: 'Designed for Learners',
                desc: 'Large buttons, calm colours, and icon-based navigation ensure that children of all abilities can use the app independently and confidently.',
                icon: Heart,
              },
              {
                title: 'Built for Facilitators',
                desc: 'Real-time dashboards, activity management tools, and observation reviews give facilitators everything they need to guide effective sessions.',
                icon: LayoutDashboard,
              },
              {
                title: 'Powered by Technology',
                desc: 'Firebase cloud storage, secure authentication, role-based access, and offline-friendly design ensure reliability in any environment.',
                icon: Shield,
              },
            ].map((item) => {
              const Icon = item.icon
              return (
                <motion.div
                  key={item.title}
                  initial="hidden"
                  whileInView="visible"
                  viewport={{ once: true }}
                  variants={fadeInUp}
                  className="bg-white rounded-2xl p-8 border border-cream-dark text-center"
                >
                  <div className="w-14 h-14 bg-forest/10 rounded-2xl flex items-center justify-center mx-auto mb-5">
                    <Icon className="w-7 h-7 text-forest" />
                  </div>
                  <h3 className="font-bold text-forest-dark text-lg mb-2">{item.title}</h3>
                  <p className="text-sm text-nature/70 leading-relaxed">{item.desc}</p>
                </motion.div>
              )
            })}
          </div>
        </div>
      </section>

      <section className="bg-forest py-20">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <motion.div initial="hidden" whileInView="visible" viewport={{ once: true }} variants={fadeInUp}>
            <h2 className="text-3xl font-bold text-white mb-4">See All Features in Action</h2>
            <p className="text-lg text-white/70 mb-8">
              Download the app today and experience every feature designed to make nature learning accessible.
            </p>
            <a
              href="/downloads/rompin-forest-explorer.apk"
              download
              className="inline-flex items-center gap-2 bg-nature-light hover:bg-nature text-forest-dark font-semibold px-10 py-4 rounded-full transition-colors shadow-lg text-lg"
            >
              <Leaf className="w-5 h-5" /> Download APK
            </a>
          </motion.div>
        </div>
      </section>
    </div>
  )
}
