import SwiftUI

struct BoundingBoxOverlay: View {
    let detections: [DetectionResult]
    let onTap: (DetectionResult) -> Void

    var body: some View {
        GeometryReader { geometry in
            let imageWidth = geometry.size.width
            let imageHeight = geometry.size.height

            ForEach(detections) { detection in
                let rect = normalizedRect(
                    from: detection.boundingBox,
                    in: CGSize(width: imageWidth, height: imageHeight)
                )

                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(boxColor(confidence: detection.confidence), lineWidth: 2.5)
                        .frame(width: rect.width, height: rect.height)
                        .position(x: rect.midX, y: rect.midY)

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Text(detection.objectName)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)

                            Text(detection.confidencePercentage)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(boxColor(confidence: detection.confidence))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .position(x: rect.midX, y: max(rect.minY - 12, 18))
                }
                .onTapGesture { onTap(detection) }
            }
        }
    }

    private func normalizedRect(from boundingBox: CGRect, in size: CGSize) -> CGRect {
        let x = boundingBox.origin.x * size.width
        let y = (1 - boundingBox.origin.y - boundingBox.height) * size.height
        let w = boundingBox.width * size.width
        let h = boundingBox.height * size.height
        return CGRect(x: x, y: y, width: w, height: h)
    }

    private func boxColor(confidence: Float) -> Color {
        if confidence > 0.8 { return AppTheme.emerald }
        else if confidence > 0.5 { return AppTheme.softOrange }
        else { return Color.red }
    }
}
