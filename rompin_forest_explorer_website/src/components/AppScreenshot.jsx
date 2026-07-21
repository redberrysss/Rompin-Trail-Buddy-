export default function AppScreenshot({ title = 'App Screenshot', className = '' }) {
  return (
    <div className={`relative ${className}`} aria-hidden="true">
      <div className="relative w-[260px] sm:w-[280px] lg:w-[300px] mx-auto">
        <div className="absolute -inset-1 bg-gradient-to-br from-nature-light/40 to-nature-green/30 rounded-[3rem] blur-sm" />
        <div className="relative bg-gray-900 rounded-[2.5rem] p-3 shadow-2xl">
          <div className="relative bg-white rounded-[2rem] overflow-hidden">
            <div className="absolute top-0 left-1/2 -translate-x-1/2 w-28 h-6 bg-gray-900 rounded-b-2xl z-10" />

            <div className="pt-8 pb-4 px-4">
              <div className="w-full aspect-[9/16] rounded-xl overflow-hidden relative">
                <div className="absolute inset-0 bg-gradient-to-br from-forest-green via-nature-green to-nature-light" />
                <div className="absolute inset-0 flex flex-col items-center justify-center text-white p-6 text-center">
                  <div className="w-16 h-16 rounded-full bg-white/20 flex items-center justify-center mb-4">
                    <svg
                      className="w-8 h-8"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="2"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    >
                      <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2z" />
                      <path d="M8 14s1.5 2 4 2 4-2 4-2" />
                      <line x1="9" y1="9" x2="9.01" y2="9" />
                      <line x1="15" y1="9" x2="15.01" y2="9" />
                    </svg>
                  </div>
                  <p className="text-sm font-semibold opacity-90">{title}</p>
                  <div className="mt-4 space-y-2 w-full">
                    <div className="h-2 bg-white/20 rounded-full w-3/4 mx-auto" />
                    <div className="h-2 bg-white/20 rounded-full w-1/2 mx-auto" />
                    <div className="h-8 bg-white/15 rounded-lg mt-4" />
                    <div className="h-8 bg-white/15 rounded-lg" />
                    <div className="h-8 bg-white/15 rounded-lg" />
                  </div>
                </div>
              </div>
            </div>

            <div className="h-1 bg-gray-900 mx-16 rounded-full mb-2" />
          </div>
        </div>
      </div>
    </div>
  )
}
