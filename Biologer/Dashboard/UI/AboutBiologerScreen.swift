//
//  AboutBiologerScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 27.6.21..
//

import SwiftUI

protocol AboutBiologerScreenLoader: ObservableObject {
    
}

struct AboutBiologerScreen<ScreenLoader>: View where ScreenLoader: AboutBiologerScreenLoader {
    
    @ObservedObject var loader: ScreenLoader
    
    var body: some View {
        Text("About Biologer Screen")
    }
}

struct AboutBiologerScreen_Previews: PreviewProvider {
    static var previews: some View {
        AboutBiologerScreen(loader: AboutBiologerScreenViewModel())
    }
    
    private class AboutBiologerScreenViewModel: AboutBiologerScreenLoader {
        
    }
}
