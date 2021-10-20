import SwiftUI
import MessageUI

/// The main view that contains the app content.
struct ContentView: View {
    enum ScreenType {
        case setup, train, email
    }
    /// Indicates whether to display the setup workflow.
    @State var showType: ScreenType = .setup

    /// A configuration for managing the characteristics of a sound classification task.
    @State var appConfig = AppConfiguration()

    /// The runtime state that contains information about the strength of the detected sounds.
    @StateObject var appState = AppState()

    var body: some View {
        ZStack {
            switch showType {
            case .setup:
                SetupMonitoredSoundsView(    
                  doneAction: {
                      showType = .train
                    appState.restartDetection(config: appConfig)
                  })
            case .train:
                DetectSoundsView(state: appState,
                                 config: $appConfig,
                                 configureAction:
                                    {
                    self.appState.stopDetection()
                    if MFMailComposeViewController.canSendMail() {
                        showType = .email
                    } else {
                        showType = .setup
                    }
                }
                )
            case .email:
                MailContentView(state: self.appState, doneAction: {
                    showType = .setup
                })
            }
        }
    }
}

