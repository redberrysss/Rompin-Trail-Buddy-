import { useState } from 'react'
import { Send, CheckCircle } from 'lucide-react'

const initialForm = {
  fullName: '',
  email: '',
  userRole: '',
  deviceModel: '',
  androidVersion: '',
  issueCategory: '',
  description: '',
}

export default function SupportForm() {
  const [form, setForm] = useState(initialForm)
  const [errors, setErrors] = useState({})
  const [submitted, setSubmitted] = useState(false)

  const validate = () => {
    const errs = {}
    if (!form.fullName.trim()) errs.fullName = 'Full name is required'
    if (!form.email.trim()) errs.email = 'Email is required'
    else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.email)) errs.email = 'Invalid email address'
    if (!form.userRole) errs.userRole = 'Please select a role'
    if (!form.deviceModel.trim()) errs.deviceModel = 'Device model is required'
    if (!form.androidVersion.trim()) errs.androidVersion = 'Android version is required'
    if (!form.issueCategory) errs.issueCategory = 'Please select an issue category'
    if (!form.description.trim()) errs.description = 'Description is required'
    return errs
  }

  const handleChange = (e) => {
    const { name, value } = e.target
    setForm((prev) => ({ ...prev, [name]: value }))
    if (errors[name]) setErrors((prev) => ({ ...prev, [name]: '' }))
  }

  const handleSubmit = (e) => {
    e.preventDefault()
    const errs = validate()
    if (Object.keys(errs).length > 0) {
      setErrors(errs)
      return
    }
    setSubmitted(true)
  }

  const inputClass = (field) =>
    `w-full px-4 py-3 rounded-xl border ${
      errors[field] ? 'border-red-400' : 'border-nature-light/40'
    } focus:outline-none focus:ring-2 focus:ring-nature-green/50 text-earth-brown bg-cream/30`

  if (submitted) {
    return (
      <div className="bg-white rounded-2xl p-8 lg:p-12 shadow-md text-center">
        <CheckCircle className="w-16 h-16 text-nature-green mx-auto mb-4" />
        <h3 className="text-2xl font-bold text-forest-green mb-2">Report Submitted!</h3>
        <p className="text-earth-brown/70">
          Thank you for your report. Our team will investigate and get back to you shortly.
        </p>
      </div>
    )
  }

  return (
    <form onSubmit={handleSubmit} className="bg-white rounded-2xl p-6 lg:p-10 shadow-md space-y-6" noValidate>
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
        <div>
          <label htmlFor="support-name" className="block text-sm font-medium text-forest-green mb-1.5">
            Full Name <span className="text-red-500">*</span>
          </label>
          <input
            id="support-name"
            name="fullName"
            type="text"
            value={form.fullName}
            onChange={handleChange}
            className={inputClass('fullName')}
            aria-invalid={!!errors.fullName}
            aria-describedby={errors.fullName ? 'support-name-error' : undefined}
          />
          {errors.fullName && (
            <p id="support-name-error" className="text-red-500 text-xs mt-1" role="alert">{errors.fullName}</p>
          )}
        </div>
        <div>
          <label htmlFor="support-email" className="block text-sm font-medium text-forest-green mb-1.5">
            Email <span className="text-red-500">*</span>
          </label>
          <input
            id="support-email"
            name="email"
            type="email"
            value={form.email}
            onChange={handleChange}
            className={inputClass('email')}
            aria-invalid={!!errors.email}
            aria-describedby={errors.email ? 'support-email-error' : undefined}
          />
          {errors.email && (
            <p id="support-email-error" className="text-red-500 text-xs mt-1" role="alert">{errors.email}</p>
          )}
        </div>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
        <div>
          <label htmlFor="support-role" className="block text-sm font-medium text-forest-green mb-1.5">
            User Role <span className="text-red-500">*</span>
          </label>
          <select
            id="support-role"
            name="userRole"
            value={form.userRole}
            onChange={handleChange}
            className={inputClass('userRole')}
            aria-invalid={!!errors.userRole}
            aria-describedby={errors.userRole ? 'support-role-error' : undefined}
          >
            <option value="">Select your role</option>
            <option value="student">Student</option>
            <option value="facilitator">Facilitator</option>
            <option value="administrator">Administrator</option>
            <option value="parent">Parent</option>
            <option value="other">Other</option>
          </select>
          {errors.userRole && (
            <p id="support-role-error" className="text-red-500 text-xs mt-1" role="alert">{errors.userRole}</p>
          )}
        </div>
        <div>
          <label htmlFor="support-category" className="block text-sm font-medium text-forest-green mb-1.5">
            Issue Category <span className="text-red-500">*</span>
          </label>
          <select
            id="support-category"
            name="issueCategory"
            value={form.issueCategory}
            onChange={handleChange}
            className={inputClass('issueCategory')}
            aria-invalid={!!errors.issueCategory}
            aria-describedby={errors.issueCategory ? 'support-category-error' : undefined}
          >
            <option value="">Select issue category</option>
            <option value="login">Login Issue</option>
            <option value="crash">App Crash</option>
            <option value="activity">Activity Problem</option>
            <option value="account">Account Issue</option>
            <option value="feature">Feature Request</option>
            <option value="other">Other</option>
          </select>
          {errors.issueCategory && (
            <p id="support-category-error" className="text-red-500 text-xs mt-1" role="alert">{errors.issueCategory}</p>
          )}
        </div>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
        <div>
          <label htmlFor="support-device" className="block text-sm font-medium text-forest-green mb-1.5">
            Device Model <span className="text-red-500">*</span>
          </label>
          <input
            id="support-device"
            name="deviceModel"
            type="text"
            value={form.deviceModel}
            onChange={handleChange}
            placeholder="e.g. Samsung Galaxy S21"
            className={inputClass('deviceModel')}
            aria-invalid={!!errors.deviceModel}
            aria-describedby={errors.deviceModel ? 'support-device-error' : undefined}
          />
          {errors.deviceModel && (
            <p id="support-device-error" className="text-red-500 text-xs mt-1" role="alert">{errors.deviceModel}</p>
          )}
        </div>
        <div>
          <label htmlFor="support-android" className="block text-sm font-medium text-forest-green mb-1.5">
            Android Version <span className="text-red-500">*</span>
          </label>
          <input
            id="support-android"
            name="androidVersion"
            type="text"
            value={form.androidVersion}
            onChange={handleChange}
            placeholder="e.g. Android 13"
            className={inputClass('androidVersion')}
            aria-invalid={!!errors.androidVersion}
            aria-describedby={errors.androidVersion ? 'support-android-error' : undefined}
          />
          {errors.androidVersion && (
            <p id="support-android-error" className="text-red-500 text-xs mt-1" role="alert">{errors.androidVersion}</p>
          )}
        </div>
      </div>

      <div>
        <label htmlFor="support-description" className="block text-sm font-medium text-forest-green mb-1.5">
          Description <span className="text-red-500">*</span>
        </label>
        <textarea
          id="support-description"
          name="description"
          rows={5}
          value={form.description}
          onChange={handleChange}
          placeholder="Please describe the issue in detail..."
          className={`w-full px-4 py-3 rounded-xl border ${
            errors.description ? 'border-red-400' : 'border-nature-light/40'
          } focus:outline-none focus:ring-2 focus:ring-nature-green/50 text-earth-brown bg-cream/30 resize-vertical`}
          aria-invalid={!!errors.description}
          aria-describedby={errors.description ? 'support-description-error' : undefined}
        />
        {errors.description && (
          <p id="support-description-error" className="text-red-500 text-xs mt-1" role="alert">{errors.description}</p>
        )}
      </div>

      <button
        type="submit"
        className="inline-flex items-center gap-2 px-8 py-3 bg-forest-green text-white font-semibold rounded-full hover:bg-nature-green transition-colors duration-200 shadow-sm hover:shadow-md"
      >
        <Send className="w-4 h-4" />
        Submit Report
      </button>
    </form>
  )
}
