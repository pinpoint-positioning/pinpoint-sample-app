import SwiftUI
import MessageUI
import SDK

struct LogView: View {
    let logFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("log.txt")
    
    @State private var logFileContents = ""
    @State private var isShowingMailView = false
    
    var body: some View {
        VStack {
            Spacer()
            Text("Logfile")
                .fontWeight(.bold)
            Divider()
            
            if logFileContents == "" {
                Spacer()
                Text("No entries in logfile")
                Spacer()
            } else {
                ScrollView {
                    TextField("", text: $logFileContents,axis: .vertical)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .font(.system(size: 10))
                        .disabled(true)
                }
                .padding()
            }
   
            
            
            HStack {
                Button("Send LogFile via mail") {
                    isShowingMailView = true
                    
                }
                .buttonStyle(.bordered)
                
                Button("Clear Log") {
                    
                    API.shared.clearLogFile()
                    logFileContents = ""
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)
                
            }
        }
        .padding()
        .task {
            do {
                logFileContents = try String(contentsOf: logFilePath)
                
            } catch {
                print("Error reading log file: \(error.localizedDescription)")
            }
        }
        .sheet(isPresented: $isShowingMailView) {
            MailView(logFilePath: logFilePath, isShowing: $isShowingMailView)
        }
    }
}


struct MailView: UIViewControllerRepresentable {
    let logFilePath: URL
    @Binding var isShowing: Bool
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = context.coordinator
        
        do {
            let logFileContents = try Data(contentsOf: logFilePath)
            mailComposeVC.addAttachmentData(logFileContents, mimeType: "text/plain", fileName: "log.txt")
        } catch {
            print("Error adding attachment: \(error.localizedDescription)")
        }
        
        return mailComposeVC
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: UIViewControllerRepresentableContext<MailView>) {
        // Do nothing
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailView
        
        init(_ parent: MailView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.isShowing = false
        }
    }
}
