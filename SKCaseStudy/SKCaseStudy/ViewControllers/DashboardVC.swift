//
//  DashboardVC.swift
//  SKCaseStudy
//
//  Created by Tiago Bras on 21/04/2018.
//  Copyright © 2018 Tiago Bras. All rights reserved.
//

import UIKit

class DashboardVC: UIViewController {
    private let kMinPasswordLength = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide navigation bar bottom separator
        navigationController?.navigationBar.shadowImage = UIImage()
        
        signInButton.setTitleColor(UIColor(red: 0.933, green: 0.929, blue: 0.922, alpha: 1.00),
                                   for: .disabled)
        
        emailTextField.addTarget(self, action: #selector(emailOrPasswordValueHaveChanged(_:)),
                                 for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(emailOrPasswordValueHaveChanged(_:)),
                                    for: .editingChanged)
    }
    
    var areCredentialsValid: Bool {
        guard let email = emailTextField.text else { return false }
        guard let password = passwordTextField.text else { return false }
        
        return isEmailValid(email) && password.count >= kMinPasswordLength
    }
    
    // URL: https://stackoverflow.com/questions/26180888/what-are-best-practices-for-validating-email-addresses-in-swift
    private func isEmailValid(_ s: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: s)
    }
    
    // Mark:- Outlets
    @IBOutlet weak var togglePasswordVisibilityButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    
    // Mark:- Actions
    @IBAction func passwordVisibilityButtonPressed(_ sender: Any) {
        passwordTextField.isSecureTextEntry.toggle()
        
        let buttonTitle = passwordTextField.isSecureTextEntry ? "show" : "hide"
        
        togglePasswordVisibilityButton.setTitle(buttonTitle, for: .normal)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    @objc func emailOrPasswordValueHaveChanged(_ textField: UITextField) {
        // Trim whitespace
        textField.text = textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        signInButton.isEnabled = areCredentialsValid
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            bottomConstraint.constant = keyboardHeight
            
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil)
    }
}

extension DashboardVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            bottomConstraint.constant = 0
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
        
        return true
    }
    
    
}
