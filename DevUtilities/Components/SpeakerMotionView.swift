// Copyright 2026 Hengfei Yang.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import SwiftUI

/// Animated speaker icon that shows three wave levels with staggered animations
struct SpeakerMotionView: View {
    @State private var opacity1: Double = 0
    @State private var opacity2: Double = 0
    @State private var opacity3: Double = 0

    var body: some View {
        ZStack(alignment: .leading) {
            Image(systemName: "speaker.wave.1")
                .opacity(opacity1)
            Image(systemName: "speaker.wave.2")
                .opacity(opacity2)
            Image(systemName: "speaker.wave.3")
                .opacity(opacity3)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                opacity1 = 1
            }
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true).delay(0.2)) {
                opacity2 = 1
            }
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true).delay(0.4)) {
                opacity3 = 1
            }
        }
    }
}

#Preview {
    SpeakerMotionView()
        .font(.system(size: 24))
}
