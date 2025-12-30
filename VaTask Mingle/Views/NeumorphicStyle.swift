import SwiftUI

// MARK: - Color Extensions
extension Color {
    static let appBackground = Color(hex: "1D1F30")
    static let appAccent = Color(hex: "FE284A")
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Neumorphic Button Style
struct NeumorphicButtonStyle: ButtonStyle {
    var color: Color = .appAccent
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(color)
                        .shadow(color: Color.black.opacity(0.5), radius: 10, x: 5, y: 5)
                        .shadow(color: Color.white.opacity(0.1), radius: 10, x: -5, y: -5)
                }
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}

// MARK: - Neumorphic Card
struct NeumorphicCard<Content: View>: View {
    let content: Content
    var backgroundColor: Color = Color.appBackground
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(backgroundColor)
                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 8, y: 8)
                    .shadow(color: Color.white.opacity(0.05), radius: 10, x: -8, y: -8)
            )
    }
}

// MARK: - Neumorphic Text Field
struct NeumorphicTextField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.appBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.4), radius: 5, x: 3, y: 3)
                    .shadow(color: Color.white.opacity(0.05), radius: 5, x: -3, y: -3)
            )
            .foregroundColor(.white)
    }
}

// MARK: - Neumorphic Toggle
struct NeumorphicToggle: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.white)
            Spacer()
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: .appAccent))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.appBackground)
                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 5, y: 5)
                .shadow(color: Color.white.opacity(0.05), radius: 8, x: -5, y: -5)
        )
    }
}

