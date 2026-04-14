import SwiftUI

struct CardView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(X2UTheme.cardBorder, lineWidth: 1)
            )
    }
}

extension View {
    func x2uScreenBackground() -> some View {
        self
            .background(X2UTheme.pageBackground.ignoresSafeArea())
    }
}
