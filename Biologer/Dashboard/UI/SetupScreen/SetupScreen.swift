//
//  SetupScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 27.6.21..
//

import SwiftUI

protocol SetupScreenLoader: ObservableObject {
    
}

struct SetupScreen<ScreenLoader>: View where ScreenLoader: SetupScreenLoader {
    
    @ObservedObject var loader: ScreenLoader
    
    var body: some View {
        Text("Setup screen")
    }
}

struct SetupScreen_Previews: PreviewProvider {
    static var previews: some View {
        SetupScreen(loader: StubSetupScreenViewModel())
    }
    
    private class StubSetupScreenViewModel: SetupScreenLoader {
        
    }
}
