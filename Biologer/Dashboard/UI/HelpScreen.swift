//
//  HelpScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 27.6.21..
//

import SwiftUI

protocol HelpScreenLoader: ObservableObject {
    
}

struct HelpScreen<ScreenLoader>: View where ScreenLoader: HelpScreenLoader {
    
    @ObservedObject var loader: ScreenLoader
    
    var body: some View {
        Text("Help Screen")
    }
}

struct HelpScreen_Previews: PreviewProvider {
    static var previews: some View {
        HelpScreen(loader: StubHelpScreenViewModel())
    }
    
    private class StubHelpScreenViewModel: HelpScreenLoader {
        
    }
}
