//
//  DevVoiceScreen.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/4/26.
//

import SwiftUI

struct DevVoiceScreen: GPView {
    
    @StateObject var viewModel: DevVoiceViewModel
    @Environment(NavigationService.self) private var navigationService
    
    var body: some View {
        
        AppHeaderScrollView(horizontalPadding: .medium) {
            
            headerView()
            
        } scrollViewContent: {
            
            content()
            
        }
        .onFirstAppear { [weak viewModel] in
            
            viewModel?
                .handleFirstAppear()
            
            viewModel?
                .setup(navigationService: self.navigationService)
            
        }
        .animation(.smooth(duration: 0.30), value: self.viewModel.stateTitle)
        .animation(.smooth(duration: 0.30), value: self.viewModel.partialTranscript)
        .animation(.smooth(duration: 0.30), value: self.viewModel.finalTranscript)
        .animation(.smooth(duration: 0.30), value: self.viewModel.tempRecordings)
        .animation(.smooth(duration: 0.30), value: self.viewModel.currentError)
        .animation(.smooth(duration: 0.30), value: self.viewModel.currentPlaybackFileID)
        .animation(.smooth(duration: 0.30), value: self.viewModel.isPlaybackPaused)
        
    }
    
    @ViewBuilder
    private func headerView() -> some View {
        
        NavBarView(
            title: "Voice",
            subtitle: "Record & Transcribe On Device",
            leftButtonView: (
                NavBarButton(style: .back) {
                    self.viewModel.dismiss()
                }
            ).asAnyView()
        )
        
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        VStack(spacing: Style.shared.spacing(.medium)) {
            
            permissionSection()
            controlSection()
            transcriptSection()
            tempFilesSection()
            
        }
        
    }
    
    @ViewBuilder
    private func permissionSection() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
            
            Text("Permissions")
                .appFont(with: .HEADER_2)
                .foregroundStyle(.text(.title))
            
            AppCardView {
                
                VStack(spacing: Style.shared.spacing(.small)) {
                    
                    permissionLineItem(
                        title: "Microphone",
                        isGranted: self.viewModel.microphonePermissionGranted,
                        shouldPrompt: self.viewModel.shouldPromptForMicrophonePermission
                    )
                    
                    CommonButton(
                        title: self.viewModel.shouldPromptForMicrophonePermission ? "Request Microphone" : "Request Again",
                        titleColor: .text(.button),
                        icon: .systemImage("mic.fill"),
                        action: {
                            self.viewModel.requestMicrophonePermission()
                        }
                    )
                    
                    permissionLineItem(
                        title: "Speech Recognition",
                        isGranted: self.viewModel.speechPermissionGranted,
                        shouldPrompt: self.viewModel.shouldPromptForSpeechPermission
                    )
                    
                    CommonButton(
                        title: self.viewModel.shouldPromptForSpeechPermission ? "Request Speech" : "Request Again",
                        titleColor: .text(.button),
                        icon: .systemImage("waveform.and.mic"),
                        action: {
                            self.viewModel.requestSpeechPermission()
                        }
                    )
                    
                }
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func controlSection() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
            
            Text("Controls")
                .appFont(with: .HEADER_2)
                .foregroundStyle(.text(.title))
            
            AppCardView {
                
                VStack(spacing: Style.shared.spacing(.small)) {
                    
                    lineItemView(
                        title: "State",
                        subtitle: self.viewModel.stateTitle
                    )
                    
                    lineItemView(
                        title: "Last Recording URL",
                        subtitle: self.viewModel.lastRecordingURL?.absoluteString ?? "Unavailable"
                    )
                    
                    CommonButton(
                        title: "Start Recording",
                        titleColor: .text(.button),
                        icon: .systemImage("record.circle.fill"),
                        backgroundStyle: self.viewModel.canStartRecording ? .foreground(.primary) : .background(.tertiary),
                        isEnabled: self.viewModel.canStartRecording,
                        action: {
                            self.viewModel.startRecording()
                        }
                    )
                    
                    CommonButton(
                        title: "Stop Recording",
                        titleColor: .text(.button),
                        icon: .systemImage("stop.circle.fill"),
                        backgroundStyle: self.viewModel.canStopRecording ? .palette(.error) : .background(.tertiary),
                        isEnabled: self.viewModel.canStopRecording,
                        action: {
                            self.viewModel.stopRecording()
                        }
                    )
                    
                    CommonButton(
                        title: "Clear Session",
                        titleColor: .text(.button),
                        icon: .systemImage("arrow.clockwise"),
                        action: {
                            self.viewModel.clearSession()
                        }
                    )
                    
                    CommonButton(
                        title: "Delete All Temp Files",
                        titleColor: .text(.button),
                        icon: .systemImage("trash.fill"),
                        backgroundStyle: .palette(.error),
                        action: {
                            self.viewModel.deleteAllTempFiles()
                        }
                    )
                    
                }
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func transcriptSection() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
            
            Text("Transcript")
                .appFont(with: .HEADER_2)
                .foregroundStyle(.text(.title))
            
            AppCardView {
                
                VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
                    
                    if let error = self.viewModel.currentError {
                        
                        VStack(alignment: .leading, spacing: Style.shared.spacing(.extraSmall)) {
                            
                            Text(error.title)
                                .appFont(with: .TITLE_5)
                                .foregroundStyle(.palette(.error))
                            
                            Text(error.message)
                                .appFont(with: .BODY_3)
                                .foregroundStyle(.text(.body))
                                .fixedSize(horizontal: false, vertical: true)
                            
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                        
                    }
                    
                    if !self.viewModel.partialTranscript.trimmed().isEmpty {
                        
                        lineItemView(
                            title: "Partial",
                            subtitle: self.viewModel.partialTranscript
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                        
                    }
                    
                    if !self.viewModel.finalTranscript.trimmed().isEmpty {
                        
                        lineItemView(
                            title: "Final Transcript",
                            subtitle: self.viewModel.finalTranscript
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        
                    }
                    
                    if self.viewModel.partialTranscript.trimmed().isEmpty &&
                        self.viewModel.finalTranscript.trimmed().isEmpty &&
                        self.viewModel.currentError == nil {
                        
                        Text("No transcript yet. Start recording to stream partial slivers, then finalize one full transcript on stop.")
                            .appFont(with: .TITLE_5)
                            .foregroundStyle(.text(.body))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .transition(.opacity)
                        
                    }
                    
                }
                .compositingGroup()
                .geometryGroup()
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func tempFilesSection() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
            
            Text("Temp Files")
                .appFont(with: .HEADER_2)
                .foregroundStyle(.text(.title))
            
            if self.viewModel.tempRecordings.isEmpty {
                
                AppCardView {
                    
                    Text("No temp files found.")
                        .appFont(with: .TITLE_5)
                        .foregroundStyle(.text(.body))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                }
                
            }
            else {
                
                LazyVStack(spacing: Style.shared.spacing(.small)) {
                    
                    ForEach(self.viewModel.tempRecordings, id: \.id) { file in
                        tempRecordingCard(file: file)
                    }
                    
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func tempRecordingCard(file: VoiceRecordingFile) -> some View {
        
        AppCardView {
            
            VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
                
                HStack(alignment: .top, spacing: Style.shared.spacing(.small)) {
                    
                    Image(systemName: "waveform")
                        .foregroundStyle(.foreground(.primary))
                    
                    VStack(alignment: .leading, spacing: Style.shared.spacing(.extraSmall)) {
                        
                        Text(file.fileName)
                            .appFont(with: .TITLE_5)
                            .foregroundStyle(.text(.title))
                            .lineLimit(2)
                        
                        Text("\(file.formattedCreatedAt) • \(file.formattedSize)")
                            .appFont(with: .BODY_3)
                            .foregroundStyle(.text(.body))
                            .lineLimit(1)
                        
                        if self.viewModel.isPlaybackActive(for: file) {
                            
                            Text("Now Playing")
                                .appFont(with: .BODY_2)
                                .foregroundStyle(.foreground(.primary))
                            
                        }
                        else if self.viewModel.isPlaybackPaused(for: file) {
                            
                            Text("Paused")
                                .appFont(with: .BODY_2)
                                .foregroundStyle(.text(.body))
                            
                        }
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                }
                
                HStack(spacing: Style.shared.spacing(.small)) {
                    
                    CommonButton(
                        title: self.viewModel.playbackButtonTitle(for: file),
                        titleColor: .text(.button),
                        icon: .systemImage(self.viewModel.playbackButtonIconName(for: file)),
                        backgroundStyle: playbackButtonBackgroundStyle(for: file),
                        action: {
                            self.viewModel.togglePlayback(for: file)
                        }
                    )
                    
                    CommonButton(
                        title: "Delete",
                        titleColor: .text(.button),
                        icon: .systemImage("trash.fill"),
                        backgroundStyle: .palette(.error),
                        action: {
                            self.viewModel.deleteTempFile(file)
                        }
                    )
                    
                }
                
                Divider()
                    .background(.background(.quinary))
                
                VStack(alignment: .leading, spacing: Style.shared.spacing(.extraSmall)) {
                    
                    Text("Full Transcript")
                        .appFont(with: .TITLE_4)
                        .foregroundStyle(.text(.title))
                    
                    Text(file.normalizedTranscript ?? "Transcript unavailable for this file.")
                        .appFont(with: .BODY_3)
                        .foregroundStyle(.text(.body))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                }
                
            }
            
        }
        
    }
    
    private func playbackButtonBackgroundStyle(for file: VoiceRecordingFile) -> ColorSource {
        
        if self.viewModel.isPlaybackActive(for: file) {
            return .foreground(.primary)
        }
        
        if self.viewModel.isPlaybackPaused(for: file) {
            return .background(.quaternary)
        }
        
        return .background(.tertiary)
        
    }
    
    private func permissionLineItem(title: String,
                                    isGranted: Bool,
                                    shouldPrompt: Bool) -> some View {
        
        let subtitle = isGranted
        ? "Allowed"
        : (shouldPrompt ? "Not Requested" : "Denied")
        
        return lineItemView(title: title, subtitle: subtitle)
        
    }
    
    private func lineItemView(title: String,
                              subtitle: String) -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.extraSmall)) {
            
            Text(title)
                .appFont(with: .TITLE_5)
                .foregroundStyle(.text(.title))
            
            Text(subtitle)
                .appFont(with: .BODY_3)
                .foregroundStyle(.text(.body))
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
}

#Preview {
    
    DevVoiceScreen(viewModel: mockResolve(DevVoiceViewModel.self))
        .withMockServices()
    
}
