import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import {
  Leaf,
  ChevronDown,
  Clock,
  Users,
  Wrench,
  CheckCircle,
  AlertCircle,
  Footprints,
  Binoculars,
  Flower2,
  ClipboardCheck,
  Sparkles,
  Download,
  BookOpen,
  Camera,
  Check,
} from 'lucide-react'
import { activities } from '../data/activities'

const iconMap = {
  Footprints,
  Binoculars,
  Flower2,
  ClipboardCheck,
  Sparkles,
  Users,
  Image: Camera,
}

const fadeInUp = {
  hidden: { opacity: 0, y: 30 },
  visible: { opacity: 1, y: 0, transition: { duration: 0.6, ease: 'easeOut' } },
}

const staggerContainer = {
  hidden: {},
  visible: { transition: { staggerChildren: 0.12 } },
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

function ActivityCard({ activity, isOpen, onToggle }) {
  const Icon = iconMap[activity.icon] || Leaf

  return (
    <motion.div
      variants={fadeInUp}
      className="bg-white rounded-2xl border border-cream-dark overflow-hidden shadow-sm hover:shadow-md transition-shadow"
    >
      <button
        onClick={onToggle}
        className="w-full flex items-center gap-5 p-6 md:p-8 text-left"
      >
        <div className="w-14 h-14 bg-nature/10 rounded-2xl flex items-center justify-center shrink-0">
          <Icon className="w-7 h-7 text-nature" />
        </div>
        <div className="flex-1 min-w-0">
          <h3 className="font-bold text-forest-dark text-lg mb-0.5">
            {activity.title}
          </h3>
          <p className="text-sm text-nature/50 italic">{activity.malayName}</p>
          <div className="flex flex-wrap items-center gap-4 mt-2 text-xs text-nature/60">
            <span className="flex items-center gap-1">
              <Clock className="w-3.5 h-3.5" /> {activity.duration}
            </span>
            <span className="flex items-center gap-1">
              <Users className="w-3.5 h-3.5" /> {activity.groupSize}
            </span>
          </div>
        </div>
        <ChevronDown
          className={`w-5 h-5 text-nature/50 shrink-0 transition-transform duration-200 ${
            isOpen ? 'rotate-180' : ''
          }`}
        />
      </button>

      <AnimatePresence>
        {isOpen && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: 'auto', opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            transition={{ duration: 0.3, ease: 'easeInOut' }}
            className="overflow-hidden"
          >
            <div className="px-6 md:px-8 pb-8 border-t border-cream-dark pt-6">
              <p className="text-nature/80 leading-relaxed mb-6">
                <strong className="text-forest-dark">Objective:</strong> {activity.objective}
              </p>

              <div className="grid md:grid-cols-2 gap-6">
                <div>
                  <h4 className="font-semibold text-forest-dark mb-3 flex items-center gap-2">
                    <BookOpen className="w-4 h-4 text-nature" /> Activity Steps
                  </h4>
                  <ol className="space-y-2">
                    {activity.steps.map((step, i) => (
                      <li key={i} className="flex items-start gap-3 text-sm text-nature/70">
                        <span className="w-5 h-5 rounded-full bg-nature/10 flex items-center justify-center shrink-0 text-xs font-semibold text-nature mt-0.5">
                          {i + 1}
                        </span>
                        {step}
                      </li>
                    ))}
                  </ol>
                </div>

                <div className="space-y-6">
                  <div>
                    <h4 className="font-semibold text-forest-dark mb-3 flex items-center gap-2">
                      <Wrench className="w-4 h-4 text-nature" /> Materials Needed
                    </h4>
                    <ul className="space-y-1.5">
                      {activity.materials.map((mat, i) => (
                        <li
                          key={i}
                          className="flex items-center gap-2 text-sm text-nature/70"
                        >
                          <CheckCircle className="w-3.5 h-3.5 text-nature/40 shrink-0" />
                          {mat}
                        </li>
                      ))}
                    </ul>
                  </div>

                  <div>
                    <h4 className="font-semibold text-forest-dark mb-3 flex items-center gap-2">
                      <AlertCircle className="w-4 h-4 text-nature" /> Autism-Friendly Modifications
                    </h4>
                    <ul className="space-y-1.5">
                      {activity.modifications.map((mod, i) => (
                        <li
                          key={i}
                          className="flex items-start gap-2 text-sm text-nature/70"
                        >
                          <Check className="w-3.5 h-3.5 text-nature shrink-0 mt-0.5" />
                          {mod}
                        </li>
                      ))}
                    </ul>
                  </div>
                </div>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  )
}

export default function Activities() {
  const [openId, setOpenId] = useState(null)

  return (
    <div>
      <PageHeader
        title="Nature Learning Activities"
        subtitle="Structured outdoor activities designed for children with autism"
      />

      <section className="bg-white py-20">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.3 }}
            className="bg-cream rounded-2xl p-8 border border-cream-dark mb-12"
          >
            <h2 className="text-2xl font-bold text-forest-dark mb-4">
              Structured Activities for Meaningful Learning
            </h2>
            <div className="space-y-4 text-nature/80 leading-relaxed">
              <p>
                Each activity in Rompin Forest Explorer has been carefully designed to provide structure,
                predictability, and sensory consideration for children with autism. Activities are broken
                into clear steps, accompanied by visual instructions, and include built-in modifications
                to accommodate different needs and abilities.
              </p>
              <p>
                Facilitators can choose from a range of activities depending on the group&apos;s interests,
                the available time, and the specific learning objectives. Every activity includes a
                materials list, suggested duration, group size recommendations, and autism-friendly
                modifications to ensure a successful experience for every participant.
              </p>
              <p>
                Click on any activity below to explore its full details, including step-by-step
                instructions, required materials, and recommended modifications.
              </p>
            </div>
          </motion.div>

          <motion.div
            variants={staggerContainer}
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true }}
            className="space-y-4"
          >
            {activities.map((activity) => (
              <ActivityCard
                key={activity.id}
                activity={activity}
                isOpen={openId === activity.id}
                onToggle={() => setOpenId(openId === activity.id ? null : activity.id)}
              />
            ))}
          </motion.div>
        </div>
      </section>

      <section className="bg-cream py-20">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-3xl mx-auto mb-10">
            <h2 className="text-3xl font-bold text-forest-dark mb-4">
              All Activities Include
            </h2>
            <p className="text-nature/80">
              Every activity comes with the same level of care and detail to ensure successful outcomes.
            </p>
          </div>
          <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-5">
            {[
              { icon: BookOpen, title: 'Step-by-Step Instructions', desc: 'Clear, numbered steps that guide each activity from start to finish.' },
              { icon: Wrench, title: 'Materials Lists', desc: 'Everything you need to prepare, listed before the activity begins.' },
              { icon: AlertCircle, title: 'Modification Guides', desc: 'Autism-friendly adaptations for every activity to suit different needs.' },
              { icon: Clock, title: 'Time Estimates', desc: 'Realistic duration ranges to help facilitators plan their sessions.' },
            ].map((item) => {
              const Icon = item.icon
              return (
                <motion.div
                  key={item.title}
                  initial="hidden"
                  whileInView="visible"
                  viewport={{ once: true }}
                  variants={fadeInUp}
                  className="bg-white rounded-2xl p-6 border border-cream-dark text-center"
                >
                  <div className="w-11 h-11 bg-nature/10 rounded-xl flex items-center justify-center mx-auto mb-3">
                    <Icon className="w-5 h-5 text-nature" />
                  </div>
                  <h4 className="font-semibold text-forest-dark mb-1 text-sm">{item.title}</h4>
                  <p className="text-xs text-nature/60 leading-relaxed">{item.desc}</p>
                </motion.div>
              )
            })}
          </div>
        </div>
      </section>

      <section className="bg-forest py-20">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <motion.div initial="hidden" whileInView="visible" viewport={{ once: true }} variants={fadeInUp}>
            <h2 className="text-3xl font-bold text-white mb-4">
              Ready to Start Exploring?
            </h2>
            <p className="text-lg text-white/70 mb-8">
              Download the app and access all activities with guided instructions and visual support.
            </p>
            <a
              href="/downloads/rompin-forest-explorer.apk"
              download
              className="inline-flex items-center gap-2 bg-nature-light hover:bg-nature text-forest-dark font-semibold px-10 py-4 rounded-full transition-colors shadow-lg text-lg"
            >
              <Download className="w-5 h-5" /> Download APK
            </a>
          </motion.div>
        </div>
      </section>
    </div>
  )
}
