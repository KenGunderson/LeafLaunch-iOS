//
//  VoiceTranscriptionServiceProtocol.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/4/26.
//

import Combine
import Foundation

struct VoiceRecordingFile: Hashable, Identifiable {
    
    let url: URL
    let createdAt: Date
    let sizeInBytes: Int64
    let transcript: String?
    
    init(url: URL,
         createdAt: Date,
         sizeInBytes: Int64,
         transcript: String? = nil) {
        
        self.url = url
        self.createdAt = createdAt
        self.sizeInBytes = sizeInBytes
        self.transcript = transcript
        
    }
    
    var id: String {
        return self.url.absoluteString
    }
    
    var fileName: String {
        return self.url.lastPathComponent
    }
    
    var formattedCreatedAt: String {
        return self.createdAt.formatted(
            .dateTime
                .year()
                .month()
                .day()
                .hour()
                .minute()
        )
    }
    
    var formattedSize: String {
        return ByteCountFormatter.string(
            fromByteCount: self.sizeInBytes,
            countStyle: .file
        )
    }
    
    var normalizedTranscript: String? {
        
        guard let transcript = self.transcript?.trimmed(),
              !transcript.isEmpty else {
            return nil
        }
        
        return transcript
        
    }
    
    var hasTranscript: Bool {
        return self.normalizedTranscript != nil
    }
    
}

enum VoiceTranscriptionError: Error, Equatable {
    
    case missingMicrophonePermission
    case missingSpeechPermission
    case onDeviceRecognitionUnsupported
    case speechRecognizerUnavailable
    case recordingAlreadyActive
    case recordingNotActive
    case audioSessionConfigurationFailed(message: String)
    case recordingInitializationFailed(message: String)
    case fileWriteFailed(message: String)
    case transcriptionFailed(message: String)
    case fileOperationFailed(message: String)
    
    var title: String {
        switch self {
        case .missingMicrophonePermission: return "Microphone Permission Missing"
        case .missingSpeechPermission: return "Speech Permission Missing"
        case .onDeviceRecognitionUnsupported: return "On-Device Recognition Unsupported"
        case .speechRecognizerUnavailable: return "Speech Recognizer Unavailable"
        case .recordingAlreadyActive: return "Recording Already Active"
        case .recordingNotActive: return "Recording Not Active"
        case .audioSessionConfigurationFailed: return "Audio Session Error"
        case .recordingInitializationFailed: return "Recording Initialization Error"
        case .fileWriteFailed: return "Recording File Write Error"
        case .transcriptionFailed: return "Transcription Error"
        case .fileOperationFailed: return "File Operation Error"
        }
    }
    
    var message: String {
        switch self {
        case .missingMicrophonePermission: return "Microphone permission is required before starting a recording."
        case .missingSpeechPermission: return "Speech recognition permission is required before starting a recording."
        case .onDeviceRecognitionUnsupported: return "On-device speech recognition is not available on this device or locale."
        case .speechRecognizerUnavailable: return "Speech recognizer is currently unavailable."
        case .recordingAlreadyActive: return "A recording session is already active."
        case .recordingNotActive: return "No active recording session exists."
        case .audioSessionConfigurationFailed(let message): return message
        case .recordingInitializationFailed(let message): return message
        case .fileWriteFailed(let message): return message
        case .transcriptionFailed(let message): return message
        case .fileOperationFailed(let message): return message
        }
    }
    
}

protocol VoiceTranscriptionServiceProtocol: AnyObject, Loggable {
    
    var isRecording: Bool { get }
    var isRecordingPublisher: AnyPublisher<Bool, Never> { get }
    
    var isTranscribing: Bool { get }
    var isTranscribingPublisher: AnyPublisher<Bool, Never> { get }
    
    var partialTranscript: String { get }
    var partialTranscriptPublisher: AnyPublisher<String, Never> { get }
    
    var finalTranscript: String { get }
    var finalTranscriptPublisher: AnyPublisher<String, Never> { get }
    
    var lastRecordingURL: URL? { get }
    var lastRecordingURLPublisher: AnyPublisher<URL?, Never> { get }
    
    var error: VoiceTranscriptionError? { get }
    var errorPublisher: AnyPublisher<VoiceTranscriptionError?, Never> { get }
    
    var tempRecordings: [VoiceRecordingFile] { get }
    var tempRecordingsPublisher: AnyPublisher<[VoiceRecordingFile], Never> { get }
    
    func startRecording() throws
    func stopRecording() throws
    func clearCurrentSession()
    
    func listTempRecordings() -> [VoiceRecordingFile]
    func deleteTempFile(at url: URL) throws
    func deleteAllTempFiles() throws
    
}
