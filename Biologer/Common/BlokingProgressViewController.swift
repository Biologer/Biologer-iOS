//
//  BlokingProgressViewController.swift
//  Biologer
//
//  Created by Nikola Popovic on 12.7.21..
//

import UIKit

class BlokingProgressViewController: UIViewController {
    
    @IBOutlet private var progress: CircularProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        progress.backgroundColor = .clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        progress.startInfinitAnimation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        progress.stopAnimation()
    }


}
