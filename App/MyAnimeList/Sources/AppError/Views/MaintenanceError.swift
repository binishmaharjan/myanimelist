//
//  Created by Maharjan Binish on 2023/05/07.
//

import SwiftUI
import AppUI

struct MaintenanceView: View {
    var message: String
    var retryAction: () -> Void

    var body: some View {
        ZStack {
            Color.clear
                .background {
                    Asset.Images.imgBlob1.swiftUIImage
                        .offset(x: 170, y: -60)
                        .blur(radius: 20)
                        .accessibilityHidden(true)
                }

            VStack(spacing: 16) {
                Text("Under maintenance")
                    .font(.app(.title))
                    .foregroundColor(.app(.primary))

                Text(verbatim: message)
                    .font(.app(.body2))
                    .foregroundColor(.app(.primary))
                    .frame(width: 263)
            }
            .frame(maxHeight: .infinity)
            .bottomFloatingButton("Retry") {
                retryAction()
            }
        }
    }
}

struct MaintenanceView_Previews: PreviewProvider {
    static var previews: some View {
        MaintenanceView(message: "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.") {}
    }
}
