//
//  Created by Maharjan Binish on 2023/05/03.
//

import SwiftUI

public struct AngularButton: View {
    @Environment(\.isEnabled) private var isEnabled
    @GestureState private var isDetectingLongPress = false
    @State private var tap = false
    @State private var completedLongPress = false

    private var title: LocalizedStringKey

    public init(title: LocalizedStringKey) {
        self.title = title
    }

    public var body: some View {
        Text(completedLongPress ? "Loading..." : title)
            .opacity(isEnabled ? 1.0 : 0.5)
            .foregroundColor(.app(.primary))
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, maxHeight: 50)
            .background(
                ZStack {
                    angularGradient
                    LinearGradient(gradient: Gradient(colors: [Color(.systemBackground).opacity(1), Color(.systemBackground).opacity(0.6)]), startPoint: .top, endPoint: .bottom)
                        .cornerRadius(20)
                        .blendMode(.softLight)
                }
                    .opacity(isEnabled ? 1.0 : 0.7)
            )
            .frame(height: 50)
            .accentColor(.primary.opacity(0.7))
            .scaleEffect(isDetectingLongPress ? 0.8 : 1)
    }

    private var angularGradient: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.clear)
            .overlay(AngularGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(#colorLiteral(red: 0, green: 0.5199999809265137, blue: 1, alpha: 1)), location: 0.0),
                    .init(color: Color(#colorLiteral(red: 0.2156862745, green: 1, blue: 0.8588235294, alpha: 1)), location: 0.4),
                    .init(color: Color(#colorLiteral(red: 1, green: 0.4196078431, blue: 0.4196078431, alpha: 1)), location: 0.5),
                    .init(color: Color(#colorLiteral(red: 1, green: 0.1843137255, blue: 0.6745098039, alpha: 1)), location: 0.8)]),
                center: .center
            ))
            .padding(6)
            .blur(radius: 20)
    }
}

struct AngularButton_Previews: PreviewProvider {
    static var previews: some View {
        AngularButton(title: "Button")
    }
}
