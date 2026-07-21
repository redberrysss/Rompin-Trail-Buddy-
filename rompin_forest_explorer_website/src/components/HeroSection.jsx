import { Link } from 'react-router-dom'
import { motion } from 'framer-motion'
import AppScreenshot from './AppScreenshot'

const fadeUp = {
  hidden: { opacity: 0, y: 30 },
  visible: (i = 0) => ({
    opacity: 1,
    y: 0,
    transition: { delay: i * 0.15, duration: 0.6, ease: 'easeOut' },
  }),
}

export default function HeroSection({
  title = 'Explore the Wonders of Rompin Forest',
  subtitle = 'An interactive outdoor education platform for Malaysian schools. Discover biodiversity, conduct field activities, and learn about conservation.',
  primaryButtonText = 'Download Android App',
  primaryButtonLink = '/download',
  secondaryButtonText = 'Explore Features',
  secondaryButtonLink = '/features',
  showPhoneMockup = true,
}) {
  return (
    <section className="relative overflow-hidden bg-gradient-to-br from-forest-green to-nature-green">
      <div className="absolute inset-0 opacity-10">
        <div className="absolute top-20 left-10 w-72 h-72 bg-white/20 rounded-full blur-3xl" />
        <div className="absolute bottom-10 right-20 w-96 h-96 bg-white/10 rounded-full blur-3xl" />
      </div>

      <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20 lg:py-28">
        <div className={`grid ${showPhoneMockup ? 'lg:grid-cols-2' : ''} gap-12 lg:gap-16 items-center`}>
          <div className="space-y-8">
            <motion.h1
              variants={fadeUp}
              initial="hidden"
              animate="visible"
              custom={0}
              className="text-4xl sm:text-5xl lg:text-6xl font-bold text-white leading-tight"
            >
              {title}
            </motion.h1>

            <motion.p
              variants={fadeUp}
              initial="hidden"
              animate="visible"
              custom={1}
              className="text-lg sm:text-xl text-white/85 max-w-xl leading-relaxed"
            >
              {subtitle}
            </motion.p>

            <motion.div
              variants={fadeUp}
              initial="hidden"
              animate="visible"
              custom={2}
              className="flex flex-col sm:flex-row gap-4"
            >
              <Link
                to={primaryButtonLink}
                className="inline-flex items-center justify-center px-8 py-4 bg-white text-forest-green font-bold text-base rounded-full hover:bg-cream transition-colors duration-200 shadow-lg hover:shadow-xl"
              >
                {primaryButtonText}
              </Link>
              <Link
                to={secondaryButtonLink}
                className="inline-flex items-center justify-center px-8 py-4 border-2 border-white text-white font-semibold text-base rounded-full hover:bg-white/10 transition-colors duration-200"
              >
                {secondaryButtonText}
              </Link>
            </motion.div>
          </div>

          {showPhoneMockup && (
            <motion.div
              variants={fadeUp}
              initial="hidden"
              animate="visible"
              custom={3}
              className="flex justify-center lg:justify-end"
            >
              <AppScreenshot title="App Screenshot" />
            </motion.div>
          )}
        </div>
      </div>
    </section>
  )
}
