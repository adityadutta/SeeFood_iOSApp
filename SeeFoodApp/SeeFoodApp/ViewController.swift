//
//  ViewController.swift
//  SeeFoodApp
//
//  Created by Aditya Dutta on 2020-01-21.
//  Copyright © 2020 Aditya Dutta. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseUI

class ViewController: UIViewController, FUIAuthDelegate {
    
    @IBOutlet weak var tfEmail: UITextField!
    
    @IBOutlet weak var tfPassword: UITextField!
    
    @IBOutlet weak var btnCreate: UIButton!
    
    @IBOutlet weak var btnLogin: UIButton!
    
    var authUI : FUIAuth?
    
    var fstore : Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        let providers : [FUIAuthProvider] = [FUIEmailAuth(), FUIGoogleAuth()]
        authUI?.providers = providers
        
        fstore = Firestore.firestore()
        
        if Auth.auth().currentUser != nil{
            //get collection with id
            let doc = fstore.collection("winner").document("100")
            doc.getDocument(completion: {(snapshot, error) in
                if let d = snapshot?.data(){
                    print(d)
                }
            })
            
            //get all data in collection
            fstore.collection("winner").getDocuments(completion: {(snapshot, error) in
                for doc in (snapshot?.documents)!{
                    print(doc.data())
                }
            })
            
            //update data
            doc.setData(["level": 1], merge: true)
            doc.updateData(["scores": ["top": 999, "low": 1]])
            doc.updateData(["scores.low": 10])
        }
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if error == nil{
            btnLogin.setTitle("Logout", for: .normal)
        }
    }
    
    @IBAction func doBtnCreate(_ sender: Any) {
        if let email = tfEmail.text, let password = tfPassword.text{
            Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                print(Auth.auth().currentUser?.email ?? "no email")
                print(Auth.auth().currentUser?.uid ?? "no userid")
            })
            //firestore
            fstore.collection("winner").addDocument(data: ["game":"1", "user": email])
        }
        
        
    }
    
    @IBAction func doBtnLogin(_ sender: Any) {
        if Auth.auth().currentUser == nil{
            if let authVC = authUI?.authViewController(){
                present(authVC, animated: true, completion: nil)
            }
            /* let email = tfEmail.text, let password = tfPassword.text{
                Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                    if error == nil{
                        self.btnLogin.setTitle("Logout", for: .normal)
                    }
                })
            }*/
        }
        else{
            do{
                try Auth.auth().signOut()
                self.btnLogin.setTitle("Login", for: .normal)
            }
            catch{}
        }
    }
    
}
