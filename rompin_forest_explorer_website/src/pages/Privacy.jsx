import { motion } from 'framer-motion'
import { Shield, Lock, Eye, Database, Users, FileText, AlertCircle, Camera } from 'lucide-react'
import PageHeader from '../components/PageHeader'

const sections = [
  {
    icon: FileText,
    title: '1. Introduction',
    content: `Rompin Forest Explorer ("we," "our," or "us") is committed to protecting the privacy and security of all users, including children, parents, guardians, facilitators, and administrators. This Privacy Policy explains how we collect, use, store, and protect your personal information when you use our mobile application and related services. By using Rompin Forest Explorer, you agree to the practices described in this policy.`,
  },
  {
    icon: Eye,
    title: '2. Information We Collect',
    content: `We collect the following categories of information to provide and improve our services:

Account Information: When you create an account, we collect your full name, email address, and role (Student, Facilitator, or Administrator). For student accounts created by facilitators, we may collect limited information provided by the supervising adult.

Activity Data: We store records of activities you participate in, including completed steps, progress tracking, earned badges, and observation entries you submit.

Photos and Media: Photographs taken during activities using the in-app camera are stored securely. These photos are used solely for educational and observational purposes within the app.

Device Information: We may collect device type, operating system version, and app version to ensure compatibility and improve performance.

Usage Data: We collect anonymized usage analytics including features accessed, session duration, and navigation patterns to help us improve the app experience.`,
  },
  {
    icon: Users,
    title: '3. How We Use Information',
    content: `We use the information we collect for the following purposes:

Provide Services: To deliver activity content, track progress, manage observations, and enable communication between students, facilitators, and administrators.

Improve Experience: To analyze usage patterns and improve the app's design, functionality, and educational content.

Communicate with Users: To send important updates about your account, activity completions, and system notifications. We may also send newsletters with your consent.

Ensure Safety: To maintain a safe environment for all users, particularly children, by enforcing our terms of use and detecting misuse.

Generate Reports: To provide facilitators and administrators with aggregate reports on activity completion, student progress, and program outcomes.`,
  },
  {
    icon: Camera,
    title: '4. Photo and Camera Permissions',
    content: `The camera feature in Rompin Forest Explorer is used exclusively during educational activities to capture photographs of nature observations.

Camera Access: The app requests camera permission only when you choose to take a photograph during an activity. We do not access the camera at any other time.

Photo Storage: All photographs are stored securely using encrypted cloud storage services. Photos are associated with your observation entries and are accessible only to you, your assigned facilitators, and authorized administrators.

Photo Sharing: We do not share your photographs with any third parties without your explicit consent. Photos are not published publicly or used for marketing purposes.

Photo Retention: Photographs are retained as part of your observation records for as long as your account is active. You may request deletion of your photos at any time.`,
  },
  {
    icon: Database,
    title: '5. Data Storage',
    content: `We use Firebase services provided by Google to store and manage your data securely.

Cloud Storage: All user data, including account information, activity records, observations, and photographs, is stored on Firebase Cloud servers using industry-standard encryption.

Encryption in Transit: All data transmitted between your device and our servers is encrypted using TLS (Transport Layer Security) protocols.

Encryption at Rest: Data stored on our servers is encrypted at rest using AES-256 encryption, one of the strongest encryption standards available.

Data Location: Data is stored in secure data centers managed by Google Cloud, with multiple redundancies to prevent data loss.

Local Storage: Some data may be cached locally on your device for offline functionality. This data is automatically synced with our servers when an internet connection is available.`,
  },
  {
    icon: Shield,
    title: "6. Children's Privacy",
    content: `We take children's privacy seriously and comply with applicable laws regarding the protection of children's personal information.

COPPA Compliance: We adhere to the Children's Online Privacy Protection Act (COPPA) and similar regulations that protect children's privacy online.

Parental Consent: For children under 13 years of age, verifiable parental or guardian consent is required before an account can be created. Facilitators are responsible for obtaining necessary consent from parents or guardians.

Limited Data Collection: We collect only the minimum amount of personal information necessary for children to participate in activities. We do not collect location data, social media information, or any other unnecessary personal data from children.

No Behavioral Advertising: We do not serve targeted advertisements to children or use children's data for advertising purposes.`,
  },
  {
    icon: Users,
    title: '7. Parent and Guardian Supervision',
    content: `We encourage parents and guardians to be actively involved in their children's use of the Rompin Forest Explorer app.

Active Supervision: Parents and guardians should supervise their children's use of the app, including reviewing activities, observations, and photographs.

Account Access: Parents and guardians may request access to their child's account data at any time by contacting our support team.

Data Deletion: Parents and guardians have the right to request the deletion of their child's personal data. We will process such requests within 30 days.

Communication: Parents and guardians may contact us at any time with questions or concerns about their child's privacy or data usage.`,
  },
  {
    icon: Lock,
    title: '8. Data Security',
    content: `We implement industry-standard security measures to protect your personal information.

Access Controls: Access to user data is restricted to authorized personnel only, with strict role-based access controls in place.

Regular Reviews: We conduct regular security reviews and audits of our systems and infrastructure to identify and address potential vulnerabilities.

Incident Response: In the unlikely event of a data breach, we will notify affected users and relevant authorities promptly in accordance with applicable laws.

Secure Authentication: User accounts are protected with secure password hashing and optional multi-factor authentication for administrative accounts.`,
  },
  {
    icon: Database,
    title: '9. Data Retention',
    content: `We retain your personal information for as long as your account is active or as needed to provide our services.

Active Accounts: All data associated with active accounts, including activity records, observations, and photographs, is retained indefinitely to maintain your history and progress.

Account Deletion: When you request account deletion, we will remove all your personal data from our active systems within 30 days. Some data may be retained in backup systems for up to 90 days for disaster recovery purposes.

Aggregated Data: We may retain anonymized, aggregated data that cannot be used to identify individual users for research and analytics purposes.

Legal Requirements: We may retain certain data if required by applicable laws or regulations.`,
  },
  {
    icon: Users,
    title: '10. User Rights',
    content: `You have the following rights regarding your personal data:

Access: You may request a copy of all personal data we hold about you. We will provide this information within 30 days of your request.

Correction: You may request that we correct any inaccurate personal data associated with your account.

Deletion: You may request the deletion of your personal data at any time. We will process your request within 30 days.

Data Portability: You may request your data in a structured, commonly used, and machine-readable format for transfer to another service.

Withdraw Consent: You may withdraw your consent for data processing at any time by contacting us. Note that withdrawal of consent may affect your ability to use certain features of the app.

To exercise any of these rights, please contact us at privacy@rompinforestexplorer.com.`,
  },
  {
    icon: Shield,
    title: '11. Third-Party Services',
    content: `We use the following third-party services to operate and improve Rompin Forest Explorer:

Firebase (Google): We use Firebase for authentication, cloud storage, analytics, and messaging. Firebase's privacy policy can be found at https://firebase.google.com/support/privacy.

Analytics Providers: We may use anonymized analytics tools to understand how the app is used and to improve the user experience. These tools do not collect personally identifiable information.

No Data Selling: We do not sell, rent, or trade your personal information to any third parties for marketing or advertising purposes.

Service Providers: We may share data with trusted service providers who assist us in operating the app, subject to strict data protection agreements.`,
  },
  {
    icon: FileText,
    title: '12. Contact Information',
    content: `If you have any questions, concerns, or requests regarding this Privacy Policy or our data practices, please contact us:

Email: privacy@rompinforestexplorer.com
Phone: +60-12-345-6789
Address: Rompin, Pahang, Malaysia

We will respond to all privacy-related inquiries within 5 business days.`,
  },
  {
    icon: AlertCircle,
    title: '13. Policy Updates',
    content: `We may update this Privacy Policy from time to time to reflect changes in our practices, technology, legal requirements, or other factors.

Notification of Changes: When we make material changes to this policy, we will notify you through the app, via email, or by other appropriate means.

Review: We encourage you to review this policy periodically to stay informed about how we protect your information.

Continued Use: Your continued use of Rompin Forest Explorer after any changes to this policy constitutes your acceptance of the updated terms.`,
  },
]

const containerVariants = {
  hidden: {},
  visible: { transition: { staggerChildren: 0.08 } },
}

const itemVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0, transition: { duration: 0.4 } },
}

export default function Privacy() {
  return (
    <div>
      <PageHeader
        title="Privacy Policy"
        subtitle="Your privacy is important to us"
      />

      <section className="py-16 lg:py-20">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
            className="text-center mb-12"
          >
            <p className="text-earth-brown/60 text-sm">
              Last updated: January 2026
            </p>
          </motion.div>

          <motion.div
            variants={containerVariants}
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true, margin: '-50px' }}
            className="space-y-6"
          >
            {sections.map((section, index) => {
              const Icon = section.icon
              return (
                <motion.div
                  key={index}
                  variants={itemVariants}
                  className="bg-white rounded-2xl p-6 lg:p-8 shadow-md border border-nature-light/20"
                >
                  <div className="flex items-start gap-4 mb-4">
                    <div className="w-10 h-10 rounded-full bg-nature-light/20 flex items-center justify-center flex-shrink-0 mt-0.5">
                      <Icon className="w-5 h-5 text-forest-green" />
                    </div>
                    <h3 className="text-xl lg:text-2xl font-bold text-forest-green">
                      {section.title}
                    </h3>
                  </div>
                  <div className="pl-0 sm:pl-14">
                    <p className="text-earth-brown/80 leading-relaxed whitespace-pre-line">
                      {section.content}
                    </p>
                  </div>
                </motion.div>
              )
            })}
          </motion.div>

          <motion.div
            initial={{ opacity: 0 }}
            whileInView={{ opacity: 1 }}
            viewport={{ once: true }}
            className="mt-12 bg-sunset/10 border border-sunset/30 rounded-xl p-6 text-center"
          >
            <p className="text-earth-brown/70 text-sm leading-relaxed">
              <strong className="text-earth-brown">Legal Disclaimer:</strong> This privacy policy is a template 
              and should be reviewed by a qualified legal professional before production use.
            </p>
          </motion.div>
        </div>
      </section>
    </div>
  )
}
