import SwiftUI

struct FacilitatorModePlaceholder: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 48))
                    .foregroundColor(AppTheme.forestGreen)

                Text("Mod Fasilitator")
                    .font(AppTheme.titleFont)
                    .foregroundColor(AppTheme.darkGreen)

                Text("Mod ini akan tersedia dalam kemas kini akan datang.")
                    .font(AppTheme.bodyFont)
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.backgroundGradient.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Tutup") { dismiss() }
                        .font(AppTheme.bodyFont)
                        .foregroundColor(AppTheme.forestGreen)
                }
            }
        }
    }
}
