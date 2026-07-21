import { useState } from 'react'
import { Link } from 'react-router-dom'
import { motion, AnimatePresence } from 'framer-motion'
import {
  Leaf,
  Download,
  ArrowRight,
  Check,
  ChevronRight,
  ChevronLeft,
  Star,
  ChevronDown,
  Shield,
  Footprints,
  Binoculars,
  Flower2,
  ClipboardCheck,
  Sparkles,
  Users,
  GraduationCap,
  Heart,
  Eye,
  Camera,
  BookOpen,
  BarChart3,
  LayoutDashboard,
  Award,
  Mail,
  Phone,
} from 'lucide-react'
import { activities } from '../data/activities'
import { features } from '../data/features'
import { testimonials } from '../data/testimonials'

const iconMap = {
  Footprints,
  Binoculars,
  Flower2,
  ClipboardCheck,
  Sparkles,
  Users,
  Image: Camera,
  BookOpen,
  ListChecks: ClipboardCheck,
  Camera,
  Leaf,
  Save: LayoutDashboard,
  BarChart3,
  LayoutDashboard,
  Shield,
  Award,
  WifiOff: Shield,
  Cloud: Shield,
  Navigation: ArrowRight,
  Heart,
  ClipboardList: ClipboardCheck,
  Calendar: BookOpen,
}

const fadeInUp = {
  hidden: { opacity: 0, y: 30 },
  visible: { opacity: 1, y: 0, transition: { duration: 0.6, ease: 'easeOut' } },
}

const staggerContainer = {
  hidden: {},
  visible: { transition: { staggerChildren: 0.1 } },
}

function SectionTitle({ title, subtitle, light = false }) {
  return (
    <div className="text-center max-w-3xl mx-auto mb-12">
      <h2
        className={`text-3xl md:text-4xl font-bold mb-4 ${
          light ? 'text-white' : 'text-forest-dark'
        }`}
      >
        {title}
      </h2>
      {subtitle && (
        <p
          className={`text-lg ${
            light ? 'text-nature-light/90' : 'text-nature/80'
          }`}
        >
          {subtitle}
        </p>
      )}
    </div>
  )
}

function Section({ children, className = '', id }) {
  return (
    <motion.section
      id={id}
      initial="hidden"
      whileInView="visible"
      viewport={{ once: true, margin: '-50px' }}
      variants={{
        hidden: { opacity: 0 },
        visible: { opacity: 1, transition: { duration: 0.5 } },
      }}
      className={className}
    >
      {children}
    </motion.section>
  )
}

function HeroSection() {
  return (
    <section className="relative bg-gradient-to-br from-forest-dark via-forest to-forest-light overflow-hidden">
      <div className="absolute inset-0 opacity-10">
        <div className="absolute top-10 left-10 w-64 h-64 rounded-full bg-nature-light blur-3xl" />
        <div className="absolute bottom-10 right-10 w-96 h-96 rounded-full bg-nature blur-3xl" />
      </div>
      <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20 md:py-28">
        <div className="grid md:grid-cols-2 gap-12 items-center">
          <motion.div
            initial={{ opacity: 0, x: -40 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.7 }}
          >
            <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold text-white leading-tight mb-6">
              Explore Nature.{' '}
              <span className="text-nature-light">Learn with Confidence.</span>
            </h1>
            <p className="text-lg text-white/80 mb-8 leading-relaxed max-w-lg">
              Rompin Forest Explorer is an autism-friendly mobile application that
              helps children explore forests through structured activities, visual
              guidance, photo observations, and facilitator support.
            </p>
            <div className="flex flex-wrap gap-4">
              <Link
                to="/download"
                className="inline-flex items-center gap-2 bg-nature-light hover:bg-nature text-forest-dark font-semibold px-8 py-3.5 rounded-full transition-colors shadow-lg"
              >
                <Download className="w-5 h-5" />
                Download Android App
              </Link>
              <Link
                to="/features"
                className="inline-flex items-center gap-2 border-2 border-white/30 hover:border-white/60 text-white font-semibold px-8 py-3.5 rounded-full transition-colors"
              >
                Explore Features
                <ArrowRight className="w-5 h-5" />
              </Link>
            </div>
          </motion.div>
          <motion.div
            initial={{ opacity: 0, x: 40 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.7, delay: 0.2 }}
            className="hidden md:flex justify-center"
          >
            <div className="relative">
              <div className="w-72 h-[520px] bg-white/10 backdrop-blur-sm rounded-[3rem] border-2 border-white/20 shadow-2xl flex items-center justify-center overflow-hidden">
                <div className="text-center px-8">
                  <div className="w-20 h-20 bg-nature-light/20 rounded-2xl flex items-center justify-center mx-auto mb-6">
                    <Leaf className="w-10 h-10 text-nature-light" />
                  </div>
                  <p className="text-white/60 text-sm font-medium mb-2">
                    Rompin Forest Explorer
                  </p>
                  <p className="text-white/40 text-xs">
                    Autism-Friendly Nature Learning
                  </p>
                  <div className="mt-8 space-y-3">
                    {[1, 2, 3].map((i) => (
                      <div
                        key={i}
                        className="h-10 bg-white/10 rounded-xl animate-pulse"
                        style={{ animationDelay: `${i * 0.2}s` }}
                      />
                    ))}
                  </div>
                </div>
              </div>
              <div className="absolute -bottom-4 -right-4 w-24 h-24 bg-nature-light/20 rounded-full blur-2xl" />
              <div className="absolute -top-4 -left-4 w-16 h-16 bg-sky/20 rounded-full blur-xl" />
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  )
}

function TrustedBy() {
  const partners = [
    'Ministry of Education',
    'Forest Department',
    'UNICEF Malaysia',
    'Autism Society',
    'UNESCO',
  ]
  return (
    <Section className="bg-cream py-14 border-b border-cream-dark">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <p className="text-center text-sm font-medium text-nature/70 uppercase tracking-widest mb-8">
          Trusted by leading organisations
        </p>
        <div className="flex flex-wrap justify-center items-center gap-8 md:gap-14">
          {partners.map((name) => (
            <motion.div
              key={name}
              variants={fadeInUp}
              className="w-32 h-32 md:w-36 md:h-36 rounded-full bg-white border border-cream-dark flex items-center justify-center shadow-sm"
            >
              <span className="text-xs text-center font-medium text-nature/60 px-3 leading-tight">
                {name}
              </span>
            </motion.div>
          ))}
        </div>
      </div>
    </Section>
  )
}

function FeaturesGrid() {
  const featureHighlights = features.slice(0, 8)
  return (
    <Section className="bg-white py-20">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <SectionTitle
          title="Powerful Features for Nature Learning"
          subtitle="Everything you need for structured, engaging, and accessible outdoor education."
        />
        <motion.div
          variants={staggerContainer}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          className="grid sm:grid-cols-2 lg:grid-cols-4 gap-6"
        >
          {featureHighlights.map((feature) => {
            const Icon = iconMap[feature.icon] || Leaf
            return (
              <motion.div
                key={feature.id}
                variants={fadeInUp}
                className="bg-cream rounded-2xl p-6 hover:shadow-lg transition-shadow border border-cream-dark group"
              >
                <div className="w-12 h-12 bg-nature/10 rounded-xl flex items-center justify-center mb-4 group-hover:bg-nature/20 transition-colors">
                  <Icon className="w-6 h-6 text-nature" />
                </div>
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
        <div className="text-center mt-10">
          <Link
            to="/features"
            className="inline-flex items-center gap-2 text-nature font-semibold hover:text-forest transition-colors"
          >
            View All Features <ArrowRight className="w-4 h-4" />
          </Link>
        </div>
      </div>
    </Section>
  )
}

function HowItWorks() {
  const steps = [
    {
      number: 1,
      title: 'Download the App',
      desc: 'Install Rompin Forest Explorer on your Android device from our download page.',
    },
    {
      number: 2,
      title: 'Choose an Activity',
      desc: 'Browse guided nature activities like walks, observation, and exploration.',
    },
    {
      number: 3,
      title: 'Follow & Explore',
      desc: 'Follow visual instructions, take photos, and complete checklists in the forest.',
    },
    {
      number: 4,
      title: 'Review & Learn',
      desc: 'Review saved observations, earn badges, and track progress over time.',
    },
  ]
  return (
    <Section className="bg-cream py-20">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <SectionTitle
          title="How It Works"
          subtitle="Four simple steps to start your nature learning journey."
        />
        <div className="relative">
          <div className="hidden md:block absolute top-12 left-[12%] right-[12%] h-0.5 bg-nature/20" />
          <motion.div
            variants={staggerContainer}
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true }}
            className="grid md:grid-cols-4 gap-8"
          >
            {steps.map((step) => (
              <motion.div
                key={step.number}
                variants={fadeInUp}
                className="relative text-center"
              >
                <div className="w-24 h-24 rounded-full bg-forest text-white flex items-center justify-center mx-auto mb-5 text-2xl font-bold shadow-lg relative z-10">
                  {step.number}
                </div>
                <h3 className="font-semibold text-forest-dark mb-2 text-lg">
                  {step.title}
                </h3>
                <p className="text-sm text-nature/70 max-w-xs mx-auto leading-relaxed">
                  {step.desc}
                </p>
              </motion.div>
            ))}
          </motion.div>
        </div>
      </div>
    </Section>
  )
}

function AutismFriendly() {
  const items = [
    'Short, clear visual instructions for every step',
    'Visual schedules showing activity timelines',
    'Large, easy-to-tap buttons and touch targets',
    'Calm, nature-inspired colour palette',
    'Predictable navigation and activity flows',
    'Consistent layout across all screens',
    'Reduced text with icon-based guidance',
    'Break reminders and pause options',
  ]
  return (
    <Section className="bg-forest py-20">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <SectionTitle
          light
          title="Designed with Autism in Mind"
          subtitle="Every detail of the app is crafted to support children with autism spectrum disorder."
        />
        <motion.div
          variants={staggerContainer}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          className="grid sm:grid-cols-2 gap-5 max-w-4xl mx-auto"
        >
          {items.map((item) => (
            <motion.div
              key={item}
              variants={fadeInUp}
              className="flex items-start gap-3 bg-white/10 backdrop-blur-sm rounded-xl px-5 py-4"
            >
              <div className="mt-0.5 w-6 h-6 rounded-full bg-nature-light/20 flex items-center justify-center shrink-0">
                <Check className="w-3.5 h-3.5 text-nature-light" />
              </div>
              <span className="text-white/90 text-sm leading-relaxed">
                {item}
              </span>
            </motion.div>
          ))}
        </motion.div>
      </div>
    </Section>
  )
}

function NatureActivities() {
  const featured = activities.slice(0, 3)
  return (
    <Section className="bg-white py-20">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <SectionTitle
          title="Nature Learning Activities"
          subtitle="Discover structured activities designed to make outdoor learning engaging and accessible."
        />
        <motion.div
          variants={staggerContainer}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          className="grid md:grid-cols-3 gap-8"
        >
          {featured.map((activity) => {
            const Icon = iconMap[activity.icon] || Leaf
            return (
              <motion.div
                key={activity.id}
                variants={fadeInUp}
                className="bg-cream rounded-2xl p-8 border border-cream-dark hover:shadow-lg transition-shadow group"
              >
                <div className="w-14 h-14 bg-nature/10 rounded-2xl flex items-center justify-center mb-5 group-hover:bg-nature/20 transition-colors">
                  <Icon className="w-7 h-7 text-nature" />
                </div>
                <h3 className="font-bold text-forest-dark text-lg mb-1">
                  {activity.title}
                </h3>
                <p className="text-sm text-nature/60 italic mb-3">
                  {activity.malayName}
                </p>
                <p className="text-sm text-nature/70 leading-relaxed mb-4">
                  {activity.objective}
                </p>
                <div className="flex items-center gap-4 text-xs text-nature/60">
                  <span className="flex items-center gap-1">
                    <BookOpen className="w-3.5 h-3.5" /> {activity.duration}
                  </span>
                  <span className="flex items-center gap-1">
                    <Users className="w-3.5 h-3.5" /> {activity.groupSize}
                  </span>
                </div>
              </motion.div>
            )
          })}
        </motion.div>
        <div className="text-center mt-10">
          <Link
            to="/activities"
            className="inline-flex items-center gap-2 text-nature font-semibold hover:text-forest transition-colors"
          >
            View All Activities <ArrowRight className="w-4 h-4" />
          </Link>
        </div>
      </div>
    </Section>
  )
}

function UserRoles() {
  const roles = [
    {
      icon: GraduationCap,
      title: 'Students',
      desc: 'Follow guided activities, take photos, complete checklists, and earn badges as you explore nature.',
      features: [
        'Visual activity instructions',
        'Photo capture & observation',
        'Progress tracking & badges',
        'Simple, intuitive navigation',
      ],
    },
    {
      icon: LayoutDashboard,
      title: 'Facilitators',
      desc: 'Manage activities, monitor student progress, review observations, and guide learning sessions.',
      features: [
        'Student progress dashboard',
        'Activity management tools',
        'Observation review panel',
        'Group session coordination',
      ],
    },
    {
      icon: Shield,
      title: 'Administrators',
      desc: 'Oversee user accounts, manage facilitators, and access comprehensive programme data.',
      features: [
        'User account management',
        'Facilitator assignment',
        'Programme analytics',
        'System configuration',
      ],
    },
  ]
  return (
    <Section className="bg-cream py-20">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <SectionTitle
          title="Built for Everyone"
          subtitle="Role-based interfaces designed to meet the needs of each user."
        />
        <motion.div
          variants={staggerContainer}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          className="grid md:grid-cols-3 gap-8"
        >
          {roles.map((role) => {
            const Icon = role.icon
            return (
              <motion.div
                key={role.title}
                variants={fadeInUp}
                className="bg-white rounded-2xl p-8 border border-cream-dark shadow-sm hover:shadow-lg transition-shadow"
              >
                <div className="w-14 h-14 bg-forest/10 rounded-2xl flex items-center justify-center mb-5">
                  <Icon className="w-7 h-7 text-forest" />
                </div>
                <h3 className="font-bold text-forest-dark text-lg mb-2">
                  {role.title}
                </h3>
                <p className="text-sm text-nature/70 leading-relaxed mb-5">
                  {role.desc}
                </p>
                <ul className="space-y-2.5">
                  {role.features.map((f) => (
                    <li
                      key={f}
                      className="flex items-start gap-2 text-sm text-nature/70"
                    >
                      <Check className="w-4 h-4 text-nature mt-0.5 shrink-0" />
                      {f}
                    </li>
                  ))}
                </ul>
              </motion.div>
            )
          })}
        </motion.div>
      </div>
    </Section>
  )
}

function AppScreenshots() {
  const screens = [
    { title: 'Student View', color: 'from-forest to-forest-light' },
    { title: 'Facilitator Dashboard', color: 'from-nature to-nature-light' },
    { title: 'Activity Screen', color: 'from-sky to-sky-light' },
  ]
  return (
    <Section className="bg-white py-20">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <SectionTitle
          title="See the App in Action"
          subtitle="Preview the clean, accessible interface designed for every user."
        />
        <motion.div
          variants={staggerContainer}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          className="grid md:grid-cols-3 gap-8"
        >
          {screens.map((screen) => (
            <motion.div key={screen.title} variants={fadeInUp} className="text-center">
              <div className="w-full max-w-[220px] mx-auto h-[400px] bg-white rounded-[2rem] border-4 border-gray-200 shadow-xl overflow-hidden mb-5">
                <div className={`h-full bg-gradient-to-b ${screen.color} flex flex-col items-center justify-center p-6`}>
                  <Leaf className="w-10 h-10 text-white/80 mb-3" />
                  <div className="space-y-2 w-full">
                    {[1, 2, 3].map((i) => (
                      <div
                        key={i}
                        className="h-8 bg-white/20 rounded-lg w-full"
                      />
                    ))}
                  </div>
                </div>
              </div>
              <h4 className="font-semibold text-forest-dark">{screen.title}</h4>
            </motion.div>
          ))}
        </motion.div>
      </div>
    </Section>
  )
}

function StudentBenefits() {
  const benefits = [
    { icon: Eye, title: 'Improved Observation', desc: 'Develop keen observation skills through guided nature activities.' },
    { icon: Camera, title: 'Creative Expression', desc: 'Express findings through photography and visual documentation.' },
    { icon: Award, title: 'Achievement Motivation', desc: 'Earn badges and recognition that encourage continued participation.' },
    { icon: Users, title: 'Social Connection', desc: 'Build social skills through collaborative group activities.' },
  ]
  return (
    <Section className="bg-cream py-20">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <SectionTitle
          title="Benefits for Students"
          subtitle="How Rompin Forest Explorer helps children grow through nature."
        />
        <motion.div
          variants={staggerContainer}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          className="grid sm:grid-cols-2 lg:grid-cols-4 gap-6"
        >
          {benefits.map((b) => {
            const Icon = b.icon
            return (
              <motion.div
                key={b.title}
                variants={fadeInUp}
                className="text-center bg-white rounded-2xl p-6 border border-cream-dark"
              >
                <div className="w-12 h-12 bg-nature/10 rounded-xl flex items-center justify-center mx-auto mb-4">
                  <Icon className="w-6 h-6 text-nature" />
                </div>
                <h4 className="font-semibold text-forest-dark mb-2">{b.title}</h4>
                <p className="text-sm text-nature/70 leading-relaxed">{b.desc}</p>
              </motion.div>
            )
          })}
        </motion.div>
      </div>
    </Section>
  )
}

function FacilitatorBenefits() {
  const benefits = [
    { icon: BarChart3, title: 'Progress Monitoring', desc: 'Track student participation and activity completion in real time.' },
    { icon: LayoutDashboard, title: 'Centralised Dashboard', desc: 'Manage all activities, students, and sessions from one interface.' },
    { icon: ClipboardCheck, title: 'Observation Reviews', desc: 'Review student observations, photos, and checklists efficiently.' },
    { icon: Heart, title: 'Tailored Support', desc: 'Provide individual support based on each student\'s progress and needs.' },
  ]
  return (
    <Section className="bg-white py-20">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <SectionTitle
          title="Benefits for Facilitators"
          subtitle="Tools and insights to support effective outdoor learning sessions."
        />
        <motion.div
          variants={staggerContainer}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          className="grid sm:grid-cols-2 lg:grid-cols-4 gap-6"
        >
          {benefits.map((b) => {
            const Icon = b.icon
            return (
              <motion.div
                key={b.title}
                variants={fadeInUp}
                className="text-center bg-cream rounded-2xl p-6 border border-cream-dark"
              >
                <div className="w-12 h-12 bg-forest/10 rounded-xl flex items-center justify-center mx-auto mb-4">
                  <Icon className="w-6 h-6 text-forest" />
                </div>
                <h4 className="font-semibold text-forest-dark mb-2">{b.title}</h4>
                <p className="text-sm text-nature/70 leading-relaxed">{b.desc}</p>
              </motion.div>
            )
          })}
        </motion.div>
      </div>
    </Section>
  )
}

function Testimonials() {
  const [current, setCurrent] = useState(0)
  const next = () => setCurrent((c) => (c + 1) % testimonials.length)
  const prev = () => setCurrent((c) => (c - 1 + testimonials.length) % testimonials.length)
  const t = testimonials[current]

  return (
    <Section className="bg-cream py-20">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <SectionTitle
          title="What People Are Saying"
          subtitle="Hear from educators, parents, and specialists who use Rompin Forest Explorer."
        />
        <div className="max-w-3xl mx-auto relative">
          <div className="bg-white rounded-2xl p-8 md:p-12 border border-cream-dark shadow-sm text-center">
            <div className="flex justify-center gap-1 mb-5">
              {Array.from({ length: t.rating }).map((_, i) => (
                <Star key={i} className="w-5 h-5 fill-sunset text-sunset" />
              ))}
            </div>
            <AnimatePresence mode="wait">
              <motion.div
                key={t.id}
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -10 }}
                transition={{ duration: 0.3 }}
              >
                <p className="text-lg text-forest-dark leading-relaxed mb-6 italic">
                  &ldquo;{t.text}&rdquo;
                </p>
                <div>
                  <p className="font-semibold text-forest-dark">{t.name}</p>
                  <p className="text-sm text-nature/60">{t.role}</p>
                </div>
              </motion.div>
            </AnimatePresence>
          </div>
          <div className="flex justify-center gap-3 mt-6">
            <button
              onClick={prev}
              className="w-10 h-10 rounded-full bg-white border border-cream-dark flex items-center justify-center hover:bg-cream transition-colors"
            >
              <ChevronLeft className="w-5 h-5 text-forest-dark" />
            </button>
            <button
              onClick={next}
              className="w-10 h-10 rounded-full bg-white border border-cream-dark flex items-center justify-center hover:bg-cream transition-colors"
            >
              <ChevronRight className="w-5 h-5 text-forest-dark" />
            </button>
          </div>
        </div>
      </div>
    </Section>
  )
}

function FAQ() {
  const faqs = [
    {
      q: 'What is Rompin Forest Explorer?',
      a: 'Rompin Forest Explorer is an autism-friendly mobile application designed to help children explore forests through structured, guided activities with visual instructions and facilitator support.',
    },
    {
      q: 'Is the app free to use?',
      a: 'Yes, Rompin Forest Explorer is completely free to download and use. There are no in-app purchases or subscription fees.',
    },
    {
      q: 'What devices are supported?',
      a: 'The app is currently available for Android devices running Android 8.0 (Oreo) or higher. iOS support is planned for a future release.',
    },
    {
      q: 'Does the app work offline?',
      a: 'Core features are designed to work with limited connectivity. The app syncs data to the cloud when an internet connection is available.',
    },
    {
      q: 'Who can use this app?',
      a: 'The app is designed for students, facilitators (teachers or parents), and administrators. Each role has a dedicated interface with appropriate features.',
    },
  ]
  const [openIndex, setOpenIndex] = useState(null)

  return (
    <Section className="bg-white py-20">
      <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
        <SectionTitle
          title="Frequently Asked Questions"
          subtitle="Find answers to common questions about Rompin Forest Explorer."
        />
        <motion.div
          variants={staggerContainer}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          className="space-y-3"
        >
          {faqs.map((faq, i) => (
            <motion.div
              key={i}
              variants={fadeInUp}
              className="bg-cream rounded-xl border border-cream-dark overflow-hidden"
            >
              <button
                onClick={() => setOpenIndex(openIndex === i ? null : i)}
                className="w-full flex items-center justify-between px-6 py-5 text-left"
              >
                <span className="font-semibold text-forest-dark pr-4">
                  {faq.q}
                </span>
                <ChevronDown
                  className={`w-5 h-5 text-nature shrink-0 transition-transform duration-200 ${
                    openIndex === i ? 'rotate-180' : ''
                  }`}
                />
              </button>
              <AnimatePresence>
                {openIndex === i && (
                  <motion.div
                    initial={{ height: 0, opacity: 0 }}
                    animate={{ height: 'auto', opacity: 1 }}
                    exit={{ height: 0, opacity: 0 }}
                    transition={{ duration: 0.2 }}
                  >
                    <div className="px-6 pb-5 text-sm text-nature/70 leading-relaxed border-t border-cream-dark pt-4">
                      {faq.a}
                    </div>
                  </motion.div>
                )}
              </AnimatePresence>
            </motion.div>
          ))}
        </motion.div>
      </div>
    </Section>
  )
}

function DownloadCTA() {
  return (
    <Section className="bg-gradient-to-br from-forest-dark via-forest to-nature py-20">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <motion.div variants={fadeInUp} initial="hidden" whileInView="visible" viewport={{ once: true }}>
          <h2 className="text-3xl md:text-4xl font-bold text-white mb-4">
            Start Exploring with Rompin Forest Explorer
          </h2>
          <p className="text-lg text-white/80 mb-8 max-w-2xl mx-auto">
            Download the app today and discover a new way to learn about nature.
            Designed for children with autism, supported by facilitators, and loved
            by families.
          </p>
          <Link
            to="/download"
            className="inline-flex items-center gap-2 bg-nature-light hover:bg-nature text-forest-dark font-semibold px-10 py-4 rounded-full transition-colors shadow-lg text-lg"
          >
            <Download className="w-5 h-5" />
            Download APK
          </Link>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4 max-w-2xl mx-auto mt-12">
            {[
              { label: 'Platform', value: 'Android' },
              { label: 'Version', value: '1.0.0' },
              { label: 'Price', value: 'Free' },
              { label: 'File', value: 'APK' },
            ].map((info) => (
              <div
                key={info.label}
                className="bg-white/10 backdrop-blur-sm rounded-xl px-5 py-4"
              >
                <p className="text-xs text-white/50 mb-1">{info.label}</p>
                <p className="font-semibold text-white">{info.value}</p>
              </div>
            ))}
          </div>
        </motion.div>
      </div>
    </Section>
  )
}

function Footer() {
  return (
    <footer className="bg-forest-dark text-white/70 py-16">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid md:grid-cols-4 gap-10 mb-12">
          <div>
            <div className="flex items-center gap-2 mb-4">
              <Leaf className="w-6 h-6 text-nature-light" />
              <span className="font-bold text-white text-lg">
                Rompin Forest Explorer
              </span>
            </div>
            <p className="text-sm leading-relaxed">
              An autism-friendly mobile application for structured nature learning
              in Rompin Forest, Malaysia.
            </p>
          </div>
          <div>
            <h4 className="font-semibold text-white mb-4">Quick Links</h4>
            <ul className="space-y-2 text-sm">
              {[
                { name: 'Home', path: '/' },
                { name: 'About', path: '/about' },
                { name: 'Features', path: '/features' },
                { name: 'Activities', path: '/activities' },
              ].map((l) => (
                <li key={l.path}>
                  <Link to={l.path} className="hover:text-nature-light transition-colors">
                    {l.name}
                  </Link>
                </li>
              ))}
            </ul>
          </div>
          <div>
            <h4 className="font-semibold text-white mb-4">Resources</h4>
            <ul className="space-y-2 text-sm">
              {[
                { name: 'Download', path: '/download' },
                { name: 'User Guide', path: '/user-guide' },
                { name: 'Support', path: '/support' },
                { name: 'Contact', path: '/contact' },
              ].map((l) => (
                <li key={l.path}>
                  <Link to={l.path} className="hover:text-nature-light transition-colors">
                    {l.name}
                  </Link>
                </li>
              ))}
            </ul>
          </div>
          <div>
            <h4 className="font-semibold text-white mb-4">Contact</h4>
            <ul className="space-y-3 text-sm">
              <li className="flex items-center gap-2">
                <Mail className="w-4 h-4" /> info@rompinforestexplorer.my
              </li>
              <li className="flex items-center gap-2">
                <Phone className="w-4 h-4" /> +60 3-1234 5678
              </li>
            </ul>
          </div>
        </div>
        <div className="border-t border-white/10 pt-8 text-center text-sm">
          <p>&copy; {new Date().getFullYear()} Rompin Forest Explorer. All rights reserved.</p>
        </div>
      </div>
    </footer>
  )
}

export default function Home() {
  return (
    <div>
      <HeroSection />
      <TrustedBy />
      <FeaturesGrid />
      <HowItWorks />
      <AutismFriendly />
      <NatureActivities />
      <UserRoles />
      <AppScreenshots />
      <StudentBenefits />
      <FacilitatorBenefits />
      <Testimonials />
      <FAQ />
      <DownloadCTA />
      <Footer />
    </div>
  )
}
