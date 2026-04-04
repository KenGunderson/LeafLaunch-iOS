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
    
    @Published private(set) var isRecording: Bool = false
    var isRecordingPublisher: AnyPublisher<Bool, Never> {
        return self.$isRecording.eraseToAnyPublisher()
    }
    
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
    
    @Published private(set) var lastRecordingURL: URL?
    var lastRecordingURLPublisher: AnyPublisher<URL?, Never> {
        return self.$lastRecordingURL.eraseToAnyPublisher()
    }
    
    @Published private(set) var error: VoiceTranscriptionError?
    var errorPublisher: AnyPublisher<VoiceTranscriptionError?, Never> {
        return self.$error.eraseToAnyPublisher()
    }
    
    @Published private(set) var tempRecordings: [VoiceRecordingFile] = []
    var tempRecordingsPublisher: AnyPublisher<[VoiceRecordingFile], Never> {
        return self.$tempRecordings.eraseToAnyPublisher()
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
            
            self.error = nil
            self.partialTranscript = ""
            self.finalTranscript = ""
            
            try ensureRecordingDirectoryExists()
            tearDownAudioPipeline()
            try configureAudioSession()
            
            let recordingURL = makeRecordingFileURL()
            
            let inputNode = self.audioEngine.inputNode
            let inputFormat = inputNode.outputFormat(forBus: 0)
            
            let request = SFSpeechAudioBufferRecognitionRequest()
            request.shouldReportPartialResults = true
            request.requiresOnDeviceRecognition = true
            
            let recordingSettings = recordingSettings(for: inputFormat)
            let recordingFile = try AVAudioFile(
                forWriting: recordingURL,
                settings: recordingSettings
            )
            
            inputNode.removeTap(onBus: 0)
            
            Self.installInputTap(
                inputNode: inputNode,
                inputFormat: inputFormat,
                request: request,
                recordingFile: recordingFile,
                service: self
            )
            
            self.recognitionTask = Self.makeRecognitionTask(
                speechRecognizer: speechRecognizer,
                request: request,
                service: self
            )
            
            self.speechRecognizer = speechRecognizer
            self.recognitionRequest = request
            self.recordingFile = recordingFile
            self.lastRecordingURL = recordingURL
            
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
        self.recordingFile = nil
        
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
        
        self.partialTranscript = ""
        self.finalTranscript = ""
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
    
    @MainActor
    private func handleRecognitionCallback(partialTranscript: String?,
                                           isFinal: Bool,
                                           errorMessage: String?) {
        
        if let partialTranscript {
            
            self.partialTranscript = partialTranscript
            
            if isFinal {
                
                self.finalTranscript = partialTranscript
                self.isTranscribing = false
                self.persistTranscriptIfAvailable(for: self.lastRecordingURL)
                self.refreshTempRecordings()
                
            }
            
        }
        
        if let errorMessage {
            
            self.isTranscribing = false
            
            if !self.finalTranscript.isEmpty {
                return
            }
            
            self.error = .transcriptionFailed(message: errorMessage)
            
        }
        
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
                                                    request: SFSpeechAudioBufferRecognitionRequest,
                                                    recordingFile: AVAudioFile,
                                                    service: VoiceTranscriptionService) {
        
        inputNode.installTap(onBus: 0,
                             bufferSize: 1024,
                             format: inputFormat) { [weak service] buffer, _ in
            
            request.append(buffer)
            
            do {
                try recordingFile.write(from: buffer)
            }
            catch {
                
                let errorMessage = error.localizedDescription
                
                Task { @MainActor [weak service] in
                    service?.error = .fileWriteFailed(message: errorMessage)
                }
                
            }
            
        }
        
    }
    
    private nonisolated static func makeRecognitionTask(
        speechRecognizer: SFSpeechRecognizer,
        request: SFSpeechAudioBufferRecognitionRequest,
        service: VoiceTranscriptionService
    ) -> SFSpeechRecognitionTask {
        
        return speechRecognizer.recognitionTask(with: request) { [weak service] result, error in
            
            let partialTranscript = result?.bestTranscription.formattedString
            let isFinal = result?.isFinal ?? false
            let errorMessage = error?.localizedDescription
            
            Task { @MainActor [weak service] in
                service?.handleRecognitionCallback(
                    partialTranscript: partialTranscript,
                    isFinal: isFinal,
                    errorMessage: errorMessage
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
