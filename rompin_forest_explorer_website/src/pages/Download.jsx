import { motion } from 'framer-motion'
import { Link } from 'react-router-dom'
import {
  Leaf,
  Download as DownloadIcon,
  Shield,
  Smartphone,
  Check,
  HelpCircle,
  ChevronRight,
  Info,
  Lock,
  Camera,
  Monitor,
  HardDrive,
  Calendar,
} from 'lucide-react'

const fadeInUp = {
  hidden: { opacity: 0, y: 30 },
  visible: { opacity: 1, y: 0, transition: { duration: 0.6, ease: 'easeOut' } },
}

const staggerContainer = {
  hidden: {},
  visible: { transition: { staggerChildren: 0.1 } },
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

function Section({ children, className = '' }) {
  return (
    <motion.section
      initial="hidden"
      whileInView="visible"
      viewport={{ once: true, margin: '-50px' }}
      variants={{ hidden: { opacity: 0 }, visible: { opacity: 1, transition: { duration: 0.5 } } }}
      className={className}
    >
      {children}
    </motion.section>
  )
}

export default function Download() {
  const installationSteps = [
    { step: 1, title: 'Download the APK', desc: 'Tap the download button below to save the APK file to your Android device.' },
    { step: 2, title: 'Open the Downloaded File', desc: 'Navigate to your Downloads folder or pull down the notification shade and tap the completed download.' },
    { step: 3, title: 'Allow Installation', desc: 'If prompted, go to Settings and allow installation from your browser or file manager. This is a standard Android security step.' },
    { step: 4, title: 'Install the App', desc: 'Tap "Install" on the installation screen and wait for the process to complete. This usually takes less than a minute.' },
    { step: 5, title: 'Open Rompin Forest Explorer', desc: 'Tap "Open" once installation is complete, or find the app icon on your home screen or app drawer.' },
    { step: 6, title: 'Register or Log In', desc: 'Create a new account or log in with your existing credentials. Facilitators and administrators will need to be registered by a programme coordinator.' },
  ]

  const versionChanges = [
    'Initial release of Rompin Forest Explorer',
    'Nature Walk guided activity with step-by-step instructions',
    'Animal Observation activity with identification cards',
    'Plant Observation activity with visual prompts',
    'Photo capture and observation gallery',
    'Facilitator dashboard with student progress tracking',
    'Administrator panel for user and programme management',
    'Firebase cloud storage for observations and images',
    'Role-based login system for students, facilitators, and administrators',
    'Activity badges and achievement system',
    'Visual schedules and autism-friendly navigation',
  ]

  const troubleshooting = [
    {
      title: 'Installation Blocked',
      desc: 'If Android blocks the installation, go to Settings > Security (or Apps) > Special Access > Install Unknown Apps, and allow your browser or file manager to install apps. Then retry the installation.',
    },
    {
      title: 'App Not Opening',
      desc: 'Ensure your device is running Android 8.0 or higher. If the app crashes on launch, try restarting your device and opening the app again. If the issue persists, uninstall and reinstall the APK.',
    },
    {
      title: 'Login Issues',
      desc: 'Verify that you are using the correct email and password. If you have forgotten your password, use the "Forgot Password" option on the login screen to reset it via email. Contact your facilitator if your account has not been set up.',
    },
    {
      title: 'Camera Not Working',
      desc: 'Ensure the app has camera permissions enabled. Go to Settings > Apps > Rompin Forest Explorer > Permissions > Camera, and make sure it is set to "Allow". You may need to restart the app after changing permissions.',
    },
  ]

  const systemRequirements = [
    { icon: Smartphone, label: 'Operating System', value: 'Android 8.0 (Oreo) or higher' },
    { icon: HardDrive, label: 'Storage', value: 'At least 100 MB free space' },
    { icon: Monitor, label: 'Display', value: '720p or higher resolution recommended' },
    { icon: Camera, label: 'Camera', value: 'Required for photo capture activities' },
    { icon: Lock, label: 'Internet', value: 'Required for initial login; core features work offline' },
  ]

  return (
    <div>
      <PageHeader
        title="Download Rompin Forest Explorer"
        subtitle="Get the app and start your nature exploration journey"
      />

      <Section className="bg-white py-20">
        <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
          <motion.div
            variants={fadeInUp}
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true }}
            className="bg-cream rounded-3xl p-8 md:p-12 border border-cream-dark shadow-sm"
          >
            <div className="flex flex-col md:flex-row items-center gap-8">
              <div className="shrink-0">
                <div className="w-28 h-28 bg-forest rounded-3xl flex items-center justify-center shadow-lg">
                  <Leaf className="w-14 h-14 text-white" />
                </div>
              </div>
              <div className="flex-1 text-center md:text-left">
                <h2 className="text-2xl font-bold text-forest-dark mb-1">
                  Rompin Forest Explorer
                </h2>
                <p className="text-sm text-nature/60 mb-4">
                  Autism-Friendly Nature Learning App
                </p>
                <div className="flex flex-wrap justify-center md:justify-start gap-3 text-xs text-nature/60 mb-6">
                  <span className="bg-white px-3 py-1 rounded-full border border-cream-dark">
                    Version 1.0.0
                  </span>
                  <span className="bg-white px-3 py-1 rounded-full border border-cream-dark">
                    ~25 MB
                  </span>
                  <span className="bg-white px-3 py-1 rounded-full border border-cream-dark">
                    Android 8.0+
                  </span>
                  <span className="bg-white px-3 py-1 rounded-full border border-cream-dark flex items-center gap-1">
                    <Calendar className="w-3 h-3" /> Released Jul 2026
                  </span>
                </div>
                <a
                  href="/downloads/rompin-forest-explorer.apk"
                  download
                  className="inline-flex items-center gap-2 bg-forest hover:bg-forest-dark text-white font-semibold px-8 py-3.5 rounded-full transition-colors shadow-lg"
                >
                  <DownloadIcon className="w-5 h-5" /> Download APK
                </a>
              </div>
              <div className="shrink-0">
                <div className="w-32 h-32 bg-white rounded-xl border border-cream-dark flex items-center justify-center">
                  <div className="text-center">
                    <div className="w-20 h-20 bg-cream rounded-lg flex items-center justify-center mx-auto mb-1">
                      <span className="text-xs font-medium text-nature/50">QR Code</span>
                    </div>
                    <p className="text-[10px] text-nature/40">Scan to download</p>
                  </div>
                </div>
              </div>
            </div>
          </motion.div>
        </div>
      </Section>

      <Section className="bg-cream py-20">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-3xl mx-auto mb-12">
            <h2 className="text-3xl md:text-4xl font-bold text-forest-dark mb-4">
              Installation Guide
            </h2>
            <p className="text-lg text-nature/80">
              Follow these simple steps to install Rompin Forest Explorer on your Android device.
            </p>
          </div>
          <div className="space-y-4">
            {installationSteps.map((item) => (
              <motion.div
                key={item.step}
                variants={fadeInUp}
                initial="hidden"
                whileInView="visible"
                viewport={{ once: true }}
                className="flex items-start gap-5 bg-white rounded-2xl p-6 border border-cream-dark"
              >
                <div className="w-10 h-10 rounded-full bg-forest text-white flex items-center justify-center shrink-0 text-sm font-bold">
                  {item.step}
                </div>
                <div>
                  <h3 className="font-semibold text-forest-dark mb-1">{item.title}</h3>
                  <p className="text-sm text-nature/70 leading-relaxed">{item.desc}</p>
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      </Section>

      <Section className="bg-white py-20">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-start gap-4 bg-amber-50 border border-amber-200 rounded-2xl p-6 md:p-8">
            <Shield className="w-8 h-8 text-amber-600 shrink-0 mt-1" />
            <div>
              <h3 className="font-bold text-amber-900 text-lg mb-2">Security Notice</h3>
              <div className="space-y-3 text-sm text-amber-800/80 leading-relaxed">
                <p>
                  Rompin Forest Explorer is distributed as an APK file directly from our website.
                  Android may warn you about installing apps from outside the Google Play Store.
                  This is a standard security measure.
                </p>
                <p>
                  The APK file is digitally signed and verified. Always download the app from this
                  official page to ensure you are getting an authentic, unmodified version. The app
                  does not contain any advertisements, in-app purchases, or third-party tracking.
                </p>
                <p>
                  User data is securely stored using Firebase cloud services with industry-standard
                  encryption. The app only requests permissions necessary for its core functionality
                  (camera for photo capture).
                </p>
              </div>
            </div>
          </div>
        </div>
      </Section>

      <Section className="bg-cream py-20">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-3xl mx-auto mb-12">
            <h2 className="text-3xl md:text-4xl font-bold text-forest-dark mb-4">
              Version 1.0.0 Release Notes
            </h2>
            <p className="text-lg text-nature/80">
              The initial release of Rompin Forest Explorer brings all core features to life.
            </p>
          </div>
          <motion.div
            variants={staggerContainer}
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true }}
            className="bg-white rounded-2xl p-8 border border-cream-dark"
          >
            <div className="flex items-center gap-3 mb-6">
              <span className="bg-forest text-white text-xs font-bold px-3 py-1 rounded-full">
                v1.0.0
              </span>
              <span className="text-sm text-nature/50">Initial Release</span>
            </div>
            <ul className="space-y-3">
              {versionChanges.map((change, i) => (
                <motion.li
                  key={i}
                  variants={fadeInUp}
                  className="flex items-start gap-3 text-sm text-nature/80"
                >
                  <Check className="w-4 h-4 text-nature mt-0.5 shrink-0" />
                  {change}
                </motion.li>
              ))}
            </ul>
          </motion.div>
        </div>
      </Section>

      <Section className="bg-white py-20">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-3xl mx-auto mb-12">
            <h2 className="text-3xl md:text-4xl font-bold text-forest-dark mb-4">
              Troubleshooting
            </h2>
            <p className="text-lg text-nature/80">
              Common issues and how to resolve them quickly.
            </p>
          </div>
          <motion.div
            variants={staggerContainer}
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true }}
            className="space-y-4"
          >
            {troubleshooting.map((item) => (
              <motion.div
                key={item.title}
                variants={fadeInUp}
                className="bg-cream rounded-2xl p-6 border border-cream-dark"
              >
                <h3 className="font-semibold text-forest-dark mb-2 flex items-center gap-2">
                  <HelpCircle className="w-5 h-5 text-nature" /> {item.title}
                </h3>
                <p className="text-sm text-nature/70 leading-relaxed">{item.desc}</p>
              </motion.div>
            ))}
          </motion.div>
        </div>
      </Section>

      <Section className="bg-cream py-20">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-3xl mx-auto mb-12">
            <h2 className="text-3xl md:text-4xl font-bold text-forest-dark mb-4">
              System Requirements
            </h2>
            <p className="text-lg text-nature/80">
              Ensure your device meets these requirements for the best experience.
            </p>
          </div>
          <motion.div
            variants={staggerContainer}
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true }}
            className="grid sm:grid-cols-2 lg:grid-cols-3 gap-4"
          >
            {systemRequirements.map((req) => {
              const Icon = req.icon
              return (
                <motion.div
                  key={req.label}
                  variants={fadeInUp}
                  className="bg-white rounded-xl p-5 border border-cream-dark flex items-start gap-4"
                >
                  <div className="w-10 h-10 bg-nature/10 rounded-xl flex items-center justify-center shrink-0">
                    <Icon className="w-5 h-5 text-nature" />
                  </div>
                  <div>
                    <p className="font-semibold text-forest-dark text-sm mb-0.5">
                      {req.label}
                    </p>
                    <p className="text-xs text-nature/60">{req.value}</p>
                  </div>
                </motion.div>
              )
            })}
          </motion.div>

          <motion.div
            variants={fadeInUp}
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true }}
            className="mt-8 bg-sky/5 border border-sky/20 rounded-xl p-5 flex items-start gap-3"
          >
            <Info className="w-5 h-5 text-sky shrink-0 mt-0.5" />
            <div className="text-sm text-nature/70">
              <p className="font-semibold text-forest-dark mb-1">Android Only</p>
              <p>
                Rompin Forest Explorer is currently available exclusively for Android devices.
                iOS support is planned for a future release. We recommend using a device with at
                least 3 GB of RAM for the smoothest experience.
              </p>
            </div>
          </motion.div>
        </div>
      </Section>

      <section className="bg-forest py-20">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <motion.div initial="hidden" whileInView="visible" viewport={{ once: true }} variants={fadeInUp}>
            <h2 className="text-3xl font-bold text-white mb-4">
              Need Help?
            </h2>
            <p className="text-lg text-white/70 mb-8">
              If you encounter any issues during download or installation, our support team is here to help.
            </p>
            <div className="flex flex-wrap justify-center gap-4">
              <Link
                to="/support"
                className="inline-flex items-center gap-2 bg-white/10 hover:bg-white/20 text-white font-semibold px-8 py-3.5 rounded-full transition-colors border border-white/10"
              >
                <HelpCircle className="w-5 h-5" /> Visit Support
              </Link>
              <Link
                to="/contact"
                className="inline-flex items-center gap-2 bg-nature-light hover:bg-nature text-forest-dark font-semibold px-8 py-3.5 rounded-full transition-colors"
              >
                Contact Us <ChevronRight className="w-5 h-5" />
              </Link>
            </div>
          </motion.div>
        </div>
      </section>
    </div>
  )
}
