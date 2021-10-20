import Foundation
import MessageUI
import SwiftUI

struct MailView: UIViewControllerRepresentable {

    @Binding var isShowing: Bool
    @Binding var result: Result<MFMailComposeResult, Error>?
    let state: AppState

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {

        @Binding var isShowing: Bool
        @Binding var result: Result<MFMailComposeResult, Error>?

        init(isShowing: Binding<Bool>,
             result: Binding<Result<MFMailComposeResult, Error>?>) {
            _isShowing = isShowing
            _result = result
        }

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            defer {
                isShowing = false
            }
            guard error == nil else {
                self.result = .failure(error!)
                return
            }
            self.result = .success(result)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(isShowing: $isShowing,
                           result: $result)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setMessageBody(getMessage(self.state.intervals), isHTML: true)
        vc.mailComposeDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                                context: UIViewControllerRepresentableContext<MailView>) {

    }
    
    func getMessage(_ yogaInfo: [BreathingInfo]) -> String {
        var res: String = "<table>"
        for info in yogaInfo {
            res += "<tr><td>\(info.description)</td><td>interval: \(info.interval.stringFromTimeInterval())</td><td>detected: \(info.time.stringFromTimeInterval())</td></tr>"
        }
        res += "</table>"
        return res
    }
    
}

struct MailContentView: View {
    let state: AppState
    let doneAction: () -> ()
    
    
    @State var result: Result<MFMailComposeResult, Error>? = nil
    @State var isShowingMailView = false

    var body: some View {

        VStack {
            if MFMailComposeViewController.canSendMail() {
                Button("Send mail") {
                    self.isShowingMailView.toggle()
                }
            } else {
                Text("Can't send emails from this device")
            }
            Button("Go to start") {
                doneAction()
            }
        }.buttonStyle(.bordered)
        .sheet(isPresented: $isShowingMailView) {
            MailView(isShowing: self.$isShowingMailView, result: self.$result, state: self.state)
        }

    }

}
