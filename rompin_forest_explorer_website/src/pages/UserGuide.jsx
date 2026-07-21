import { useState } from 'react'
import { Link } from 'react-router-dom'
import { motion } from 'framer-motion'
import {
  UserPlus, LogIn, Users, GraduationCap, ClipboardList, Camera,
  Eye, MapPin, ChevronDown, ChevronRight,
  FileText, Shield, Download, HelpCircle,
} from 'lucide-react'
import PageHeader from '../components/PageHeader'

const guideSections = [
  {
    id: 1,
    icon: UserPlus,
    title: 'Creating an Account',
    steps: [
      'Open the Rompin Forest Explorer app on your device.',
      'On the welcome screen, tap "Create Account" to begin registration.',
      'Select your role: Student, Facilitator, or Administrator.',
      'Enter your details including full name, email address, and a secure password.',
      'Verify your email address by clicking the confirmation link sent to your inbox.',
      'Complete your profile by adding any additional required information such as your school or organization.',
    ],
  },
  {
    id: 2,
    icon: LogIn,
    title: 'Logging In',
    steps: [
      'Open the Rompin Forest Explorer app on your device.',
      'Enter your registered email address in the email field.',
      'Enter your password in the password field.',
      'Tap the "Log In" button to proceed.',
      'Select your role if prompted, then you will be directed to your role-specific dashboard.',
    ],
  },
  {
    id: 3,
    icon: Users,
    title: 'Selecting Your Role',
    steps: [
      'Student: View and participate in activities, take photographs, record observations, and track your personal progress and badges.',
      'Facilitator: Access a dedicated dashboard to manage assigned students, create and organize activities, monitor student progress, and review observations.',
      'Administrator: Manage the entire system including user accounts, activity templates, system settings, and generate reports for your organization.',
    ],
  },
  {
    id: 4,
    icon: GraduationCap,
    title: 'Using the Student Interface',
    steps: [
      'From the home screen, browse the list of available activities assigned to you.',
      'Select an activity to view its details, including visual instructions and objectives.',
      'Follow the visual step-by-step instructions provided within each activity.',
      'Use the built-in camera to take photographs as part of the activity requirements.',
      'Record your observations by selecting items from the checklist or typing notes.',
      'Save your progress at any time by tapping the save button to ensure your work is stored.',
    ],
  },
  {
    id: 5,
    icon: ClipboardList,
    title: 'Using the Facilitator Interface',
    steps: [
      'Access your facilitator dashboard upon login to see an overview of your group.',
      'View the list of students assigned to you along with their current activity status.',
      'Create new activities by selecting from predefined templates or customizing your own.',
      'Manage existing activities by editing instructions, adding or removing steps, and setting deadlines.',
      'Monitor student progress in real-time through the activity completion tracker.',
      'Review student observations and photographs submitted during activities.',
      'Confirm activity completions and provide feedback to students.',
    ],
  },
  {
    id: 6,
    icon: MapPin,
    title: 'Starting an Activity',
    steps: [
      'Browse the activities library to find an activity suitable for your group.',
      'Select an activity to view its full details, objectives, and required materials.',
      'Read through all instructions carefully before beginning to ensure proper preparation.',
      'Prepare the necessary materials and equipment listed in the activity requirements.',
      'Begin the activity with your group, following each step as guided by the app.',
    ],
  },
  {
    id: 7,
    icon: Camera,
    title: 'Taking a Photograph',
    steps: [
      'During an activity, tap the camera icon to open the built-in camera feature.',
      'Frame your subject within the viewfinder, ensuring it is clearly visible.',
      'Tap the capture button to take the photograph.',
      'Review the captured photo to ensure it meets your expectations.',
      'Save the photo to attach it to your current observation entry.',
    ],
  },
  {
    id: 8,
    icon: FileText,
    title: 'Saving an Observation',
    steps: [
      'Complete the required activity steps that correspond to the observation.',
      'Add detailed notes and attach relevant photographs to your observation entry.',
      'Review your observation entry for completeness and accuracy.',
      'Tap the "Save" button to store your observation locally on the device.',
      'When an internet connection is available, your observation will automatically sync to the cloud.',
    ],
  },
  {
    id: 9,
    icon: Eye,
    title: 'Viewing Progress',
    steps: [
      'Navigate to the Progress section from the main menu or dashboard.',
      'View a summary of all completed activities and their status.',
      'Check the badges you have earned for completing various activities and milestones.',
      'Review your full observation history including photographs and notes.',
      'Track your overall participation and achievements over time.',
    ],
  },
  {
    id: 10,
    icon: Shield,
    title: 'Logging Out',
    steps: [
      'Tap on your profile icon located in the top corner of the screen.',
      'Select "Log Out" from the profile menu options.',
      'Confirm your action when prompted to ensure you want to log out.',
      'You will be returned to the login screen.',
    ],
  },
]

const troubleshootingFaqs = [
  {
    question: 'I forgot my password. How do I reset it?',
    answer: 'On the login screen, tap "Forgot Password" below the password field. Enter your registered email address and check your inbox for a password reset link. Follow the instructions in the email to create a new password. If you do not receive the email within a few minutes, check your spam or junk folder.',
  },
  {
    question: 'My account is locked. What should I do?',
    answer: 'Your account may be locked after multiple failed login attempts for security reasons. Please wait 15 minutes and try again, or contact our support team at support@rompinforestexplorer.com with your registered email address for assistance in unlocking your account.',
  },
  {
    question: 'I did not receive the email verification link. What can I do?',
    answer: 'Check your spam or junk folder first. If the email is not there, go back to the login screen and tap "Resend Verification Email." Make sure you are using the correct email address. If the problem persists, contact support with your registration details.',
  },
  {
    question: 'The app version I have seems outdated. How do I update?',
    answer: 'Visit the Google Play Store on your device, search for "Rompin Forest Explorer," and tap "Update" if an update is available. We recommend keeping the app updated to the latest version for access to new features, improvements, and bug fixes.',
  },
]

const containerVariants = {
  hidden: {},
  visible: {
    transition: { staggerChildren: 0.1 },
  },
}

const itemVariants = {
  hidden: { opacity: 0, y: 30 },
  visible: { opacity: 1, y: 0, transition: { duration: 0.5 } },
}

export default function UserGuide() {
  const [openFaq, setOpenFaq] = useState(null)

  return (
    <div>
      <PageHeader
        title="User Guide"
        subtitle="Learn how to use Rompin Forest Explorer step by step"
      />

      <section className="py-16 lg:py-20">
        <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
          <motion.div
            variants={containerVariants}
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true, margin: '-50px' }}
            className="space-y-8"
          >
            {guideSections.map((section, index) => {
              const Icon = section.icon
              return (
                <motion.div
                  key={section.id}
                  variants={itemVariants}
                  className="bg-white rounded-2xl p-6 lg:p-8 shadow-md border border-nature-light/20"
                >
                  <div className="flex flex-col sm:flex-row gap-5 sm:gap-6">
                    <div className="flex-shrink-0">
                      <div className="w-14 h-14 rounded-full bg-nature-light/20 flex items-center justify-center">
                        <Icon className="w-7 h-7 text-forest-green" />
                      </div>
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-3 mb-4">
                        <span className="flex-shrink-0 w-8 h-8 rounded-full bg-forest-green text-white text-sm font-bold flex items-center justify-center">
                          {index + 1}
                        </span>
                        <h3 className="text-xl lg:text-2xl font-bold text-forest-green">
                          {section.title}
                        </h3>
                      </div>
                      <ol className="space-y-3">
                        {section.steps.map((step, stepIdx) => (
                          <li
                            key={stepIdx}
                            className="flex gap-3 text-earth-brown/80 leading-relaxed"
                          >
                            <ChevronRight className="w-4 h-4 mt-1.5 flex-shrink-0 text-nature" />
                            <span>{step}</span>
                          </li>
                        ))}
                      </ol>
                    </div>
                  </div>
                </motion.div>
              )
            })}
          </motion.div>
        </div>
      </section>

      <section className="py-16 lg:py-20 bg-white">
        <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5 }}
            className="text-center mb-12"
          >
            <div className="w-14 h-14 rounded-full bg-nature-light/20 flex items-center justify-center mx-auto mb-5">
              <HelpCircle className="w-7 h-7 text-forest-green" />
            </div>
            <h2 className="text-3xl sm:text-4xl font-bold text-forest-green mb-4">
              Troubleshooting Login Issues
            </h2>
            <div className="w-20 h-1 bg-nature-green mx-auto rounded-full" />
          </motion.div>

          <div className="space-y-4">
            {troubleshootingFaqs.map((faq, index) => (
              <motion.div
                key={index}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ delay: index * 0.05, duration: 0.4 }}
                className="border border-nature-light/30 rounded-xl overflow-hidden"
              >
                <button
                  onClick={() => setOpenFaq(openFaq === index ? null : index)}
                  className="w-full flex items-center justify-between px-6 py-4 text-left bg-cream/50 hover:bg-cream transition-colors duration-200"
                  aria-expanded={openFaq === index}
                >
                  <span className="font-semibold text-forest-green pr-4">
                    {faq.question}
                  </span>
                  <ChevronDown
                    className={`w-5 h-5 text-earth-brown/60 flex-shrink-0 transition-transform duration-200 ${
                      openFaq === index ? 'rotate-180' : ''
                    }`}
                  />
                </button>
                {openFaq === index && (
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

          <motion.div
            initial={{ opacity: 0 }}
            whileInView={{ opacity: 1 }}
            viewport={{ once: true }}
            className="mt-10 text-center"
          >
            <p className="text-earth-brown/70 mb-4">
              Still having trouble? Our support team is here to help.
            </p>
            <Link
              to="/support"
              className="inline-flex items-center gap-2 px-6 py-3 bg-forest-green text-white font-semibold rounded-full hover:bg-nature-green transition-colors duration-200"
            >
              <Download className="w-4 h-4" />
              Contact Support
            </Link>
          </motion.div>
        </div>
      </section>
    </div>
  )
}
