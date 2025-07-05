import SwiftUI
import Speech

struct VoiceRecordingView: View {
    @EnvironmentObject var appState: AppStateManager
    @State private var waveformTimer: Timer?
    @State private var waveformAmplitudes: [CGFloat] = Array(repeating: 0.3, count: 20)

    // Speech Properties
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    @State var task: SFSpeechRecognitionTask?
    @State private var isRecording: Bool = false
    @State private var message: String?
    @State var hasErrorOccurred: Bool = false
    @State var hasRecordingErrorOccurred: Bool = false
    @State var receiptData: ReceiptData?

    var body: some View {
        VStack(spacing: .zero) {
            // Header
            headerSection

            VStack(spacing: 40) {
                Spacer()
                // Waveform
                waveformSection
                // Status
                statusSection
                // Record Button
                recordButtonSection
                Spacer()
            }
            .padding(.horizontal, Constraint.padding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.customRichBlack)
        .onDisappear {
            stopRecording()
        }
        .onAppear {
            requestPermission()
        }
        .showVoiceErrorAlert(isPresented: $hasErrorOccurred) {
            openSettings()
        }
        .showVoiceGeneralErrorAlert(isPresented: $hasRecordingErrorOccurred)
        .showReceiptFoundAlert(
            isPresented: .init(get: {
                receiptData != nil
            }, set: { bool in
                if !bool {
                    receiptData = nil
                    hasErrorOccurred = false
                }
            }),
            receiptData: receiptData ?? ReceiptData(totalAmount: .zero),
            onTap: saveTheReceipt
        )
    }

    
    
    // MARK: - Header
    private var headerSection: some View {
        var attributedTitle: AttributedString {
            var attributedString = AttributedString(NSLocalizedString("voice_entry", comment: ""))

            if let helloRange = attributedString.range(of: NSLocalizedString("voice", comment: "")) {
                attributedString[helloRange].foregroundColor = .customWhiteSand.opacity(Constraint.Opacity.high)
                attributedString[helloRange].font = TextFonts.titleSmall.font
            }
            if let worldRange = attributedString.range(of: NSLocalizedString("entry", comment: "")) {
                attributedString[worldRange].foregroundColor = .customWhiteSand
                attributedString[worldRange].font = TextFonts.titleSmallBold.font
            }
            return attributedString
        }
        return CustomNavigationBarTitleView(title: attributedTitle)
    }

    // MARK: - Waveform
    private var waveformSection: some View {
        HStack(spacing: 4) {
            ForEach(Array(waveformAmplitudes.enumerated()), id: \.offset) { index, amplitude in
                RoundedRectangle(cornerRadius: 2)
                    .fill(.customGold)
                    .frame(width: 6, height: waveformHeight(for: amplitude))
                    .opacity(isRecording ? 1.0 : 0.4)
                    .animation(
                        .easeInOut(duration: 0.2).delay(Double(index) * 0.03),
                        value: amplitude
                    )
            }
        }
        .frame(height: 80)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.customWhiteSand.opacity(0.05))
        )
    }
    
    // MARK: - Status
    private var statusSection: some View {
        VStack(spacing: Constraint.padding) {
            CustomTextView(isRecording ? NSLocalizedString("recording", comment: "") : NSLocalizedString("tap_and_hold", comment: ""), font: .bodyLarge)
                .animation(.smooth, value: isRecording)

            CustomTextView(message ?? "", font: .titleSmall)
                .frame(height: 60)
        }
    }
    
    // MARK: - Record Button
    private var recordButtonSection: some View {
        Button(action: {}) {
            ZStack {
                Circle()
                    .fill(.customGold)
                    .frame(width: 100, height: 100)
                    .scaleEffect(isRecording ? 1.1 : 1.0)
                    .shadow(
                        color: .customGold.opacity(0.3),
                        radius: isRecording ? 16 : 8,
                        y: 4
                    )
                if isRecording {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.customRichBlack)
                        .frame(width: 24, height: 24)
                } else {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.customRichBlack)
                }
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isRecording)
        .onLongPressGesture(minimumDuration: 0) {
            // Touch down
        } onPressingChanged: { isPressing in
            if isPressing {
                startRecording()
            } else {
                stopRecording()
            }
        }
    }
    
    // MARK: - Functions
    private func waveformHeight(for amplitude: CGFloat) -> CGFloat {
        let minHeight: CGFloat = 8
        let maxHeight: CGFloat = 60
        return minHeight + (amplitude * (maxHeight - minHeight))
    }
    
    private func startRecording() {
        isRecording = true

        waveformTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            updateWaveform()
        }

        startSpeechRecognization()
    }
    
    private func stopRecording() {
        isRecording = false

        waveformTimer?.invalidate()
        waveformTimer = nil

        withAnimation(.easeOut(duration: 0.4)) {
            waveformAmplitudes = Array(repeating: 0.3, count: 20)
        }

        cancelSpeechRecognization()

        let amount = Double(message?.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "") ?? "")

        if let amount = amount, amount > 0 {
            receiptData = .init(
                merchantName: nil,
                date: .now,
                totalAmount: amount
            )
        } else {
            withAnimation(.smooth) {
                hasRecordingErrorOccurred = true
            }
        }
    }

    private func updateWaveform() {
        withAnimation(.easeInOut(duration: 0.1)) {
            for i in 0..<waveformAmplitudes.count {
                waveformAmplitudes[i] = CGFloat.random(in: 0.2...1.0)
            }
        }
    }

    func requestPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized: break
                case .denied:
                    withAnimation(.smooth) {
                        hasErrorOccurred = true
                    }
                case .notDetermined: break
                case .restricted:
                    withAnimation(.smooth) {
                        hasErrorOccurred = true
                    }
                @unknown default: break
                }
            }
        }
    }

    func startSpeechRecognization() {
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        
        node.installTap(
            onBus: 0,
            bufferSize: 1024,
            format: recordingFormat) { [self] buffer, _ in
                self.request.append(buffer)
            }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {}

        guard let myRecognizer = SFSpeechRecognizer() else { return }
        if !myRecognizer.isAvailable { return }
        self.task = speechRecognizer?.recognitionTask(with: request, resultHandler: { [self] response, error in
            guard let response = response else { return }

            let speech = response.bestTranscription.formattedString
            DispatchQueue.main.async {
                withAnimation(.smooth) {
                    self.message = speech
                }
            }
        })
    }

    func cancelSpeechRecognization() {
        task?.finish()
        task?.cancel()
        task = nil
        request.endAudio()
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }

    func saveTheReceipt(of receipt: ReceiptData?) {
        HapticManager.shared.trigger(.success)
        DispatchQueue.main.async {
            withAnimation {
                appState.willOpenVoiceRecording = false
            }
        }

        guard let receipt = receipt else { return }
        let newExpense: ExpenseViewModel = .create(
            id: UUID(),
            name: receipt.merchantName ?? "",
            date: receipt.date ?? .now,
            amount: receipt.totalAmount ?? .zero,
            createDate: .now
        )
        switch DataController.shared.saveExpense(of: newExpense) {
        case .success:
            HapticManager.shared.trigger(.add)
            withAnimation {
                appState.hasAddedExpense = true
            }
        case .failure:
            HapticManager.shared.trigger(.error)
        }
    }

    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
            HapticManager.shared.trigger(.navigation)
        }
    }
}

// MARK: - Preview
struct VoiceRecordingView_Previews: PreviewProvider {
    static var previews: some View {
        VoiceRecordingView()
    }
}
