//
//  UiElements.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 28.08.23.
//

import Foundation
import SwiftUI


struct ListItem: View {

    @State var header:String
    @Binding var subText:String
    @State var symbol:String

    var body: some View {

        HStack{
            Image(systemName: symbol)
                .frame(width: 20, height: 20)
            VStack(alignment: .leading) {

                Text(header)
                    .fontWeight(.semibold)
                Text(subText)
                    .fontWeight(.regular)
                    .font(.system(size: 12))
            }
        }
    }
}
