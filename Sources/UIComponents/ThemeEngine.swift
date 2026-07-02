import SwiftUI
import Core

/// Defines the color palette for a theme in NovaDesk.
public struct ThemePalette: Equatable {
    public let background: Color
    public let secondaryBackground: Color
    public let primaryText: Color
    public let secondaryText: Color
    public let accent: Color
    public let warning: Color
    public let error: Color
    public let success: Color
    
    public init(
        background: Color,
        secondaryBackground: Color,
        primaryText: Color,
        secondaryText: Color,
        accent: Color,
        warning: Color,
        error: Color,
        success: Color
    ) {
        self.background = background
        self.secondaryBackground = secondaryBackground
        self.primaryText = primaryText
        self.secondaryText = secondaryText
        self.accent = accent
        self.warning = warning
        self.error = error
        self.success = success
    }
    
    public static let dark = ThemePalette(
        background: Color(red: 0.08, green: 0.08, blue: 0.09),
        secondaryBackground: Color(red: 0.12, green: 0.12, blue: 0.14),
        primaryText: .white,
        secondaryText: .gray,
        accent: Color.blue,
        warning: Color.orange,
        error: Color.red,
        success: Color.green
    )
    
    public static let light = ThemePalette(
        background: Color(red: 0.98, green: 0.98, blue: 0.99),
        secondaryBackground: Color(red: 0.92, green: 0.92, blue: 0.94),
        primaryText: .black,
        secondaryText: .gray,
        accent: Color.blue,
        warning: Color.orange,
        error: Color.red,
        success: Color.green
    )
}

/// A centralized Theme Engine to manage and publish theme changes.
@Observable
public final class ThemeEngine {
    public static let shared = ThemeEngine()
    
    public var currentPalette: ThemePalette = .dark
    
    private init() {}
    
    public func setDarkTheme() {
        currentPalette = .dark
    }
    
    public func setLightTheme() {
        currentPalette = .light
    }
}

/// A view modifier to inject the theme into the environment.
public struct ThemeEnvironmentModifier: ViewModifier {
    @Bindable var themeEngine = ThemeEngine.shared
    
    public func body(content: Content) -> some View {
        content
            .environment(\.themePalette, themeEngine.currentPalette)
    }
}

public extension View {
    func withThemeEngine() -> some View {
        self.modifier(ThemeEnvironmentModifier())
    }
}

/// Environment key for easy access to the current theme palette.
private struct ThemePaletteKey: EnvironmentKey {
    static let defaultValue: ThemePalette = .dark
}

public extension EnvironmentValues {
    var themePalette: ThemePalette {
        get { self[ThemePaletteKey.self] }
        set { self[ThemePaletteKey.self] = newValue }
    }
}
