//
//  BiologerProgressBarScreenViewModel.swift
//  Biologer
//
//  Created by Nikola Popovic on 6.11.21..
//

import Foundation

public protocol BiologerProgressBarDelegate {
    func updateProgressBar(currentValue: Double, maxValue: Double)
}

public final class BiologerProgressBarScreenViewModel: ObservableObject {
    @Published public private(set) var maxValue: Double
    @Published public private(set) var currentValue: Double
    public let cancelButtonTitle: String = "Common.btn.cancel".localized
    private let onCancelTapped: Observer<Double>
    private let onProgressAppeared: Observer<Double>
    
    init(maxValue: Double,
         currentValue: Double = 0.0,
         onProgressAppeared: @escaping Observer<Double>,
         onCancelTapped: @escaping Observer<Double>) {
        self.maxValue = maxValue
        self.currentValue = currentValue
        self.onProgressAppeared = onProgressAppeared
        self.onCancelTapped = onCancelTapped
    }
    
    func cancelTapped() {
        onCancelTapped((currentValue))
    }
    
    func progressBarAppeared() {
        onProgressAppeared((currentValue))
    }
    
    func getTitle() -> String {
        return maxValue == currentValue ? "Common.title.downloaded".localized : "Common.title.downloading".localized
    }
}

extension BiologerProgressBarScreenViewModel: BiologerProgressBarDelegate {
    public func updateProgressBar(currentValue: Double, maxValue: Double) {
        self.currentValue = currentValue
        self.maxValue = maxValue
    }
}
