import TestimonialCard from './TestimonialCard'

export default function TestimonialSlider({ testimonials = [] }) {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 lg:gap-8">
      {testimonials.map((testimonial, index) => (
        <TestimonialCard
          key={testimonial.id || index}
          name={testimonial.name}
          role={testimonial.role}
          text={testimonial.text}
          rating={testimonial.rating}
        />
      ))}
    </div>
  )
}
