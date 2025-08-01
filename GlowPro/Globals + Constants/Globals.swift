//
//  Globals.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 4/22/25.
//

import Swinject
import SwiftUI

/// For fun; not actually keeping
nonisolated(unsafe) public var globalResolver: Resolver!

/// For fun; not actually keeping
nonisolated(unsafe) var globalNavigationService: NavigationService!

/// For fun; not actually keeping
nonisolated(unsafe) public var loggedEvents: [LogEvent] = []

/// For fun; not actually keeping
nonisolated(unsafe) public var apiLogResponses: [APILogResponse] = []
