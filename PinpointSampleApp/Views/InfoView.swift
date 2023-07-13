//
//  InfoView.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 21.06.23.
//

import SwiftUI

struct InfoView: View {
    func version() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "\(version) build \(build)"
    }
    
    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }

  
    
    
    
    var body: some View {
        
        let currentDate = Date()
        ScrollView{
            VStack (alignment: .leading){

                Text("Disclaimer: PinPoint Demo App")
                    .font(.headline)
                    .padding(.all)
                Text("""
            This is a draft....
                 Please read this disclaimer carefully before using the PinPoint Demo App (the "App"), developed by PinPoint ("the Company"). By installing and using this App, you agree to the terms and conditions stated herein.
            
                 Accuracy of Information: The PinPoint Demo App utilizes Bluetooth and location services to provide location-based features. While the Company endeavors to provide accurate and up-to-date information, we cannot guarantee the accuracy, completeness, or reliability of the data obtained through these services. The App relies on third-party data sources and the functionality of your device's Bluetooth and location services, which may occasionally result in inaccuracies or limitations.
                 Privacy and Data Security: The App collects and processes location and Bluetooth data to facilitate its intended features. The Company prioritizes user privacy and takes precautions to protect your personal information in accordance with applicable data protection laws. However, the Company cannot guarantee the security of the data transmitted or stored on your device or through third-party services. By using the App, you acknowledge and accept the inherent risks associated with data transmission over the internet and through wireless networks.
                 Device Compatibility: The PinPoint Demo App is designed to work on compatible devices that support Bluetooth and location services. The Company does not guarantee that the App will function correctly on all devices or that all features will be available due to variations in hardware, operating systems, or other factors beyond our control.
                 Usage and Reliance: The PinPoint Demo App is a demonstration app intended for testing and evaluation purposes only. It may contain experimental features and functionalities that are subject to change without notice. The Company does not warrant or represent that the App is suitable for any specific purpose, and you acknowledge that your usage of the App is at your own risk.
                 Limitation of Liability: In no event shall the Company be liable for any direct, indirect, incidental, consequential, or punitive damages arising out of or in connection with the use or inability to use the PinPoint Demo App. This includes, but is not limited to, damages for loss of data, profits, or business interruption, even if the Company has been advised of the possibility of such damages.
                 Modifications and Updates: The Company reserves the right to modify, suspend, or discontinue the PinPoint Demo App at any time without prior notice. The Company may also update this disclaimer periodically, and it is your responsibility to review the most current version when using the App.
                 By using the PinPoint Demo App, you acknowledge that you have read and understood this disclaimer and agree to its terms and conditions. If you do not agree with any part of this disclaimer, please refrain from using the App.
            
                 Date of Last Update: \(formatDate(date:currentDate))
            """)
                .padding(.all)
                
                
                HStack{
                    
                    Text("Version: ")
                    Spacer()
                    Text(version())
                    
                }
                
                HStack{
                    
                    Text("Compatible Tracelet Firmware: ")
                    Spacer()
                    Text("tbd")
                }
                
                Spacer()
            }
        }
        .padding(.all)
        
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
    }
}
