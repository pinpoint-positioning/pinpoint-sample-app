//
//  Buttons.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 09.03.23.
//

import SwiftUI

struct Buttons {
    struct FilledButton: ButtonStyle {
        @State private var scale = 1.0
        @State var labelText = "Button"
        
        @Environment(\.isEnabled) private var isEnabled
        
        func makeBody(configuration: Configuration) -> some View {
            configuration
                .label
                .padding()
                
                .background(isEnabled ? Color(red: 253/255, green: 158/255, blue: 27/255): .gray)
                .opacity(configuration.isPressed ? 0.5 : 1.0)
                .cornerRadius(25)
     
        }
    }
}

