//
//  ViewController.swift
//  UiKit
//
//  Created by Горніч Антон on 16.02.2026.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var helloLabel: UILabel!
    
    
    
    // 1. Initialization
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        print("1. init(nibName:bundle:)")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print("1. init(coder:) - for Storyboard/XIB")
    }
    
    // 2. Loading the view
    override func loadView() {
        super.loadView()
        print("2. loadView() - view is being created")
    }
    
    // 3. View loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        print("3. viewDidLoad() - view loaded, ready for setup")
        // UI setup, notification subscriptions
    }
    
    // 4. View is about to appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("4. viewWillAppear() - before appearing on screen")
        // Data refresh, observer registration
    }
    
    // 5. View layout is about to be calculated
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print("5. viewWillLayoutSubviews() - before layout calculation")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("6. viewDidLayoutSubviews() - after layout calculation")
        // Safe place to work with subviews' frames/bounds
    }
    
    // 6. View appeared on screen
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("7. viewDidAppear() - view fully visible")
        // Start animations, perform network requests
    }
    
    // 7. View is about to disappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("8. viewWillDisappear() - view will disappear")
        // Save state, remove notification observers
    }
    
    // 8. View disappeared from screen
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("9. viewDidDisappear() - view disappeared")
        // Release resources
    }
    
    // 9. Memory warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("10. didReceiveMemoryWarning() - low memory")
        // Clear caches, images
    }
    
    // 10. View controller is being deallocated
    deinit {
        print("11. deinit - view controller deallocated")
    }
    
    // MARK: - Actions
    
    @IBAction func ButtonPressed(_ sender: UIButton) {
        helloLabel.text = ""
    }
}
