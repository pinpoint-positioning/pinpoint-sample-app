import SwiftUI
import Foundation
import SDK

struct LogView: View {
    
    @State private var logText: String = ""
    
    var body: some View {
        VStack {
            Button(action: {
                Logger.shared.log(error: "An error occurred")
                logText = Logger.shared.readLogFile() ?? ""
            }, label: {
                Text("Log Error")
            })
            Button(action: {
                Logger.shared.openLogFile()
            }, label: {
                Text("Open Log File")
            })
            Button(action: {
                Logger.shared.saveLogFile()
            }, label: {
                Text("Save Log File")
            })
            Text(logText)
        }
    }
}

struct LogView_Previes: PreviewProvider {
    static var previews: some View {
        LogView()
    }
}
