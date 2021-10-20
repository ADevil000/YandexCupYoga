import SwiftUI
import Combine
import SoundAnalysis

/// Contains customizable settings that control app behavior.
struct AppConfiguration {
    /// Indicates the amount of audio, in seconds, that informs a prediction.
    var inferenceWindowSize = Double(1.2)

    /// The amount of overlap between consecutive analysis windows.
    ///
    /// The system performs sound classification on a window-by-window basis. The system divides an
    /// audio stream into windows, and assigns labels and confidence values. This value determines how
    /// much two consecutive windows overlap. For example, 0.9 means that each window shares 90% of
    /// the audio that the previous window uses.
    var overlapFactor = Double(0.1)

    /// A list of sounds to identify from system audio input.
    var monitoredSounds: SoundIdentifier = SoundIdentifier(labelName: "breathing")
}

/// The runtime state of the app after setup.
///
/// Sound classification begins after completing the setup process. The `DetectSoundsView` displays
/// the results of the classification. Instances of this class contain the detection information that
/// `DetectSoundsView` renders. It incorporates new classification results as the app produces them into
/// the cumulative understanding of what sounds are currently present. It tracks interruptions, and allows for
/// restarting an analysis by providing a new configuration.
class AppState: ObservableObject {
    /// A cancellable object for the lifetime of the sound classification.
    ///
    /// While the app retains this cancellable object, a sound classification task continues to run until it
    /// terminates due to an error.
    private var detectionCancellable: AnyCancellable? = nil

    /// The configuration that governs sound classification.
    private var appConfig = AppConfiguration()

    @Published var detectionTime: [Date] = []
    @Published var intervals: [BreathingInfo] = []

    /// Indicates whether a sound classification is active.
    ///
    /// When `false,` the sound classification has ended for some reason. This could be due to an error
    /// emitted from Sound Analysis, or due to an interruption in the recorded audio. The app needs to prompt
    /// the user to restart classification when `false.`
    @Published var soundDetectionIsRunning: Bool = false

    /// Begins detecting sounds according to the configuration you specify.
    ///
    /// If the sound classification is running when calling this method, it stops before starting again.
    ///
    /// - Parameter config: A configuration that provides information for performing sound detection.
    func restartDetection(config: AppConfiguration) {
        stopDetection()
        self.detectionTime = []
        self.intervals = []
        let classificationSubject = PassthroughSubject<SNClassificationResult, Error>()

        detectionCancellable =
          classificationSubject
          .receive(on: DispatchQueue.main)
          .sink(receiveCompletion: { _ in self.soundDetectionIsRunning = false },
                receiveValue: { value in
                    if self.isDetected(value: value) {
                        self.detectionTime.append(Date())
                        let count = self.detectionTime.count
                        if count > 1 {
                            let description = count % 2 == 0 ? "inhale -> exhale" : "exhale -> inhale"
                            let detected = self.detectionTime[count - 1]
                            self.intervals.append(BreathingInfo(description: description, interval: self.detectionTime[count - 2].distance(to: detected), id: detected.id, time: self.detectionTime[0].distance(to: detected)))
                        }
                    }
                })

        soundDetectionIsRunning = true
        appConfig = config
        SystemAudioClassifier.singleton.startSoundClassification(
          subject: classificationSubject,
          inferenceWindowSize: config.inferenceWindowSize,
          overlapFactor: config.overlapFactor)
    }
    
    func stopDetection() {
        SystemAudioClassifier.singleton.stopSoundClassification()
    }
    
    func isDetected(value: SNClassificationResult) -> Bool {
        (value.classification(forIdentifier: self.appConfig.monitoredSounds.labelName)?.confidence ?? 0) >= 0.7
    }
}

struct BreathingInfo: Identifiable {
    let description: String
    let interval: TimeInterval
    let id: Double
    let time: TimeInterval
}

extension Date: Identifiable {
    public var id: Double {
        self.timeIntervalSince1970
    }
}


@main
struct ClassifySoundApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
