export default function SectionTitle({ title, subtitle, light = false }) {
  return (
    <div className="text-center max-w-3xl mx-auto mb-12 lg:mb-16">
      <h2
        className={`text-3xl sm:text-4xl lg:text-5xl font-bold mb-4 ${
          light ? 'text-white' : 'text-forest-green'
        }`}
      >
        {title}
      </h2>
      <div className="w-20 h-1 bg-nature-green mx-auto rounded-full mb-6" />
      {subtitle && (
        <p
          className={`text-lg sm:text-xl leading-relaxed ${
            light ? 'text-white/80' : 'text-earth-brown/80'
          }`}
        >
          {subtitle}
        </p>
      )}
    </div>
  )
}
