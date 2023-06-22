//
//  Created by Maharjan Binish on 2023/05/06.
//

import AppUI
import SwiftUI

struct ServerErrorView: View {
    var message: String
    var retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "xmark.octagon")
                .resizable()
                .frame(width: 75, height: 75)
                .foregroundColor(Color.app(.primary))
            
            Text("An server error has occurred")
                .font(.app(.title))
                .foregroundColor(Color.app(.primary))
            
            Text(verbatim: message)
                .multilineTextAlignment(.center)
                .font(.app(.body2))
                .foregroundColor(Color.app(.primary))
                .frame(width: 263)
        }
        .frame(maxHeight: .infinity)
        .bottomFloatingButton("Retry") {
            retryAction()
        }
    }
}

#Preview {
    ServerErrorView(
        message: "Please wait a while and try again.",
        retryAction: { }
    )
    .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
    .previewDisplayName("iPhone 8")
}

#Preview {
    ServerErrorView(
        message: "Please wait a while and try again.",
        retryAction: {}
    )
}
