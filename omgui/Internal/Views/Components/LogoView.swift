import SwiftUI
#if canImport(UIKit)
import UIKit
#endif


struct LogoView: View {
    @Environment(\.colorScheme)
    var colorScheme
    
    let size: CGFloat
    
    init(_ size: CGFloat = 33.0) {
        self.size = size
    }
    
    var body: some View {
        coreIcon
            .aspectRatio(1, contentMode: .fit)
            .frame(width: size, height: size)
    }
    
    @ViewBuilder
    var coreIcon: some View {
        foreground
    }
    
    @ViewBuilder
    var foreground: some View {
        Heart()
    }
    
    @ViewBuilder
    var iconBackground: some View {
        Color.lolBackground
    }
    
    @ViewBuilder
    var roundRectMask: some View {
        RoundedRectangle(cornerRadius: 12)
    }
    
    @ViewBuilder
    var circleMask: some View {
        Circle()
    }
}

fileprivate struct Heart: View {
    var body: some View {
        GeometryReader { reader in
            ZStack(alignment: .top) {
                Image(systemName: "heart.fill")
                    .font(.system(size: reader.percentageHeight(0.74), weight: .bold, design: .serif))
                    .foregroundStyle(
                        AngularGradient(
                            colors: Color.lolRandom,
                            center: .top,
                            angle: Angle(degrees: 180)
                        )
                    )
                    .shadow(color: .lolAccent, radius: reader.percentageHeight(0.08))
                Image(systemName: "heart.fill")
                    .font(.system(size: reader.percentageHeight(0.55), weight: .bold, design: .serif))
                    .foregroundStyle(
                        LinearGradient(
                            stops: [
                                .init(color: .lolPink, location: 0.3),
                                .init(color: .lolOrange, location: 0.4),
                                .init(color: .lolYellow, location: 0.55),
                                .init(color: .lolGreen, location: 0.8),
                                .init(color: .lolPurple, location: 0.95)
                            ],
                            startPoint:
                                UnitPoint(x: 0, y: 0),
                            endPoint: UnitPoint(x: 1, y: 0)
                        )
                    )
                    .offset(y: reader.percentageHeight(0.04))
                    .shadow(radius: 22)
            }
            .padding(.top, reader.percentageHeight(0.04))
            .rotationEffect(.degrees(-10))
        }
    }
}

extension GeometryProxy {
    func percentageWidth(_ percentage: CGFloat) -> CGFloat {
        return size.width * percentage
    }
    func percentageHeight(_ percentage: CGFloat) -> CGFloat {
        size.height * percentage
    }
}

#if canImport(UIKit)
extension UIView {
    func asImage() -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 2
        return UIGraphicsImageRenderer(size: self.layer.frame.size, format: format).image { context in
            self.drawHierarchy(in: self.layer.bounds, afterScreenUpdates: true)
        }
    }
}
extension View {
    func asImage(size: CGSize) -> UIImage {
        let controller = UIHostingController(rootView: self)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.backgroundColor = .clear
        let image = controller.view.asImage()
        return image
    }
}
#endif
