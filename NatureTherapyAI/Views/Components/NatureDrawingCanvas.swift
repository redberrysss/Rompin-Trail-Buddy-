import SwiftUI

struct NatureDrawingCanvas: View {
    @Binding var selectedTool: String
    let onComplete: () -> Void

    @State private var lines: [DrawLine] = []
    @State private var currentLine: DrawLine?

    let tools = ["Leaf", "Flower", "Rock", "Stick", "Finger"]
    let toolEmojis = ["🍃", "🌸", "🪨", "🌿", "👆"]

    let colors: [Color] = [
        .green, AppTheme.forestGreen, AppTheme.emerald,
        AppTheme.softOrange, .yellow, AppTheme.softBlue, .red, .purple
    ]
    @State private var selectedColor: Color = AppTheme.forestGreen

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Color(red: 0.97, green: 0.97, blue: 0.95)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius))

                Canvas { context, size in
                    for line in lines {
                        var path = Path()
                        if let first = line.points.first {
                            path.move(to: first)
                            for point in line.points.dropFirst() {
                                path.addLine(to: point)
                            }
                        }
                        context.stroke(path, with: .color(line.color), lineWidth: line.width)
                    }
                    if let current = currentLine {
                        var path = Path()
                        if let first = current.points.first {
                            path.move(to: first)
                            for point in current.points.dropFirst() {
                                path.addLine(to: point)
                            }
                        }
                        context.stroke(path, with: .color(current.color), lineWidth: current.width)
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let point = value.location
                            if currentLine == nil {
                                currentLine = DrawLine(points: [point],
                                                       color: selectedColor,
                                                       width: lineWidth(for: selectedTool))
                            } else {
                                currentLine?.points.append(point)
                            }
                        }
                        .onEnded { _ in
                            if let line = currentLine {
                                lines.append(line)
                                currentLine = nil
                            }
                        }
                )
            }
            .frame(height: 300)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                    .stroke(AppTheme.lightGreen.opacity(0.5), lineWidth: 1.5)
            )

            HStack(spacing: 10) {
                ForEach(Array(colors.enumerated()), id: \.offset) { _, color in
                    Circle()
                        .fill(color)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                        )
                        .shadow(color: color.opacity(0.3), radius: selectedColor == color ? 4 : 0)
                        .onTapGesture { selectedColor = color }
                }
            }

            HStack(spacing: 10) {
                ForEach(Array(tools.enumerated()), id: \.offset) { index, tool in
                    VStack(spacing: 3) {
                        Text(toolEmojis[index])
                            .font(.system(size: 24))
                        Text(tool)
                            .font(AppTheme.smallCaption)
                            .foregroundColor(selectedTool == tool ? AppTheme.forestGreen : AppTheme.secondaryText)
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(selectedTool == tool ? AppTheme.lightGreen.opacity(0.3) : Color.clear)
                    )
                    .onTapGesture { selectedTool = tool }
                }
            }

            HStack(spacing: 16) {
                Button(action: { lines.removeAll() }) {
                    Label("Clear", systemImage: "trash")
                        .font(AppTheme.captionFont)
                        .foregroundColor(.red)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.red.opacity(0.08))
                        )
                }

                Button(action: onComplete) {
                    Label("Save Drawing", systemImage: "checkmark.circle.fill")
                        .font(AppTheme.captionFont)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(AppTheme.forestGreen)
                        )
                }
            }
        }
    }

    private func lineWidth(for tool: String) -> CGFloat {
        switch tool {
        case "Leaf": return 6
        case "Flower": return 4
        case "Rock": return 10
        case "Stick": return 3
        case "Finger": return 8
        default: return 5
        }
    }
}

struct DrawLine {
    var points: [CGPoint]
    let color: Color
    let width: CGFloat
}
