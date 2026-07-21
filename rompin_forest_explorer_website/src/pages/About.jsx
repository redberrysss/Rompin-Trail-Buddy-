import { Link } from 'react-router-dom'
import { motion } from 'framer-motion'
import {
  GraduationCap,
  Users,
  Heart,
  Building2,
  Shield,
  TreePine,
  ArrowRight,
  Check,
  Eye,
  Brain,
  Hand,
  Compass,
  Lightbulb,
  Sprout,
  Download,
} from 'lucide-react'

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
      <h2 className={`text-3xl md:text-4xl font-bold mb-4 ${light ? 'text-white' : 'text-forest-dark'}`}>
        {title}
      </h2>
      {subtitle && (
        <p className={`text-lg ${light ? 'text-nature-light/90' : 'text-nature/80'}`}>{subtitle}</p>
      )}
    </div>
  )
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

export default function About() {
  return (
    <div>
      <PageHeader
        title="About Rompin Forest Explorer"
        subtitle="Making outdoor learning inclusive, structured, and engaging"
      />

      <Section className="bg-white py-20">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <motion.div variants={fadeInUp} initial="hidden" whileInView="visible" viewport={{ once: true }}>
            <h2 className="text-3xl font-bold text-forest-dark mb-6">Overview</h2>
            <div className="space-y-5 text-nature/80 leading-relaxed">
              <p>
                Rompin Forest Explorer is a mobile application specifically designed to make outdoor
                nature learning accessible and enjoyable for children with autism spectrum disorder
                (ASD). Built as part of the Rompin Forest Exploration Program in Pahang, Malaysia,
                this app transforms traditional field trips into structured, guided experiences that
                cater to the unique learning needs of neurodiverse children.
              </p>
              <p>
                The application provides visual instructions, guided activities, photo observation
                tools, and a facilitator dashboard that ensures every child can participate fully
                in nature-based learning. By combining technology with the natural environment,
                Rompin Forest Explorer bridges the gap between structured classroom learning and
                open-ended outdoor exploration.
              </p>
              <p>
                Whether used by special education teachers during school excursions, parents during
                weekend nature walks, or professional facilitators running organised programmes,
                the app offers a flexible yet consistent framework that supports children of varying
                abilities and learning styles.
              </p>
            </div>
          </motion.div>
        </div>
      </Section>

      <Section className="bg-forest py-20">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <motion.div
            variants={fadeInUp}
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true }}
            className="bg-white/10 backdrop-blur-sm rounded-3xl p-10 md:p-14 border border-white/10"
          >
            <div className="flex items-center gap-3 mb-6">
              <div className="w-12 h-12 bg-nature-light/20 rounded-xl flex items-center justify-center">
                <Lightbulb className="w-6 h-6 text-nature-light" />
              </div>
              <h2 className="text-3xl font-bold text-white">Our Mission</h2>
            </div>
            <p className="text-lg text-white/90 leading-relaxed mb-4">
              Our mission is to make outdoor learning inclusive, structured, and accessible for every
              child, regardless of their neurodevelopmental profile. We believe that nature is a
              powerful teacher, and every child deserves the opportunity to explore, discover, and
              learn in natural environments.
            </p>
            <p className="text-white/70 leading-relaxed">
              Through thoughtful design, evidence-based practices, and deep understanding of autism,
              we aim to remove barriers that prevent children with ASD from fully participating in
              outdoor education. Rompin Forest Explorer is more than an app — it is a commitment to
              inclusive education and a celebration of every child&apos;s potential to connect with nature.
            </p>
          </motion.div>
        </div>
      </Section>

      <Section className="bg-white py-20">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <motion.div variants={fadeInUp} initial="hidden" whileInView="visible" viewport={{ once: true }}>
            <h2 className="text-3xl font-bold text-forest-dark mb-6">Why This App Was Created</h2>
            <div className="space-y-5 text-nature/80 leading-relaxed">
              <p>
                Children with autism often face significant challenges when participating in outdoor
                activities. Unstructured environments, unpredictable schedules, sensory overload,
                and unclear instructions can make traditional field trips overwhelming rather than
                enriching. Many children with ASD miss out on the profound benefits of nature-based
                learning simply because existing outdoor programmes are not designed with their needs
                in mind.
              </p>
              <p>
                Rompin Forest Explorer was created to address this gap. Inspired by the rich
                biodiversity of Malaysia&apos;s Rompin Forest and the growing recognition that outdoor
                education benefits all children, the app was developed in collaboration with special
                educators, child development specialists, and autism advocates to ensure it meets the
                real-world needs of its users.
              </p>
              <p>
                The app was also developed in response to requests from teachers and parents who
                wanted a reliable, structured tool for outdoor learning. Many facilitators expressed
                the need for visual guides, progress tracking, and activity frameworks that could be
                consistently applied across different groups and settings.
              </p>
            </div>
          </motion.div>
        </div>
      </Section>

      <Section className="bg-cream py-20">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <SectionTitle title="Who It's For" subtitle="Rompin Forest Explorer serves multiple user groups, each with tailored features." />
          <motion.div variants={staggerContainer} initial="hidden" whileInView="visible" viewport={{ once: true }} className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
            {[
              { icon: Heart, title: 'Children with Autism', desc: 'Structured activities with visual instructions, simple navigation, sensory-friendly design, and achievement badges make nature learning enjoyable and accessible.' },
              { icon: Users, title: 'Parents', desc: 'Guide your child through nature walks with confidence. Track their progress, review their observations, and support their learning journey at home.' },
              { icon: GraduationCap, title: 'Teachers', desc: 'Plan and execute outdoor lessons with built-in activity frameworks. Monitor student participation and integrate nature learning into your curriculum.' },
              { icon: Hand, title: 'Facilitators', desc: 'Manage group sessions, review observations in real time, assign activities, and provide tailored support to each student during exploration.' },
              { icon: Building2, title: 'Organisations', desc: 'Schools, therapy centres, and nature programmes can deploy Rompin Forest Explorer as a standardised tool for inclusive outdoor education.' },
              { icon: Shield, title: 'Programme Coordinators', desc: 'Oversee multiple sessions, manage facilitator accounts, and access analytics to measure programme effectiveness and student outcomes.' },
            ].map((item) => {
              const Icon = item.icon
              return (
                <motion.div key={item.title} variants={fadeInUp} className="bg-white rounded-2xl p-7 border border-cream-dark hover:shadow-lg transition-shadow">
                  <div className="w-12 h-12 bg-forest/10 rounded-xl flex items-center justify-center mb-4">
                    <Icon className="w-6 h-6 text-forest" />
                  </div>
                  <h3 className="font-bold text-forest-dark mb-2">{item.title}</h3>
                  <p className="text-sm text-nature/70 leading-relaxed">{item.desc}</p>
                </motion.div>
              )
            })}
          </motion.div>
        </div>
      </Section>

      <Section className="bg-white py-20">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <SectionTitle title="Educational Value" subtitle="Nature-based learning offers profound benefits for all children." />
          <motion.div variants={staggerContainer} initial="hidden" whileInView="visible" viewport={{ once: true }} className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
            {[
              { icon: Eye, title: 'Enhanced Observation Skills', desc: 'Guided activities encourage children to look closely at natural details, developing visual attention and discrimination.' },
              { icon: Brain, title: 'Cognitive Development', desc: 'Exploring nature stimulates curiosity, problem-solving, and scientific thinking as children observe patterns and cause-effect relationships.' },
              { icon: Compass, title: 'Spatial Awareness', desc: 'Navigating trails and exploring different environments helps children develop spatial reasoning and orientation skills.' },
              { icon: Sprout, title: 'Environmental Awareness', desc: 'Direct interaction with nature fosters an appreciation for the environment and understanding of ecological concepts.' },
              { icon: Users, title: 'Social Skills', desc: 'Group activities provide structured opportunities for communication, turn-taking, cooperation, and peer interaction.' },
              { icon: Hand, title: 'Sensory Integration', desc: 'Nature offers rich, varied sensory input that supports sensory processing development in a calming, natural context.' },
            ].map((item) => {
              const Icon = item.icon
              return (
                <motion.div key={item.title} variants={fadeInUp} className="bg-cream rounded-2xl p-7 border border-cream-dark">
                  <div className="w-12 h-12 bg-nature/10 rounded-xl flex items-center justify-center mb-4">
                    <Icon className="w-6 h-6 text-nature" />
                  </div>
                  <h3 className="font-bold text-forest-dark mb-2">{item.title}</h3>
                  <p className="text-sm text-nature/70 leading-relaxed">{item.desc}</p>
                </motion.div>
              )
            })}
          </motion.div>
        </div>
      </Section>

      <Section className="bg-cream py-20">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <SectionTitle title="Benefits for Children with Autism" subtitle="How Rompin Forest Explorer specifically supports children on the spectrum." />
          <motion.div variants={staggerContainer} initial="hidden" whileInView="visible" viewport={{ once: true }} className="grid sm:grid-cols-2 gap-6 max-w-4xl mx-auto">
            {[
              'Reduced anxiety through predictable, structured activity flows',
              'Visual schedules that set clear expectations before each activity begins',
              'Short, step-by-step instructions that prevent overwhelm',
              'Large, easy-to-use touch targets for children with motor challenges',
              'Calm colour palette that minimises sensory overload',
              'Consistent navigation patterns across all app screens',
              'Positive reinforcement through activity badges and progress tracking',
              'Flexible pacing that allows breaks and repetition as needed',
              'Safe, supervised exploration with facilitator monitoring',
              'Opportunities for successful experiences that build confidence',
            ].map((item) => (
              <motion.div key={item} variants={fadeInUp} className="flex items-start gap-3 bg-white rounded-xl px-5 py-4 border border-cream-dark">
                <div className="mt-0.5 w-6 h-6 rounded-full bg-nature/10 flex items-center justify-center shrink-0">
                  <Check className="w-3.5 h-3.5 text-nature" />
                </div>
                <span className="text-sm text-nature/80 leading-relaxed">{item}</span>
              </motion.div>
            ))}
          </motion.div>
        </div>
      </Section>

      <Section className="bg-white py-20">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <SectionTitle title="Role of Facilitators and Parents" subtitle="The app is a tool — facilitators and parents bring it to life." />
          <motion.div variants={staggerContainer} initial="hidden" whileInView="visible" viewport={{ once: true }} className="space-y-6">
            <motion.div variants={fadeInUp} className="bg-cream rounded-2xl p-8 border border-cream-dark">
              <h3 className="font-bold text-forest-dark text-lg mb-3 flex items-center gap-2">
                <Hand className="w-5 h-5 text-nature" /> Facilitators
              </h3>
              <p className="text-nature/80 leading-relaxed mb-4">
                Facilitators are the backbone of every Rompin Forest Explorer session. Whether they
                are special education teachers, therapists, or trained nature guides, facilitators
                use the app&apos;s dedicated dashboard to prepare activities, monitor student progress,
                review observations, and provide real-time support. The facilitator interface
                empowers them to adapt activities on the fly, ensuring every child has a positive
                experience regardless of their individual challenges.
              </p>
              <p className="text-nature/80 leading-relaxed">
                The app also provides facilitators with pre-built activity templates, visual card
                libraries, and observation review tools that reduce preparation time and allow them
                to focus on what matters most — connecting with their students and the natural world.
              </p>
            </motion.div>
            <motion.div variants={fadeInUp} className="bg-cream rounded-2xl p-8 border border-cream-dark">
              <h3 className="font-bold text-forest-dark text-lg mb-3 flex items-center gap-2">
                <Heart className="w-5 h-5 text-nature" /> Parents
              </h3>
              <p className="text-nature/80 leading-relaxed mb-4">
                Parents play a vital role in extending the benefits of Rompin Forest Explorer beyond
                structured programmes. The app allows parents to guide their children through nature
                walks using the same visual instructions and structured activities used in
                professional settings. This consistency helps children feel comfortable and confident,
                knowing what to expect during outdoor experiences.
              </p>
              <p className="text-nature/80 leading-relaxed">
                Parents can also review their child&apos;s saved observations, photos, and badges,
                creating meaningful opportunities to discuss what their child learned and discovered.
                This shared experience strengthens family bonds and reinforces the child&apos;s connection
                with nature.
              </p>
            </motion.div>
          </motion.div>
        </div>
      </Section>

      <Section className="bg-forest py-20">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <motion.div variants={fadeInUp} initial="hidden" whileInView="visible" viewport={{ once: true }}>
            <div className="flex items-center gap-3 mb-6">
              <div className="w-12 h-12 bg-nature-light/20 rounded-xl flex items-center justify-center">
                <TreePine className="w-6 h-6 text-nature-light" />
              </div>
              <h2 className="text-3xl font-bold text-white">Rompin Forest Exploration Program</h2>
            </div>
            <div className="space-y-5 text-white/80 leading-relaxed">
              <p>
                Rompin Forest, located in the state of Pahang, Malaysia, is one of the country&apos;s
                most biodiverse tropical rainforests. Home to an incredible array of plant and animal
                species, it provides the perfect setting for immersive nature learning. The forest
                is known for its lush canopy, diverse wildlife including the Malayan tapir, and rich
                indigenous plant communities.
              </p>
              <p>
                The Rompin Forest Exploration Program was established to bring structured outdoor
                education to schools and organisations in the region. Recognising that many children —
                particularly those with autism — were missing out on these experiences, the programme
                integrated the Rompin Forest Explorer app as a core component of its delivery model.
              </p>
              <p>
                Through this programme, children participate in guided nature walks, animal and plant
                observation sessions, sensory exploration activities, and collaborative group
                challenges. The app serves as both a guide for facilitators and a companion for
                students, ensuring that every session is safe, structured, and deeply rewarding.
              </p>
              <p>
                The programme has partnered with local schools, special education centres, and
                environmental organisations to reach as many children as possible. By combining
                technology with the natural world, Rompin Forest Explorer and the Exploration Program
                are paving the way for a more inclusive approach to outdoor education in Malaysia.
              </p>
            </div>
          </motion.div>
        </div>
      </Section>

      <Section className="bg-white py-20">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <motion.div variants={fadeInUp} initial="hidden" whileInView="visible" viewport={{ once: true }}>
            <h2 className="text-3xl font-bold text-forest-dark mb-4">Ready to Explore?</h2>
            <p className="text-lg text-nature/80 mb-8">
              Download Rompin Forest Explorer and discover a world of structured, inclusive outdoor learning.
            </p>
            <div className="flex flex-wrap justify-center gap-4">
              <Link
                to="/download"
                className="inline-flex items-center gap-2 bg-forest hover:bg-forest-dark text-white font-semibold px-8 py-3.5 rounded-full transition-colors"
              >
                <Download className="w-5 h-5" /> Download the App
              </Link>
              <Link
                to="/features"
                className="inline-flex items-center gap-2 border-2 border-forest text-forest font-semibold px-8 py-3.5 rounded-full hover:bg-forest hover:text-white transition-colors"
              >
                Explore Features <ArrowRight className="w-5 h-5" />
              </Link>
            </div>
          </motion.div>
        </div>
      </Section>
    </div>
  )
}
