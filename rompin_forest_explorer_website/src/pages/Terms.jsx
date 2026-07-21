import { motion } from 'framer-motion'
import {
  FileCheck, Shield, Users, Lock, Camera, Copyright,
  Clock, AlertTriangle, RefreshCw, Mail, BookOpen,
} from 'lucide-react'
import PageHeader from '../components/PageHeader'

const sections = [
  {
    icon: FileCheck,
    title: '1. Acceptance of Terms',
    content: `By downloading, installing, or using the Rompin Forest Explorer application ("the App"), you agree to be bound by these Terms of Use. If you do not agree to these terms, please do not use the App. These terms constitute a legally binding agreement between you and the Rompin Forest Explorer team. For users under the age of 18, a parent or guardian must review and accept these terms on behalf of the minor.`,
  },
  {
    icon: BookOpen,
    title: '2. Description of Service',
    content: `Rompin Forest Explorer is a mobile application designed to support nature exploration activities for children with autism. The App provides structured outdoor learning activities, visual guidance, camera-based observation recording, progress tracking, and facilitator support tools. The App is intended for use in educational settings and outdoor environments under adult supervision. Features include activity modules, photograph capture, observation logging, badge systems, and multi-role access for students, facilitators, and administrators.`,
  },
  {
    icon: Users,
    title: '3. User Responsibilities',
    content: `As a user of Rompin Forest Explorer, you agree to:

Provide accurate and truthful information when creating your account and using the app.
Use the App only for its intended educational and nature exploration purposes.
Ensure that any personal information entered is accurate and up to date.
Use the App in compliance with all applicable local, state, national, and international laws and regulations.
Supervise children at all times during outdoor activities facilitated by the App.
Report any bugs, security vulnerabilities, or inappropriate content to our support team promptly.`,
  },
  {
    icon: Lock,
    title: '4. Account Security',
    content: `You are responsible for maintaining the security of your account credentials. Keep your password confidential and do not share it with anyone. Use a strong, unique password for your account. If you suspect unauthorized access to your account, change your password immediately and contact our support team. We are not responsible for any loss or damage arising from unauthorized use of your account. Facilitators and administrators should take extra precautions to protect their credentials due to the elevated access levels associated with these roles.`,
  },
  {
    icon: Shield,
    title: '5. Appropriate Use',
    content: `You agree not to:

Misuse the App in any way that could damage, disable, or impair its functionality.
Upload or transmit harmful, offensive, inappropriate, or malicious content through the App.
Attempt to gain unauthorized access to other users' accounts, data, or the App's systems.
Use the App for any commercial purpose without explicit written permission.
Interfere with or disrupt the App's servers, networks, or infrastructure.
Reverse engineer, decompile, or disassemble any part of the App.
Use automated tools or scripts to interact with the App unless specifically authorized.`,
  },
  {
    icon: Users,
    title: '6. Child Supervision',
    content: `Rompin Forest Explorer is designed for use by children with adult supervision. The App requires adult supervision at all times during outdoor activities. Facilitators are responsible for the safety, well-being, and appropriate use of the App by children in their care. Parents and guardians should review activity content and approve participation before children begin any activity. Facilitators must ensure that all children under their supervision have proper safety equipment and are in a safe environment during activities. The App is not a substitute for professional supervision or safety guidance.`,
  },
  {
    icon: Camera,
    title: '7. Camera Usage',
    content: `Photographs taken through the App are intended for educational and observational purposes only. Photos are captured to document nature observations during guided activities. Users must obtain appropriate consent before photographing individuals. Photographs are stored securely and are only accessible to the user, their assigned facilitators, and authorized administrators. Photos must not be used for any purpose other than the educational objectives of the activity. We reserve the right to review photographs to ensure compliance with our community guidelines and terms of use.`,
  },
  {
    icon: Copyright,
    title: '8. Intellectual Property',
    content: `All content, design, graphics, text, code, and other materials within Rompin Forest Explorer are owned by or licensed to the Rompin Forest Explorer team and are protected by copyright, trademark, and other intellectual property laws. You may not reproduce, distribute, modify, create derivative works of, publicly display, or in any way exploit any of the App's content without prior written permission. User-generated content, including photographs and observations, remains the property of the user, but by submitting content through the App, you grant us a non-exclusive license to store, display, and process that content within the context of the App's services.`,
  },
  {
    icon: Clock,
    title: '9. Service Availability',
    content: `We strive to provide reliable and uninterrupted access to Rompin Forest Explorer. However, we do not guarantee that the App will be available at all times without interruption. We may temporarily suspend or restrict access to the App for maintenance, updates, or circumstances beyond our control. We are not liable for any loss or damage caused by the unavailability of the App. Core features are designed to function with limited connectivity, but some features may require an active internet connection to operate fully.`,
  },
  {
    icon: AlertTriangle,
    title: '10. Disclaimer',
    content: `Rompin Forest Explorer is provided on an "as is" and "as available" basis without any warranties of any kind, either express or implied. We do not warrant that the App will be error-free, secure, or compatible with all devices. We do not guarantee the accuracy, completeness, or reliability of any content or information provided through the App. The App is not a substitute for professional educational guidance, medical advice, or safety supervision. Users assume all risks associated with outdoor activities facilitated by the App.`,
  },
  {
    icon: Shield,
    title: '11. Limitation of Liability',
    content: `To the maximum extent permitted by applicable law, the Rompin Forest Explorer team shall not be liable for any indirect, incidental, special, consequential, or punitive damages arising out of or related to your use of the App. Our total liability for any claim arising out of or relating to these terms or the App shall not exceed the amount you paid to us for the App, or fifty Malaysian Ringgit (RM 50), whichever is greater. These limitations apply regardless of the legal theory on which the claim is based.`,
  },
  {
    icon: RefreshCw,
    title: '12. Changes to Terms',
    content: `We reserve the right to modify these Terms of Use at any time. When we make material changes, we will notify you through the App, via email, or by other appropriate means. Your continued use of the App after any changes constitutes acceptance of the updated terms. If you do not agree to the modified terms, you should stop using the App and contact us to close your account. We encourage you to review these terms periodically.`,
  },
  {
    icon: Mail,
    title: '13. Contact Details',
    content: `If you have any questions or concerns about these Terms of Use, please contact us:

Email: terms@rompinforestexplorer.com
Phone: +60-12-345-6789
Address: Rompin, Pahang, Malaysia

We will respond to all inquiries within 5 business days.`,
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

export default function Terms() {
  return (
    <div>
      <PageHeader
        title="Terms of Use"
        subtitle="Please read these terms carefully"
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
              <strong className="text-earth-brown">Disclaimer:</strong> These Terms of Use are a template 
              and should be reviewed by a qualified legal professional before production use.
            </p>
          </motion.div>
        </div>
      </section>
    </div>
  )
}
