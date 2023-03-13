//
//  ConsoleTextView.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 09.03.23.
//

import SwiftUI
 
struct ConsoleTextView: UIViewRepresentable {
    
    var text = ""
    var textStyle: UIFont.TextStyle
    var autoScroll: Bool
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        
        textView.font = UIFont.preferredFont(forTextStyle: textStyle)
        textView.autocapitalizationType = .sentences
        textView.backgroundColor = .lightGray
        textView.isEditable = false
        textView.isSelectable = false
        textView.layer.cornerRadius = 10
        
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text += text
        uiView.font = UIFont.preferredFont(forTextStyle: textStyle)
        // Scroll to last line, when filled (Autoscroll)
        if (autoScroll)
        {
        if (uiView.text.count > 400) {
            let point = CGPoint(x: 0.0, y: (uiView.contentSize.height - uiView.bounds.height))
            uiView.setContentOffset(point, animated: true)
        }
        }
        
    }
    mutating func clear(){
        self.text = ""
    }
}







struct ConsoleTextView_Previews: PreviewProvider {
    static var previews: some View {
        ConsoleTextView(textStyle: UIFont.TextStyle.body, autoScroll: false)
            .previewLayout(.sizeThatFits)
    }
}
