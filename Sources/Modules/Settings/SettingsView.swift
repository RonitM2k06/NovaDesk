import SwiftUI
import Core
import UIComponents

public struct SettingsView: View {
    @State private var viewModel: SettingsViewModel
    @Environment(\.themePalette) private var theme
    
    public init(viewModel: SettingsViewModel = SettingsViewModel()) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        Form {
            Section(header: Text("Appearance").font(DesignSystem.Typography.subHeader)) {
                Toggle("Dark Mode", isOn: Binding(
                    get: { viewModel.preferences.useDarkMode },
                    set: { 
                        viewModel.preferences.useDarkMode = $0
                        viewModel.hasUnsavedChanges = true 
                        if $0 {
                            ThemeEngine.shared.setDarkTheme()
                        } else {
                            ThemeEngine.shared.setLightTheme()
                        }
                    }
                ))
            }
            
            Section(header: Text("Terminal").font(DesignSystem.Typography.subHeader)) {
                TextField("Default Shell", text: Binding(
                    get: { viewModel.preferences.defaultTerminalShell },
                    set: { viewModel.preferences.defaultTerminalShell = $0; viewModel.hasUnsavedChanges = true }
                ))
            }
            
            Section(header: Text("AI Settings").font(DesignSystem.Typography.subHeader)) {
                Picker("Default Provider", selection: Binding(
                    get: { viewModel.preferences.defaultAIProvider },
                    set: { viewModel.preferences.defaultAIProvider = $0; viewModel.hasUnsavedChanges = true }
                )) {
                    Text("OpenAI").tag("OpenAI")
                    Text("Ollama").tag("Ollama")
                    Text("Anthropic").tag("Anthropic")
                }
            }
            
            if viewModel.hasUnsavedChanges {
                HStack {
                    Button("Save") {
                        viewModel.save()
                    }
                    .buttonStyle(.nova)
                    
                    Button("Discard") {
                        viewModel.discardChanges()
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(theme.error)
                }
                .padding(.top, DesignSystem.Spacing.medium)
            }
            
            if let error = viewModel.saveError {
                Text(error)
                    .foregroundColor(theme.error)
                    .font(DesignSystem.Typography.caption)
            }
        }
        .padding()
        .background(theme.background)
        .foregroundColor(theme.primaryText)
    }
}
