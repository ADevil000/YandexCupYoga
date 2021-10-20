import SwiftUI

/// A view for selecting sounds to monitor.
struct SetupMonitoredSoundsView: View {
    var doneSetup: () -> ()
    
    init(doneAction: @escaping () -> ()) {
        self.doneSetup = doneAction
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("Start on inhale")
            Button(LocalizedStringKey("Start"), action: doneSetup)
                .buttonStyle(.bordered)
        }
    }
}
