//
//  AboutUsScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/12/25.
//

import SwiftUI
import Charts

struct AboutUsScreen: GPView {
    
    @StateObject var viewModel: AboutUsViewModel
    @Environment(NavigationService.self) private var navigationService
    
    @State private var onAppearAnimation: Bool = false
            
    var body: some View {
        
        AppHeaderScrollView(horizontalPadding: .medium) {
            headerView()
        } scrollViewContent: {
            content()
        }
        
        // Lifecycle
        
        .onFirstAppear { [weak viewModel] in
            
            viewModel?
                .handleFirstAppear()
            
            viewModel?
                .setup(navigationService: self.navigationService)
            
        }
        .task {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.onAppearAnimation = true
            }
            
        }

    }
    
    @ViewBuilder
    private func headerView() -> some View {
        
        NavBarView(
            title: "About Us",
            leftButtonView: (
                NavBarButton(style: .back) {
                    self.viewModel.dismiss()
                }
            ).asAnyView()
        )
        
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        let config = Constants.StaggerAnimation.config(interitemSpacing: 16)
        
        StaggeredView(config: config) {
            
            if self.onAppearAnimation {
                
                Image(systemName: "person.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 48)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(self.viewModel.tagLine())
                    .appFont(with: .TITLE_6)
                    .foregroundStyle(.text(.title))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .padding(.top, .small)
                
                attributedMessage()
                    .multilineTextAlignment(.leading)
                
            }
            
        }
        .padding(.top, .small)
        
    }
    
    @ViewBuilder
    private func attributedMessage() -> some View {
                
        AttributedText {

            Text("GlowPro")
                .foregroundStyle(.foreground(.primary))
                .font(Style.shared.font(.TITLE_5))

            Text(" is the simplest and most affordable way to create and organize your client photos and treatment notes without replacing your current scheduling system. From solo practitioners to large scale businesses, ")

            Text("GlowPro")
                .foregroundStyle(.foreground(.primary))
                .font(Style.shared.font(.TITLE_5))

            Text(" helps you to save time and make your business more efficient - all while you focus on making your clients glow.\n\n")

            Text("GlowPro")
                .foregroundStyle(.foreground(.primary))
                .font(Style.shared.font(.TITLE_5))

            Text(" was created by practitioners, for practitioners. One of our co-founders, ")

            Text("Robert")
                .font(Style.shared.font(.TITLE_5))
                .foregroundStyle(.foreground(.primary))

            Text(", owned and operated a successful med-spa and experienced first-hand the daily challenges that come with running a growing practice—juggling clients, photos, notes, and follow-ups across disconnected tools. He saw how much time was lost to technology that didn’t quite fit the unique workflow of aestheticians and injectors.\n\nWe came together to build ")

            Text("GlowPro")
                .foregroundStyle(.foreground(.primary))
                .font(Style.shared.font(.TITLE_5))

            Text(" as a better way forward—a tool designed to help every practitioner flourish. ")

            Text("GlowPro")
                .foregroundStyle(.foreground(.primary))
                .font(Style.shared.font(.TITLE_5))

            Text(" makes it simple to capture and organize before-and-after photos, store treatment notes, and manage multiple locations—all without replacing your existing booking system.\n\nFrom solo providers to multi-location practices, ")

            Text("GlowPro")
                .foregroundStyle(.foreground(.primary))
                .font(Style.shared.font(.TITLE_5))

            Text(" saves time, streamlines operations, and elevates client trust—so you can focus on what matters most: making your clients glow.")

        }
        .foregroundStyle(.text(.title))
        .font(Style.shared.font(.BODY_4))
        
    }
    
}

#Preview {
    
    AboutUsScreen(
        viewModel: mockResolve(AboutUsViewModel.self)
    )
    .withMockServices()
    
}
