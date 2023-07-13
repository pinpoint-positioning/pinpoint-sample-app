//
//  ConsoleTextView.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 09.03.23.
//

import SwiftUI
 
struct ConsoleTextView: UIViewRepresentable {
    
    var text = ""
    var autoScroll: Bool
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 12)
        textView.autocapitalizationType = .sentences
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.isSelectable = false
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        
        uiView.text += text
        uiView.font = UIFont.systemFont(ofSize: 12)
        if (autoScroll)
        {
            // Estimated number of chars. Needs to be made in better way
            if (uiView.text.count > 200) {
                let point = CGPoint(x: 0.0, y: (uiView.contentSize.height - uiView.bounds.height))
                uiView.setContentOffset(point, animated: true)
            }
        }
    }

    
    struct ConsoleTextView_Previews: PreviewProvider {
        static var previews: some View {
            ConsoleTextView(autoScroll: false)
                .previewLayout(.sizeThatFits)
        }
    }
}
