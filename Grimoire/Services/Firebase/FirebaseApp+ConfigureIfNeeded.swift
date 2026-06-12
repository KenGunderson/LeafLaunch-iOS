//
//  FirebaseApp+ConfigureIfNeeded.swift
//  Grimoire
//
//  Created by KC Gunderson on 6/3/26.
//

import FirebaseCore

extension FirebaseApp {

    static func configureIfNeeded() {

        guard FirebaseApp.app() == nil else { return }
        FirebaseApp.configure()

    }

}
