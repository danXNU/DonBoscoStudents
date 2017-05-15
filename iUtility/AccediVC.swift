//
//  AccediVC.swift
//  iUtility
//
//  Created by Dani Tox on 28/04/17.
//  Copyright © 2017 Dani Tox. All rights reserved.
//

import UIKit
import FirebaseDatabase
import CryptoSwift

class AccediVC: UIViewController {

    var presentError = false

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var progressView: UIActivityIndicatorView!
    
    var ref: FIRDatabaseReference!
    var handle:FIRDatabaseHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressView.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func dismissAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
  
    
    
    
    @IBAction func loginAction() {
        
        
        if usernameTextField.text != nil && usernameTextField.text != "" {
            if passwordTextField.text != nil && passwordTextField.text != "" {
                progressView.isHidden = false
                progressView.startAnimating()
                
                var allUsers = [String]()
                ref = FIRDatabase.database().reference()
                ref.child("Utenti").observeSingleEvent(of: .value, with: { (snapshot) in
                    let username = self.usernameTextField.text?.trimTrailingWhitespace()
                    if let users = snapshot.value as? NSDictionary {
                        for (keys, _) in users {
                            allUsers.append(keys as! String)
                        }
                        if allUsers.contains(username!) {
                            self.checkPassword()
                        }
                        else {
                            self.mostraAlert(titolo: "Errore", messaggio: "L'username non esiste. Riprova", tipo: .alert)
                            self.progressView.stopAnimating()
                        }
                    }
                    
                })
            }
        }
    }
    
    func checkPassword() {
        let passwdTyped = passwordTextField.text
        let username = usernameTextField.text?.trimTrailingWhitespace()
        ref.child("Utenti").child(username!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let credentials = snapshot.value as? NSDictionary {
                let passwd = credentials["Password"] as? String
                
                let passwdRightString = passwd
                let passwdTypedCripted = passwdTyped?.sha512()
                
                
                if passwdRightString == passwdTypedCripted {
                    //self.presentaAlertSuccess()
                    let date = Date()
                    let now = Calendar.current
                    let hour = now.component(.hour, from: date)
                    let minute = now.component(.minute, from: date)
                    let day = now.component(.day, from: date)
                    let month = now.component(.month, from: date)
                    let year = now.component(.year, from: date)
                    
                    self.ref.child("Utenti").child(username!).child("Ultimo Accesso").setValue("\(hour):\(minute) - \(day)/\(month)/\(year)")
                    
                    self.dismiss(animated: true, completion: nil)
                    self.progressView.stopAnimating()
                    
                    UserDefaults.standard.set(username!, forKey: "usernameAccount")
                    NotificationCenter.default.post(name: NOTIF_ACCEDUTO, object: nil)
                    if let token = credentials["Access Token"] as? Int {
                        UserDefaults.standard.set(token, forKey: "AccessToken")
                        UserDefaults.standard.set(true, forKey: "accountLoggato")
                        
                    }
                    else {
                        print("C'è stato un errore mentre stavo ricevendo il token del tuo account. Contattami via mail scrivendo il tuo username in modo che possa aiutarti")
                        self.mostraAlert(titolo: "Errore Token", messaggio: "C'è stato un errore mentre stavo ricevendo il token del tuo account. Contattami via mail scrivendo il tuo username in modo che possa aiutarti", tipo: .alert)
                        
                        self.progressView.stopAnimating()
                    }
                    
                    
                }
                else {
                    print("Password che hai scritto: \(passwdTyped!)\nPassword giusta: \(passwdRightString!)\nPassword che hai scritto CRIPTATA: \(passwdTypedCripted!)\n")
                    self.mostraAlert(titolo: "Errore", messaggio: "Password sbagliata", tipo: .alert)
                    self.progressView.stopAnimating()
                }
                
                
                
            }
            
        })
        
    }

    
    func presentaAlertSuccess() {
        let alert = UIAlertController(title: "Login", message: "Il login è stato completato con successo", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
}