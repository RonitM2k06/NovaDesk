import SwiftUI

public struct ToastModifier: ViewModifier {
    @Binding var isShowing: Bool
    let message: String
    @Environment(\.themePalette) private var theme
    
    public func body(content: Content) -> some View {
        ZStack {
            content
            
            if isShowing {
                VStack {
                    Spacer()
                    Text(message)
                        .font(DesignSystem.Typography.body.weight(.medium))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(theme.accent)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    isShowing = false
                                }
                            }
                        }
                        .padding(.bottom, 20)
                }
                .zIndex(100)
            }
        }
    }
}

public extension View {
    func toast(isShowing: Binding<Bool>, message: String) -> some View {
        self.modifier(ToastModifier(isShowing: isShowing, message: message))
    }
}
