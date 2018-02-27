//
//  LoginViewController.swift
//  DemoHelix
//
//  Created by Alejandro Barros Cuetos on 25/02/2018.
//  Copyright © 2018 Filtercode Ltd. All rights reserved.
//

import UIKit
import Helix

final class LoginViewController: UIViewController, StoryboardInstantiatable {
    
    var presenter: LoginPresenterType!
    
    // MARK: - Outlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Actions
    
    @IBAction func submitAction(_ sender: UIButton) {
        guard let username = usernameTextField.text,
            let password = passwordTextField.text,
            !username.isEmpty, !password.isEmpty else {
            debugPrint("Empty fields")
            return
        }
        presenter?.login(with: username, password: password, completionHandler: { [weak self](succeed) in
            debugPrint("Login successful: \(succeed)")
            if succeed {
                guard let navigationController = self?.navigationController else {
                    return
                }
                self?.presenter.pushHomeScreen(in: navigationController)
            }
        })
    }
}
