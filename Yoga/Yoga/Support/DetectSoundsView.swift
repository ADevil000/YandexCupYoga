import Foundation
import SwiftUI

///  Provides a visualization the app uses when detecting sounds.
struct DetectSoundsView: View {
    /// The runtime state that contains information about the strength of the detected sounds.
    @ObservedObject var state: AppState

    /// The configuration that dictates aspects of sound classification, as well as aspects of the visualization.
    @Binding var config: AppConfiguration

    /// An action to perform when the user requests to edit the app's configuration.
    let configureAction: () -> ()

    var body: some View {
        VStack {
            List(self.state.intervals) { info in
                Text(info.description + "\ninterval: " + info.interval.stringFromTimeInterval() + "\ndetected: " + info.time.stringFromTimeInterval())
            }
            Spacer()
            Button("Finish", action: self.configureAction)
                .buttonStyle(.bordered)
        }.padding()
    }
}

extension TimeInterval{
    func stringFromTimeInterval() -> String {
        let time = NSInteger(self)
        let ms = Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        return String(format: "%0.2d:%0.2d.%0.3d", minutes, seconds, ms)

    }
}
