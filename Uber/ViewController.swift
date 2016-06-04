//
//  ViewController.swift
//

import UIKit
import Parse

class ViewController: UIViewController, UITextFieldDelegate {

	@IBOutlet weak var username: UITextField!
	@IBOutlet weak var password: UITextField!
	@IBOutlet weak var `switch`: UISwitch!
	@IBOutlet weak var riderLabel: UILabel!
	@IBOutlet weak var driverLabel: UILabel!
	@IBOutlet weak var submitButton: UIButton!
	@IBOutlet weak var toggleButton: UIButton!
	@IBOutlet weak var questionLabel: UILabel!
	
	var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
	var isSignUpMode = true
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		`switch`.hidden = false
		riderLabel.hidden = false
		driverLabel.hidden = false
		username.delegate = self
		password.delegate = self
	}

	@IBAction func submitButtonAction(sender: AnyObject) {
		
		if username.text == "" || password.text == "" {
			displayAlert("Faltan campos por llenar", message: "Se requiere Usuario y password ")
		}
		else {
			//start spinner
			activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
			activityIndicator.center = self.view.center
			activityIndicator.hidesWhenStopped = true
			activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
			view.addSubview(activityIndicator)
			//ignore interaction events
			activityIndicator.startAnimating()
			UIApplication.sharedApplication().beginIgnoringInteractionEvents()
			
			//set default error message
			var errorMessage = "Favor de intentar de nuevo"
			
			if isSignUpMode {
				//signup with parse
				let user = PFUser()
				user.username = username.text
				user.password = password.text
				user["isDriver"] = self.`switch`.on
				
				user.signUpInBackgroundWithBlock {
					(succeeded: Bool, error: NSError?) -> Void in
					//enable interaction events
					self.activityIndicator.stopAnimating()
					UIApplication.sharedApplication().endIgnoringInteractionEvents()
					
					if error != nil {
						if let errorString = error!.userInfo["error"] as? String {
							errorMessage = errorString
						}
						self.displayAlert("Error al crear usuario", message: errorMessage)
					} else {
						self.displayAlert("Usuario creado con exito", message: "Ya puedes usar miraite")
						self.password.text = ""
						self.toggleButtonAction("")
					}
				}
			}
			else{
				//login with parse
				PFUser.logInWithUsernameInBackground(username.text!, password:password.text!) {
					(user: PFUser?, error: NSError?) -> Void in
					//enable interaction events
					self.activityIndicator.stopAnimating()
					UIApplication.sharedApplication().endIgnoringInteractionEvents()
					
					if error != nil {//login failed
						if let errorString = error!.userInfo["error"] as? String {
							errorMessage = errorString
						}
						self.displayAlert("Fallo entrada a Miraite", message: errorMessage)
					}
					else {
						self.login()
					}
				}
			}
		}
	}
	
	func login(){
		if let isDriver = PFUser.currentUser()!["isDriver"] {
			if isDriver as! Bool {
				self.performSegueWithIdentifier("showDriverView", sender: self)
			}
			else {
				self.performSegueWithIdentifier("showRiderView", sender: self)
			}
		}
	}
	
	@IBAction func toggleButtonAction(sender: AnyObject) {
		isSignUpMode = !isSignUpMode
		if isSignUpMode {
			`switch`.hidden = false
			riderLabel.hidden = false
			driverLabel.hidden = false
			questionLabel.text = "Ya estas registrado?"
			submitButton.setTitle("Darse de alta", forState: UIControlState.Normal)
			toggleButton.setTitle("Acceso", forState: UIControlState.Normal)
		}
		else {
			`switch`.hidden = true
			riderLabel.hidden = true
			driverLabel.hidden = true
			questionLabel.text = "No estas registrado?"
			submitButton.setTitle("Acceso", forState: UIControlState.Normal)
			toggleButton.setTitle("Darse alta", forState: UIControlState.Normal)
		}
	}
	
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func displayAlert(title:String, message:String){
		let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
			self.dismissViewControllerAnimated(true, completion: nil)
		}))
		self.presentViewController(alert, animated: true, completion: nil)
	}

	//Remove keyboard when touch ouside the keyboard
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		self.view.endEditing(true)
	}
	
	//Remove keyboard when clic 'return'
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}

	override func viewDidAppear(animated: Bool) {
		if let _ = PFUser.currentUser()?.username {
			login()
		}
	}
}

