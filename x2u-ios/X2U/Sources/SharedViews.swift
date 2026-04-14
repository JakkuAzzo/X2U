import SwiftUI
import UIKit

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

struct X2ULogoView: View {
    let size: CGFloat

    init(size: CGFloat = 84) {
        self.size = size
    }

    var body: some View {
        if let image = X2ULogoImageLoader.image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        } else {
            Image(systemName: "xmark.octagon")
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .foregroundStyle(X2UTheme.accent)
        }
    }
}

private enum X2ULogoImageLoader {
    static let image: UIImage? = {
        if let assetImage = UIImage(named: "X2ULogo") {
            return assetImage
        }

        guard let path = Bundle.main.path(forResource: "X2ULogo", ofType: "png") else {
            return nil
        }
        return UIImage(contentsOfFile: path)
    }()
}
