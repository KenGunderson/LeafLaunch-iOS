//
//  VoiceTranscriptionService.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/4/26.
//

import Combine
import AVFoundation
import Speech

final class VoiceTranscriptionService: VoiceTranscriptionServiceProtocol {
    
    internal let loggerName: String = "VOICE_TRANSCRIPTION_SERVICE"
    internal let loggerEmoji: String = "🎤"
    
    // Recording
    
    @Published private(set) var isRecording: Bool = false
    var isRecordingPublisher: AnyPublisher<Bool, Never> {
        return self.$isRecording.eraseToAnyPublisher()
    }
    
    @Published private(set) var lastRecordingURL: URL?
    var lastRecordingURLPublisher: AnyPublisher<URL?, Never> {
        return self.$lastRecordingURL.eraseToAnyPublisher()
    }
    
    @Published private(set) var tempRecordings: [VoiceRecordingFile] = []
    var tempRecordingsPublisher: AnyPublisher<[VoiceRecordingFile], Never> {
        return self.$tempRecordings.eraseToAnyPublisher()
    }
    
    // Transcriptions
    
    @Published private(set) var isTranscribing: Bool = false
    var isTranscribingPublisher: AnyPublisher<Bool, Never> {
        return self.$isTranscribing.eraseToAnyPublisher()
    }
    
    @Published private(set) var partialTranscript: String = ""
    var partialTranscriptPublisher: AnyPublisher<String, Never> {
        return self.$partialTranscript.eraseToAnyPublisher()
    }
    
    @Published private(set) var finalTranscript: String = ""
    var finalTranscriptPublisher: AnyPublisher<String, Never> {
        return self.$finalTranscript.eraseToAnyPublisher()
    }
    
    @Published private(set) var error: VoiceTranscriptionError?
    var errorPublisher: AnyPublisher<VoiceTranscriptionError?, Never> {
        return self.$error.eraseToAnyPublisher()
    }
    
    private let microphonePermissionService: MicrophonePermissionServiceProtocol
    private let speechRecognitionPermissionService: SpeechRecognitionPermissionServiceProtocol
    
    private let fileManager: FileManager
    private let audioSession: AVAudioSession
    private let speechLocale: Locale
    private let audioEngine = AVAudioEngine()
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recordingFile: AVAudioFile?
    private var activeRecognitionCycleID: UUID?
    
    private var committedTranscript: String = ""
    private var latestRecognitionSnapshot: String = ""
    private var lastRecognitionUpdateAt: Date?
    
    private var recordingDirectoryURL: URL {
        
        return self.fileManager
            .temporaryDirectory
            .appendingPathComponent("voice-recordings", isDirectory: true)
        
    }
    
    private let recordingAudioExtensions: Set<String> = ["m4a", "wav", "caf", "mp3", "aac"]
    
    init(microphonePermissionService: MicrophonePermissionServiceProtocol,
         speechRecognitionPermissionService: SpeechRecognitionPermissionServiceProtocol,
         fileManager: FileManager = .default,
         audioSession: AVAudioSession = .sharedInstance(),
         speechLocale: Locale = .autoupdatingCurrent) {
        
        self.microphonePermissionService = microphonePermissionService
        self.speechRecognitionPermissionService = speechRecognitionPermissionService
        self.fileManager = fileManager
        self.audioSession = audioSession
        self.speechLocale = speechLocale
        
        self.logInit()
        
        do {
            
            try ensureRecordingDirectoryExists()
            refreshTempRecordings()
            
        }
        catch {
            
            self.error = .fileOperationFailed(message: error.localizedDescription)
            self.logError(
                title: "Voice Recording Directory Error",
                message: error.localizedDescription
            )
            
        }
        
    }
    
    isolated deinit {
        
        self.tearDownAudioPipeline()
        self.logDeinit()
        
    }
    
    func startRecording() throws {
        
        // Check permissions and ensure healthy startup
        
        if self.isRecording {
            try publishAndThrow(.recordingAlreadyActive)
        }
        
        guard self.microphonePermissionService.permissionGranted else {
            return try publishAndThrow(.missingMicrophonePermission)
        }
        
        guard self.speechRecognitionPermissionService.permissionGranted else {
            return try publishAndThrow(.missingSpeechPermission)
        }
        
        guard let speechRecognizer = SFSpeechRecognizer(locale: self.speechLocale) else {
            return try publishAndThrow(.speechRecognizerUnavailable)
        }
        
        guard speechRecognizer.isAvailable else {
            return try publishAndThrow(.speechRecognizerUnavailable)
        }
        
        guard speechRecognizer.supportsOnDeviceRecognition else {
            return try publishAndThrow(.onDeviceRecognitionUnsupported)
        }
        
        do {
            
            // Clear out old values
            
            self.error = nil
            self.clearRecognitionSnapshotState()
            self.committedTranscript = ""
            self.finalTranscript = ""
            self.activeRecognitionCycleID = nil
            
            try ensureRecordingDirectoryExists()
            tearDownAudioPipeline()
            try configureAudioSession()
            
            // Make new audo file and bind recording to it
            
            let recordingURL = makeRecordingFileURL()
            
            let inputNode = self.audioEngine.inputNode
            let inputFormat = inputNode.outputFormat(forBus: 0)
            
            let recordingSettings = recordingSettings(for: inputFormat)
            let recordingFile = try AVAudioFile(
                forWriting: recordingURL,
                settings: recordingSettings
            )
            
            self.speechRecognizer = speechRecognizer
            self.recordingFile = recordingFile
            self.lastRecordingURL = recordingURL
            
            _ = try self.startContinuousRecognitionTask()
            
            self.audioEngine.prepare()
            try self.audioEngine.start()
            
            self.isRecording = true
            self.isTranscribing = true
            
            self.log(message: "Started voice recording at: \(recordingURL.absoluteString)")
            
        }
        catch let error as VoiceTranscriptionError {
            
            self.tearDownAudioPipeline()
            throw error
            
        }
        catch {
            
            self.tearDownAudioPipeline()
            
            try publishAndThrow(
                .recordingInitializationFailed(message: error.localizedDescription)
            )
            
        }
        
    }
    
    func stopRecording() throws {
        
        guard self.isRecording else {
            return try publishAndThrow(.recordingNotActive)
        }
        
        self.audioEngine.stop()
        self.audioEngine.inputNode.removeTap(onBus: 0)
        self.recognitionRequest?.endAudio()
        
        self.isRecording = false
        self.isTranscribing = false
        self.recordingFile = nil
        
        self.commitLatestRecognitionSnapshot()
        self.commitRecognitionSnapshot(self.partialTranscript)
        self.clearRecognitionSnapshotState()
        
        do {
            try self.audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        }
        catch {
            self.logError(
                title: "Deactivate Audio Session Error",
                message: error.localizedDescription
            )
        }
        
        self.persistTranscriptIfAvailable(for: self.lastRecordingURL)
        self.refreshTempRecordings()
        
        self.log(message: "Stopped voice recording")
        
    }
    
    func clearCurrentSession() {
        
        if self.isRecording {
            try? self.stopRecording()
        }

        self.clearRecognitionSnapshotState()
        self.committedTranscript = ""
        self.finalTranscript = ""
        self.activeRecognitionCycleID = nil
        self.lastRecordingURL = nil
        self.error = nil
        self.isTranscribing = false
        
    }
    
    func listTempRecordings() -> [VoiceRecordingFile] {
        return self.tempRecordings
    }
    
    func deleteTempFile(at url: URL) throws {
        
        do {
            try self.fileManager.removeItem(at: url)
            try self.removeTranscriptFileIfNeeded(for: url)
            
            if self.lastRecordingURL == url {
                self.lastRecordingURL = nil
            }
            
            self.refreshTempRecordings()
            
        }
        catch {
            try publishAndThrow(
                .fileOperationFailed(message: error.localizedDescription)
            )
        }
        
    }
    
    func deleteAllTempFiles() throws {
        
        do {
            
            for file in self.tempRecordings {
                try self.fileManager.removeItem(at: file.url)
                try self.removeTranscriptFileIfNeeded(for: file.url)
            }
            
            self.lastRecordingURL = nil
            self.refreshTempRecordings()
            
        }
        catch {
            try publishAndThrow(
                .fileOperationFailed(message: error.localizedDescription)
            )
        }
        
    }
    
    private func publishAndThrow(_ error: VoiceTranscriptionError) throws {
        
        self.error = error
        throw error
        
    }
    
    private func configureAudioSession() throws {
        
        do {
            
            try self.audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try self.audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
        }
        catch {
            
            try publishAndThrow(
                .audioSessionConfigurationFailed(message: error.localizedDescription)
            )
            
        }
        
    }
    
    private func recordingSettings(for inputFormat: AVAudioFormat) -> [String: Any] {
        
        return [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: inputFormat.sampleRate,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
    }
    
    private func makeRecordingFileURL() -> URL {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        
        let fileName = "voice_\(formatter.string(from: Date()))_\(UUID().uuidString).m4a"
        
        return self.recordingDirectoryURL.appendingPathComponent(fileName)
        
    }
    
    private func ensureRecordingDirectoryExists() throws {
        
        if !self.fileManager.fileExists(atPath: self.recordingDirectoryURL.path()) {
            
            try self.fileManager.createDirectory(
                at: self.recordingDirectoryURL,
                withIntermediateDirectories: true
            )
            
        }
        
    }
    
    private func refreshTempRecordings() {
        
        do {
            
            let urls = try self.fileManager.contentsOfDirectory(
                at: self.recordingDirectoryURL,
                includingPropertiesForKeys: [.creationDateKey, .fileSizeKey],
                options: .skipsHiddenFiles
            )
            
            self.tempRecordings = urls
                .filter { self.isRecordingAudioFileURL($0) }
                .map { url in
                    
                    let values = try? url.resourceValues(forKeys: [.creationDateKey, .fileSizeKey])
                    
                    return VoiceRecordingFile(
                        url: url,
                        createdAt: values?.creationDate ?? .distantPast,
                        sizeInBytes: Int64(values?.fileSize ?? 0),
                        transcript: self.loadTranscript(for: url)
                    )
                    
                }
                .sorted { lhs, rhs in
                    lhs.createdAt > rhs.createdAt
                }
            
        }
        catch {
            
            self.tempRecordings = []
            self.error = .fileOperationFailed(message: error.localizedDescription)
            
        }
        
    }
    
    @discardableResult
    private func startContinuousRecognitionTask() throws -> SFSpeechAudioBufferRecognitionRequest? {
        
        guard let speechRecognizer = self.speechRecognizer else { return nil }
        
        self.recognitionTask?.cancel()
        self.recognitionRequest?.endAudio()
        
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.requiresOnDeviceRecognition = true
        
        let recognitionCycleID = UUID()
        self.activeRecognitionCycleID = recognitionCycleID
        
        self.recognitionRequest = request
        self.recognitionTask = Self.makeRecognitionTask(
            speechRecognizer: speechRecognizer,
            request: request,
            recognitionCycleID: recognitionCycleID,
            service: self
        )
        
        self.rebindInputTapIfNeeded(for: request)
        
        return request
        
    }

    private func rebindInputTapIfNeeded(for recognitionRequest: SFSpeechAudioBufferRecognitionRequest) {
        
        guard let recordingFile = self.recordingFile else {
            return
        }
        
        let inputNode = self.audioEngine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.removeTap(onBus: 0)
        
        Self.installInputTap(
            inputNode: inputNode,
            inputFormat: inputFormat,
            recordingFile: recordingFile,
            recognitionRequest: recognitionRequest,
            service: self
        )
        
    }
    
    @MainActor
    private func handleRecognitionCallback(partialTranscript: String?,
                                           isFinal: Bool,
                                           errorMessage: String?,
                                           recognitionCycleID: UUID) {
        
        guard self.activeRecognitionCycleID == recognitionCycleID else {
            return
        }
        
        if let partialTranscript {
            
            let normalizedTranscript = partialTranscript.trimmed()
            
            if !normalizedTranscript.isEmpty {
                
                self.commitLatestRecognitionSnapshotIfNeeded(before: normalizedTranscript)
                self.latestRecognitionSnapshot = self.mergeTranscript(
                    existingTranscript: self.latestRecognitionSnapshot,
                    incomingTranscript: normalizedTranscript
                )
                
                if isFinal {
                    
                    self.commitLatestRecognitionSnapshot()
                    self.clearRecognitionSnapshotState()
                    
                    if !self.isRecording {
                        
                        self.isTranscribing = false
                        self.persistTranscriptIfAvailable(for: self.lastRecordingURL)
                        self.refreshTempRecordings()
                        
                    }
                    
                }
                else {
                    
                    self.partialTranscript = self.extractInFlightTranscript(
                        currentSnapshot: self.latestRecognitionSnapshot,
                        finalizedTranscript: self.committedTranscript
                    )
                    self.publishRollingFinalTranscript()
                    
                }
                
                self.lastRecognitionUpdateAt = Date()
                
            }
            
        }
        
        if (isFinal || errorMessage != nil) && self.isRecording {
            
            self.commitLatestRecognitionSnapshot()
            self.commitRecognitionSnapshot(self.partialTranscript)
            self.clearRecognitionSnapshotState()
            
            do {
                let _ = try self.startContinuousRecognitionTask()
            }
            catch {
                self.error = .transcriptionFailed(message: "Could not resume transcription: \(error.localizedDescription)")
            }
            
            return
            
        }
        
        if let errorMessage, !self.isRecording {
            
            self.isTranscribing = false
            
            if !self.finalTranscript.isEmpty {
                return
            }
            
            self.error = .transcriptionFailed(message: errorMessage)
            
        }
        
    }
    
    private func commitLatestRecognitionSnapshotIfNeeded(before incomingSnapshot: String) {
        
        guard self.shouldCommitLatestRecognitionSnapshot(before: incomingSnapshot) else {
            return
        }
        
        self.commitLatestRecognitionSnapshot()
        self.clearRecognitionSnapshotState()
        
    }
    
    private func shouldCommitLatestRecognitionSnapshot(before incomingSnapshot: String) -> Bool {
        
        let previousSnapshot = self.latestRecognitionSnapshot.trimmed()
        let incoming = incomingSnapshot.trimmed()
        
        guard !previousSnapshot.isEmpty,
              !incoming.isEmpty,
              previousSnapshot != incoming else {
            return false
        }
        
        if incoming.hasPrefix(previousSnapshot) || incoming.contains(previousSnapshot) {
            return false
        }
        
        guard let lastRecognitionUpdateAt else {
            return self.isLikelyRecognitionReset(
                previousSnapshot: previousSnapshot,
                incomingSnapshot: incoming
            )
        }
        
        let didPauseLongEnough = Date().timeIntervalSince(lastRecognitionUpdateAt) >= 1.0
        
        guard didPauseLongEnough else {
            return false
        }
        
        if previousSnapshot.hasPrefix(incoming) || previousSnapshot.contains(incoming) {
            return self.isLikelyRecognitionReset(
                previousSnapshot: previousSnapshot,
                incomingSnapshot: incoming
            )
        }
        
        return true
        
    }
    
    private func isLikelyRecognitionReset(previousSnapshot: String,
                                          incomingSnapshot: String) -> Bool {
        
        if previousSnapshot.hasSuffix(incomingSnapshot) {
            return true
        }
        
        return self.wordCount(previousSnapshot) - self.wordCount(incomingSnapshot) >= 2
        
    }
    
    private func commitLatestRecognitionSnapshot() {
        self.commitRecognitionSnapshot(self.latestRecognitionSnapshot)
    }
    
    private func commitRecognitionSnapshot(_ transcript: String) {
        
        let normalizedTranscript = transcript.trimmed()
        
        guard !normalizedTranscript.isEmpty else {
            return
        }
        
        self.committedTranscript = self.mergeTranscript(
            existingTranscript: self.committedTranscript,
            incomingTranscript: normalizedTranscript
        )
        self.finalTranscript = self.committedTranscript
        
    }
    
    private func publishRollingFinalTranscript() {
        
        self.finalTranscript = self.mergeTranscript(
            existingTranscript: self.committedTranscript,
            incomingTranscript: self.latestRecognitionSnapshot
        )
        
    }
    
    private func clearRecognitionSnapshotState() {
        
        self.partialTranscript = ""
        self.latestRecognitionSnapshot = ""
        self.lastRecognitionUpdateAt = nil
        
    }
    
    private func extractInFlightTranscript(currentSnapshot: String,
                                           finalizedTranscript: String) -> String {
        
        let snapshot = currentSnapshot.trimmed()
        let finalized = finalizedTranscript.trimmed()
        
        guard !snapshot.isEmpty else {
            return ""
        }
        
        guard !finalized.isEmpty else {
            return snapshot
        }
        
        if snapshot.hasPrefix(finalized) {
            return String(snapshot.dropFirst(finalized.count)).trimmed()
        }
        
        if finalized.contains(snapshot) {
            return ""
        }
        
        let overlapWordCount = self.longestSuffixPrefixWordOverlap(
            lhs: finalized,
            rhs: snapshot
        )
        
        guard overlapWordCount > 0 else {
            return snapshot
        }
        
        let snapshotWords = snapshot.wordTokens
        let remainingWords = snapshotWords.dropFirst(overlapWordCount)
        
        guard !remainingWords.isEmpty else {
            return ""
        }
        
        return remainingWords.joined(separator: " ")
        
    }
    
    private func mergeTranscript(existingTranscript: String,
                                 incomingTranscript: String) -> String {
        
        let existing = existingTranscript.trimmed()
        let incoming = incomingTranscript.trimmed()
        
        guard !incoming.isEmpty else {
            return existing
        }
        
        guard !existing.isEmpty else {
            return incoming
        }
        
        guard existing != incoming else {
            return existing
        }
        
        if incoming.hasPrefix(existing) {
            return incoming
        }
        
        if existing.hasPrefix(incoming) {
            return existing
        }
        
        if incoming.contains(existing) {
            return incoming
        }
        
        if existing.contains(incoming) {
            return existing
        }
        
        return self.overlapAwareJoin(lhs: existing, rhs: incoming)
        
    }
    
    private func overlapAwareJoin(lhs: String,
                                  rhs: String) -> String {
        
        let overlapWordCount = self.longestSuffixPrefixWordOverlap(lhs: lhs, rhs: rhs)
        
        guard overlapWordCount > 0 else {
            return self.spaceAwareJoin(lhs: lhs, rhs: rhs)
        }
        
        let rhsWords = rhs.wordTokens
        let remainingWords = rhsWords.dropFirst(overlapWordCount)
        
        guard !remainingWords.isEmpty else {
            return lhs
        }
        
        return self.spaceAwareJoin(
            lhs: lhs,
            rhs: remainingWords.joined(separator: " ")
        )
        
    }
    
    private func longestSuffixPrefixWordOverlap(lhs: String,
                                                rhs: String) -> Int {
        
        let lhsWords = lhs.wordTokens
        let rhsWords = rhs.wordTokens
        
        let maxOverlap = min(lhsWords.count, rhsWords.count)
        
        guard maxOverlap > 0 else {
            return 0
        }
        
        for overlapCount in stride(from: maxOverlap, through: 1, by: -1) {
            
            if Array(lhsWords.suffix(overlapCount)) == Array(rhsWords.prefix(overlapCount)) {
                return overlapCount
            }
            
        }
        
        return 0
        
    }
    
    private func wordCount(_ transcript: String) -> Int {
        return transcript.wordTokens.count
        
    }
    
    private func spaceAwareJoin(lhs: String,
                                rhs: String) -> String {
        
        guard !lhs.isEmpty else {
            return rhs
        }
        
        guard !rhs.isEmpty else {
            return lhs
        }
        
        if lhs.hasSuffix(" ") || lhs.hasSuffix("\n") {
            return lhs + rhs
        }
        
        if let firstCharacter = rhs.first,
           [".", ",", "!", "?", ";", ":"].contains(firstCharacter) {
            return lhs + rhs
        }
        
        return "\(lhs) \(rhs)"
        
    }
    
    private func isRecordingAudioFileURL(_ url: URL) -> Bool {
        return self.recordingAudioExtensions.contains(url.pathExtension.lowercased())
    }
    
    private func transcriptFileURL(for recordingURL: URL) -> URL {
        return recordingURL.deletingPathExtension().appendingPathExtension("txt")
    }
    
    private func loadTranscript(for recordingURL: URL) -> String? {
        
        let transcriptURL = self.transcriptFileURL(for: recordingURL)
        
        guard self.fileManager.fileExists(atPath: transcriptURL.path()) else {
            return nil
        }
        
        return try? String(contentsOf: transcriptURL, encoding: .utf8)
        
    }
    
    private func persistTranscriptIfAvailable(for recordingURL: URL?) {
        
        guard let recordingURL else {
            return
        }
        
        let transcript = !self.finalTranscript.trimmed().isEmpty
        ? self.finalTranscript.trimmed()
        : self.partialTranscript.trimmed()
        
        guard !transcript.isEmpty else {
            return
        }
        
        let transcriptURL = self.transcriptFileURL(for: recordingURL)
        
        do {
            try transcript.write(to: transcriptURL, atomically: true, encoding: .utf8)
        }
        catch {
            self.logError(
                title: "Transcript Save Error",
                message: error.localizedDescription
            )
        }
        
    }
    
    private func removeTranscriptFileIfNeeded(for recordingURL: URL) throws {
        
        let transcriptURL = self.transcriptFileURL(for: recordingURL)
        
        guard self.fileManager.fileExists(atPath: transcriptURL.path()) else {
            return
        }
        
        try self.fileManager.removeItem(at: transcriptURL)
        
    }
    
    private nonisolated static func installInputTap(inputNode: AVAudioInputNode,
                                                    inputFormat: AVAudioFormat,
                                                    recordingFile: AVAudioFile,
                                                    recognitionRequest: SFSpeechAudioBufferRecognitionRequest?,
                                                    service: VoiceTranscriptionService) {
        
        inputNode.installTap(onBus: 0,
                             bufferSize: 1024,
                             format: inputFormat) { [weak service] buffer, _ in

            do {
                try recordingFile.write(from: buffer)
            }
            catch {
                
                let errorMessage = error.localizedDescription
                
                Task { @MainActor [weak service] in
                    service?.error = .fileWriteFailed(message: errorMessage)
                }
                
            }
            
            recognitionRequest?.append(buffer)
            
        }
        
    }
    
    private nonisolated static func makeRecognitionTask(speechRecognizer: SFSpeechRecognizer,
                                                        request: SFSpeechAudioBufferRecognitionRequest,
                                                        recognitionCycleID: UUID,
                                                        service: VoiceTranscriptionService) -> SFSpeechRecognitionTask {
        
        return speechRecognizer.recognitionTask(with: request) { [weak service] result, error in
            
            let partialTranscript = result?.bestTranscription.formattedString
            let isFinal = result?.isFinal ?? false
            let errorMessage = error?.localizedDescription
            
            Task { @MainActor [weak service] in
                service?.handleRecognitionCallback(
                    partialTranscript: partialTranscript,
                    isFinal: isFinal,
                    errorMessage: errorMessage,
                    recognitionCycleID: recognitionCycleID
                )
            }
            
        }
        
    }
    
    private func tearDownAudioPipeline() {
        
        if self.audioEngine.isRunning {
            self.audioEngine.stop()
        }
        
        self.audioEngine.inputNode.removeTap(onBus: 0)
        self.recognitionRequest?.endAudio()
        self.recognitionTask?.cancel()
        
        self.recognitionTask = nil
        self.recognitionRequest = nil
        self.recordingFile = nil
        self.speechRecognizer = nil
        self.activeRecognitionCycleID = nil
        self.isRecording = false
        
        do {
            try self.audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        }
        catch {
            
            self.logError(
                title: "Audio Session Tear Down Error",
                message: error.localizedDescription
            )
            
        }
        
    }
    
}

private extension String {
    
    var wordTokens: [String] {
        return self.split(whereSeparator: \.isWhitespace).map(String.init)
    }
    
}
