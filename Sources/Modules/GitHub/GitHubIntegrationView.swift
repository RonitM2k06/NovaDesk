import SwiftUI
import Core
import UIComponents

public struct GitHubIntegrationView: View {
    @State private var viewModel: GitHubViewModel
    @Environment(\.themePalette) private var theme
    
    public init(viewModel: GitHubViewModel = GitHubViewModel()) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            toolbarView
            Divider().background(theme.secondaryText.opacity(0.3))
            
            if !viewModel.isConfigured {
                setupView
            } else if viewModel.isLoading {
                Spacer()
                ProgressView("Fetching GitHub data...")
                    .foregroundColor(theme.primaryText)
                Spacer()
            } else {
                contentView
            }
        }
        .background(theme.background)
    }
    
    private var toolbarView: some View {
        HStack {
            Text("GitHub")
                .font(DesignSystem.Typography.subHeader)
                .foregroundColor(theme.primaryText)
            
            Spacer()
            
            if viewModel.isConfigured {
                Button("Disconnect") {
                    viewModel.disconnect()
                }
                .buttonStyle(.plain)
                .foregroundColor(theme.error)
            }
        }
        .padding(DesignSystem.Spacing.medium)
        .background(theme.secondaryBackground)
    }
    
    private var setupView: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            Image(systemName: "lock.shield")
                .font(.system(size: 64))
                .foregroundColor(theme.accent)
            Text("Connect GitHub")
                .font(DesignSystem.Typography.header)
            Text("Enter a Personal Access Token (classic or fine-grained) to access your repositories. The token will be securely stored in the macOS Keychain.")
                .font(DesignSystem.Typography.body)
                .foregroundColor(theme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            SecureField("Personal Access Token", text: $viewModel.patTokenInput)
                .textFieldStyle(.roundedBorder)
                .frame(width: 300)
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(theme.error)
            }
            
            Button("Connect") {
                viewModel.saveToken()
            }
            .buttonStyle(.nova)
            .disabled(viewModel.patTokenInput.isEmpty)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var contentView: some View {
        HStack(alignment: .top, spacing: 0) {
            // Sidebar: User Profile
            VStack {
                if let profile = viewModel.userProfile {
                    AsyncImage(url: URL(string: profile.avatarUrl)) { image in
                        image.resizable().aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .padding(.top, DesignSystem.Spacing.large)
                    
                    Text(profile.name ?? profile.login)
                        .font(DesignSystem.Typography.subHeader)
                        .foregroundColor(theme.primaryText)
                    Text("@\(profile.login)")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(theme.secondaryText)
                }
                Spacer()
            }
            .frame(width: 200)
            .background(theme.secondaryBackground)
            
            Divider().background(theme.secondaryText.opacity(0.3))
            
            // Main content: Repositories
            List {
                Section(header: Text("Repositories").font(DesignSystem.Typography.subHeader)) {
                    ForEach(viewModel.repositories) { repo in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Image(systemName: repo.privateRepo ? "lock" : "globe")
                                        .foregroundColor(theme.secondaryText)
                                    Text(repo.fullName)
                                        .font(DesignSystem.Typography.body.weight(.medium))
                                        .foregroundColor(theme.accent)
                                }
                                if let desc = repo.description {
                                    Text(desc)
                                        .font(DesignSystem.Typography.caption)
                                        .foregroundColor(theme.secondaryText)
                                        .lineLimit(2)
                                }
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                    Text("\(repo.stargazersCount)")
                                        .font(DesignSystem.Typography.caption)
                                }
                                if let lang = repo.language {
                                    Text(lang)
                                        .font(DesignSystem.Typography.caption)
                                        .foregroundColor(theme.secondaryText)
                                }
                            }
                        }
                        .padding(.vertical, DesignSystem.Spacing.small)
                        // In a real macOS app we might open the link in the browser
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}
