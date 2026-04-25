//
//  DevVoiceViewModel.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/4/26.
//

import SwiftUI
import Combine
import AVFoundation

final class DevVoiceViewModel: ViewModel {
    
    internal let loggerName: String = "DEV"
    internal let loggerEmoji: String = "🔧"
    
    private let analyticsService: AnalyticsServiceProtocol
    private let authService: AuthServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let environmentService: EnvironmentServiceProtocol
    private let voiceTranscriptionService: VoiceTranscriptionServiceProtocol
    private let microphonePermissionService: MicrophonePermissionServiceProtocol
    private let speechRecognitionPermissionService: SpeechRecognitionPermissionServiceProtocol
    
    private weak var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    private let playbackAudioSession: AVAudioSession
    private var playbackPlayer: AVPlayer?
    private var playbackCompletionObserver: NSObjectProtocol?
    
    @Published private(set) var isRecording: Bool = false
    @Published private(set) var isTranscribing: Bool = false
    @Published private(set) var partialTranscript: String = ""
    @Published private(set) var finalTranscript: String = ""
    @Published private(set) var lastRecordingURL: URL?
    @Published private(set) var currentError: VoiceTranscriptionError?
    @Published private(set) var tempRecordings: [VoiceRecordingFile] = []
    
    @Published private(set) var microphonePermissionGranted: Bool = false
    @Published private(set) var shouldPromptForMicrophonePermission: Bool = false
    @Published private(set) var speechPermissionGranted: Bool = false
    @Published private(set) var shouldPromptForSpeechPermission: Bool = false
    
    @Published private(set) var currentPlaybackFileID: String?
    @Published private(set) var isPlaybackPaused: Bool = false
    
    var stateTitle: String {
        if self.isRecording {
            return "Recording"
        }
        
        if self.isTranscribing {
            return "Transcribing"
        }
        
        if !self.finalTranscript.trimmed().isEmpty {
            return "Completed"
        }
        
        if self.currentError != nil {
            return "Error"
        }
        
        return "Idle"
    }
    
    var canStartRecording: Bool {
        return !self.isRecording &&
        self.microphonePermissionGranted &&
        self.speechPermissionGranted
    }
    
    var canStopRecording: Bool {
        return self.isRecording
    }
    
    init(analyticsService: AnalyticsServiceProtocol,
         authService: AuthServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         environmentService: EnvironmentServiceProtocol,
         voiceTranscriptionService: VoiceTranscriptionServiceProtocol,
         microphonePermissionService: MicrophonePermissionServiceProtocol,
         speechRecognitionPermissionService: SpeechRecognitionPermissionServiceProtocol) {
        
        self.analyticsService = analyticsService
        self.authService = authService
        self.viewLifecycleService = viewLifecycleService
        self.environmentService = environmentService
        self.voiceTranscriptionService = voiceTranscriptionService
        self.microphonePermissionService = microphonePermissionService
        self.speechRecognitionPermissionService = speechRecognitionPermissionService
        self.playbackAudioSession = .sharedInstance()
        
        self.logInit()
        
    }
    
    isolated deinit {
        
        self.stopPlaybackAndResetState()
        self.logDeinit()
        
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func handleFirstAppear() {
        
        track()
        bindSubscribers()
        syncStateFromServices()
        
    }
    
    func dismiss() {
        
        self.navigationService?
            .pop()
        
    }
    
    func requestMicrophonePermission() {
        
        self.log(message: "Request microphone permission tapped")
        self.microphonePermissionService.requestPermission()
        
    }
    
    func requestSpeechPermission() {
        
        self.log(message: "Request speech recognition permission tapped")
        self.speechRecognitionPermissionService.requestPermission()
        
    }
    
    func startRecording() {
        
        self.log(message: "Start voice recording tapped")
        self.stopPlaybackAndResetState()
        
        do {
            try self.voiceTranscriptionService.startRecording()
        }
        catch let error as VoiceTranscriptionError {
            
            self.currentError = error
            self.logError(
                title: error.title,
                message: error.message
            )
            
        }
        catch {
            
            self.logError(
                title: "Start Recording Error",
                message: error.getMessageForError()
            )
            
        }
        
    }
    
    func stopRecording() {
        
        self.log(message: "Stop voice recording tapped")
        
        do {
            try self.voiceTranscriptionService.stopRecording()
        }
        catch let error as VoiceTranscriptionError {
            
            self.currentError = error
            self.logError(
                title: error.title,
                message: error.message
            )
            
        }
        catch {
            
            self.logError(
                title: "Stop Recording Error",
                message: error.getMessageForError()
            )
            
        }
        
    }
    
    func clearSession() {
        
        self.log(message: "Clear voice session tapped")
        self.stopPlaybackAndResetState()
        self.voiceTranscriptionService.clearCurrentSession()
        
    }
    
    func deleteAllTempFiles() {
        
        self.log(message: "Delete all voice temp files tapped")
        self.stopPlaybackAndResetState()
        
        do {
            try self.voiceTranscriptionService.deleteAllTempFiles()
        }
        catch let error as VoiceTranscriptionError {
            
            self.currentError = error
            self.logError(
                title: error.title,
                message: error.message
            )
            
        }
        catch {
            
            self.logError(
                title: "Delete Temp Files Error",
                message: error.getMessageForError()
            )
            
        }
        
    }
    
    func deleteTempFile(_ file: VoiceRecordingFile) {
        
        self.log(message: "Delete temp file tapped: \(file.fileName)")
        
        if self.currentPlaybackFileID == file.id {
            self.stopPlaybackAndResetState()
        }
        
        do {
            try self.voiceTranscriptionService.deleteTempFile(at: file.url)
        }
        catch let error as VoiceTranscriptionError {
            
            self.currentError = error
            self.logError(
                title: error.title,
                message: error.message
            )
            
        }
        catch {
            
            self.logError(
                title: "Delete Temp File Error",
                message: error.getMessageForError()
            )
            
        }
        
    }
    
    private func syncStateFromServices() {
        
        self.isRecording = self.voiceTranscriptionService.isRecording
        self.isTranscribing = self.voiceTranscriptionService.isTranscribing
        self.partialTranscript = self.voiceTranscriptionService.partialTranscript
        self.finalTranscript = self.voiceTranscriptionService.finalTranscript
        self.lastRecordingURL = self.voiceTranscriptionService.lastRecordingURL
        self.currentError = self.voiceTranscriptionService.error
        self.tempRecordings = self.voiceTranscriptionService.listTempRecordings()
        self.validatePlaybackState(with: self.tempRecordings)
        
        self.microphonePermissionGranted = self.microphonePermissionService.permissionGranted
        self.shouldPromptForMicrophonePermission = self.microphonePermissionService.shouldPromptForPermissions
        self.speechPermissionGranted = self.speechRecognitionPermissionService.permissionGranted
        self.shouldPromptForSpeechPermission = self.speechRecognitionPermissionService.shouldPromptForPermissions
        
    }
    
    private func bindSubscribers() {
        
        self.cancelBag = CancelBag()
        
        self.voiceTranscriptionService
            .isRecordingPublisher
            .receiveOnMain()
            .sink { [weak self] isRecording in
                self?.isRecording = isRecording
            }
            .store(in: &self.cancelBag)
        
        self.voiceTranscriptionService
            .isTranscribingPublisher
            .receiveOnMain()
            .sink { [weak self] isTranscribing in
                self?.isTranscribing = isTranscribing
            }
            .store(in: &self.cancelBag)
        
        self.voiceTranscriptionService
            .partialTranscriptPublisher
            .receiveOnMain()
            .sink { [weak self] transcript in
                self?.partialTranscript = transcript
            }
            .store(in: &self.cancelBag)
        
        self.voiceTranscriptionService
            .finalTranscriptPublisher
            .receiveOnMain()
            .sink { [weak self] transcript in
                self?.finalTranscript = transcript
                
                if !transcript.trimmed().isEmpty {
                    self?.partialTranscript = ""
                }
            }
            .store(in: &self.cancelBag)
        
        self.voiceTranscriptionService
            .lastRecordingURLPublisher
            .receiveOnMain()
            .sink { [weak self] url in
                self?.lastRecordingURL = url
            }
            .store(in: &self.cancelBag)
        
        self.voiceTranscriptionService
            .errorPublisher
            .receiveOnMain()
            .sink { [weak self] error in
                self?.currentError = error
            }
            .store(in: &self.cancelBag)
        
        self.voiceTranscriptionService
            .tempRecordingsPublisher
            .receiveOnMain()
            .sink { [weak self] files in
                self?.tempRecordings = files
                self?.validatePlaybackState(with: files)
            }
            .store(in: &self.cancelBag)
        
        self.microphonePermissionService
            .permissionGrantedPublisher
            .receiveOnMain()
            .sink { [weak self] isGranted in
                self?.microphonePermissionGranted = isGranted
            }
            .store(in: &self.cancelBag)
        
        self.microphonePermissionService
            .shouldPromptForPermissionsPublisher
            .receiveOnMain()
            .sink { [weak self] shouldPrompt in
                self?.shouldPromptForMicrophonePermission = shouldPrompt
            }
            .store(in: &self.cancelBag)
        
        self.speechRecognitionPermissionService
            .permissionGrantedPublisher
            .receiveOnMain()
            .sink { [weak self] isGranted in
                self?.speechPermissionGranted = isGranted
            }
            .store(in: &self.cancelBag)
        
        self.speechRecognitionPermissionService
            .shouldPromptForPermissionsPublisher
            .receiveOnMain()
            .sink { [weak self] shouldPrompt in
                self?.shouldPromptForSpeechPermission = shouldPrompt
            }
            .store(in: &self.cancelBag)
        
        self.viewLifecycleService
            .onDidBecomeActive
            .dropFirst()
            .receiveOnMain()
            .sink { [weak self] _ in
                self?.tempRecordings = self?.voiceTranscriptionService.listTempRecordings() ?? []
            }
            .store(in: &self.cancelBag)
        
    }
    
    func togglePlayback(for file: VoiceRecordingFile) {
        
        if self.currentPlaybackFileID == file.id {
            
            if self.isPlaybackPaused {
                self.resumePlayback()
            }
            else {
                self.pausePlayback()
            }
            
            return
            
        }
        
        self.startPlayback(for: file)
        
    }
    
    func playbackButtonTitle(for file: VoiceRecordingFile) -> String {
        
        if self.currentPlaybackFileID != file.id {
            return "Play"
        }
        
        return self.isPlaybackPaused ? "Resume" : "Pause"
        
    }
    
    func playbackButtonIconName(for file: VoiceRecordingFile) -> String {
        
        if self.currentPlaybackFileID != file.id {
            return "play.fill"
        }
        
        return self.isPlaybackPaused ? "play.fill" : "pause.fill"
        
    }
    
    func isPlaybackActive(for file: VoiceRecordingFile) -> Bool {
        return self.currentPlaybackFileID == file.id && !self.isPlaybackPaused
    }
    
    func isPlaybackPaused(for file: VoiceRecordingFile) -> Bool {
        return self.currentPlaybackFileID == file.id && self.isPlaybackPaused
    }
    
    private func startPlayback(for file: VoiceRecordingFile) {
        
        self.stopPlaybackAndResetState()
        
        guard self.configurePlaybackAudioSession() else {
            return
        }
        
        let playerItem = AVPlayerItem(url: file.url)
        let player = AVPlayer(playerItem: playerItem)
        
        self.observePlaybackCompletion(for: playerItem)
        
        self.playbackPlayer = player
        self.currentPlaybackFileID = file.id
        self.isPlaybackPaused = false
        
        player.play()
        
    }
    
    private func pausePlayback() {
        
        self.playbackPlayer?.pause()
        self.isPlaybackPaused = true
        
    }
    
    private func resumePlayback() {
        
        self.playbackPlayer?.play()
        self.isPlaybackPaused = false
        
    }
    
    private func stopPlaybackAndResetState() {
        
        self.playbackPlayer?.pause()
        self.playbackPlayer?.replaceCurrentItem(with: nil)
        
        self.playbackPlayer = nil
        self.currentPlaybackFileID = nil
        self.isPlaybackPaused = false
        
        self.clearPlaybackCompletionObserver()
        self.deactivatePlaybackAudioSessionIfNeeded()
        
    }
    
    private func configurePlaybackAudioSession() -> Bool {
        
        do {
            
            try self.playbackAudioSession.setCategory(.playback, mode: .default, options: [.duckOthers])
            try self.playbackAudioSession.setActive(true, options: .notifyOthersOnDeactivation)
            return true
            
        }
        catch {
            
            self.currentError = .audioSessionConfigurationFailed(message: error.localizedDescription)
            self.logError(
                title: "Playback Audio Session Error",
                message: error.localizedDescription
            )
            
            return false
            
        }
        
    }
    
    private func deactivatePlaybackAudioSessionIfNeeded() {
        
        do {
            try self.playbackAudioSession.setActive(false, options: .notifyOthersOnDeactivation)
        }
        catch {
            self.logError(
                title: "Playback Audio Session Deactivation Error",
                message: error.localizedDescription
            )
        }
        
    }
    
    private func observePlaybackCompletion(for item: AVPlayerItem) {
        
        self.clearPlaybackCompletionObserver()
        
        self.playbackCompletionObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            
            Task { @MainActor [weak self] in
                self?.stopPlaybackAndResetState()
            }
            
        }
        
    }
    
    private func clearPlaybackCompletionObserver() {
        
        guard let playbackCompletionObserver = self.playbackCompletionObserver else {
            return
        }
        
        NotificationCenter.default.removeObserver(playbackCompletionObserver)
        self.playbackCompletionObserver = nil
        
    }
    
    private func validatePlaybackState(with files: [VoiceRecordingFile]) {
        
        guard let currentPlaybackFileID = self.currentPlaybackFileID else {
            return
        }
        
        let fileStillExists = files.contains { file in
            file.id == currentPlaybackFileID
        }
        
        guard !fileStillExists else {
            return
        }
        
        self.stopPlaybackAndResetState()
        
    }
    
}

extension DevVoiceViewModel {
    
    func track() {
        self.analyticsService.track(screen: .devSettings(.voice))
    }
    
}
