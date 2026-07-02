import SwiftUI
import Core

/// Centralized Design System for NovaDesk ensuring consistent styling, spacing, and typography across the app.
public struct DesignSystem {
    public struct Spacing {
        public static let xSmall: CGFloat = 4
        public static let small: CGFloat = 8
        public static let medium: CGFloat = 16
        public static let large: CGFloat = 24
        public static let xLarge: CGFloat = 32
        public static let xxLarge: CGFloat = 48
    }
    
    public struct CornerRadius {
        public static let small: CGFloat = 6
        public static let medium: CGFloat = 10
        public static let large: CGFloat = 16
    }
    
    public struct Typography {
        public static let header = Font.system(.title, design: .rounded).weight(.semibold)
        public static let subHeader = Font.system(.title3, design: .rounded).weight(.medium)
        public static let body = Font.system(.body, design: .default)
        public static let code = Font.system(.body, design: .monospaced)
        public static let caption = Font.system(.caption, design: .default).weight(.regular)
    }
}

/// A custom button style that adheres to the NovaDesk premium aesthetic.
public struct NovaButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, DesignSystem.Spacing.medium)
            .padding(.vertical, DesignSystem.Spacing.small)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .fill(configuration.isPressed ? Color.accentColor.opacity(0.8) : Color.accentColor)
            )
            .foregroundColor(.white)
            .font(DesignSystem.Typography.body.weight(.medium))
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

public extension ButtonStyle where Self == NovaButtonStyle {
    static var nova: NovaButtonStyle {
        NovaButtonStyle()
    }
}
