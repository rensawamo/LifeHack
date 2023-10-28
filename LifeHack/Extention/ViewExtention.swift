
import SwiftUI

extension Color {
    static func background() -> some View {
        Color(red: 255 / 255, green: 250 / 255, blue: 240 / 255)
            .edgesIgnoringSafeArea(.all)
    }
}

extension View {
    func backgroundFloralWhite() -> some View {
        self.background(Color(red: 255 / 255, green: 250 / 255, blue: 240 / 255))
    }
}

extension Color {
    
    static let fontColor = Color(#colorLiteral(red: 0.3803921569, green: 0.1764705882, blue: 0.1137254902, alpha: 1))  // #602D1D
    
    static let customBackground = Color(red: 255 / 255, green: 250 / 255, blue: 240 / 255)
}

extension UIApplication {
    func closeKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension View {
    /// Custom Spacers
    @ViewBuilder
    func hSpacing(_ alignment: Alignment) -> some View {
        self
            .frame(maxWidth: .infinity, alignment: alignment)
    }
    
    @ViewBuilder
    func vSpacing(_ alignment: Alignment) -> some View {
        self
            .frame(maxHeight: .infinity, alignment: alignment)
    }
    
}


extension UIScreen {
    
    var hasHomeButton: Bool {
        return self.nativeBounds.height > 2208 || self.nativeBounds.height == 1792
    }
    
}
