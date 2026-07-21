import { motion } from 'framer-motion'
import {
  Leaf, TreePine, Binoculars, Map, Compass, Camera,
  BookOpen, Users, Mountain, Droplets, Sun, Wind,
  Bug, Flower2, PawPrint, Microscope, Globe, Heart,
  Zap, Target, Award, Lightbulb, Layers, Cpu,
  Database, Shield, Settings, Star, CheckCircle,
  Calendar, Clock, FileText, Search, Bell, Home,
  ListChecks, Save, BarChart3, LayoutDashboard, WifiOff,
  Cloud, Navigation, ClipboardList, ClipboardCheck,
  Sparkles, Image, Footprints, ChevronDown, ChevronUp,
  GraduationCap, UserCheck, Download, MapPin, Menu, X,
  Building2, Phone, Mail, ExternalLink, ChevronRight,
  AlertTriangle, ShieldCheck, Info, HelpCircle, Send,
} from 'lucide-react'

const iconMap = {
  Leaf, TreePine, Binoculars, Map, Compass, Camera,
  BookOpen, Users, Mountain, Droplets, Sun, Wind,
  Bug, Flower2, PawPrint, Microscope, Globe, Heart,
  Zap, Target, Award, Lightbulb, Layers, Cpu,
  Database, Shield, Settings, Star, CheckCircle,
  Calendar, Clock, FileText, Search, Bell, Home,
  ListChecks, Save, BarChart3, LayoutDashboard, WifiOff,
  Cloud, Navigation, ClipboardList, ClipboardCheck,
  Sparkles, Image, Footprints, ChevronDown, ChevronUp,
  GraduationCap, UserCheck, Download, MapPin, Menu, X,
  Building2, Phone, Mail, ExternalLink, ChevronRight,
  AlertTriangle, ShieldCheck, Info, HelpCircle, Send,
}

export default function FeatureCard({ title, description, icon = 'Leaf', index = 0 }) {
  const IconComponent = iconMap[icon] || Leaf

  return (
    <motion.div
      initial={{ opacity: 0, y: 30 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: '-50px' }}
      transition={{ delay: index * 0.1, duration: 0.5 }}
      whileHover={{ y: -6, transition: { duration: 0.25 } }}
      className="bg-white rounded-2xl p-6 lg:p-8 shadow-md hover:shadow-xl transition-shadow duration-300 border border-nature-light/20"
    >
      <div className="w-14 h-14 rounded-full bg-nature-light/20 flex items-center justify-center mb-5">
        <IconComponent className="w-7 h-7 text-forest-green" />
      </div>
      <h3 className="text-xl font-bold text-forest-green mb-3">{title}</h3>
      <p className="text-earth-brown/70 leading-relaxed">{description}</p>
    </motion.div>
  )
}
