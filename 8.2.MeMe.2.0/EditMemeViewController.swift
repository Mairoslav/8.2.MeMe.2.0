//
//  EditMemeViewController.swift
//  4.0meMeV1.0
//
//  Created by mairo on 19/03/2022.
//

import UIKit

// Add two protocols to the class declaration: UIImagePickerControllerDelegate, UINavigationControllerDelegate
// Add third protocol to the class declaration: UItextFieldDelegate

class EditMemeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    // MARK: Outlets
    @IBOutlet weak var imagePickerView: UIImageView!
    
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var topNavBar: UINavigationBar!
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    var savedMemeForEdit: Meme? // to enable edit saved meme in detail view
    
    var imagePicker = UIImagePickerController() // an instance of UIImagePickerController
    
    // MARK: view-DidLoad/willAppear/willDisappear
    override func viewDidLoad() {
        super.viewDidLoad()
        // set View Controller as the delegate for the UIImagePickerController
        // denoting that “self” is the delegate for the imagePicker, bottomTextField, topTextField
        imagePicker.delegate = self
        // bottomTextField.delegate = self // need when text style via storyboard
        // topTextField.delegate = self // need when text style via storyboard
        
        // need when text style progamaticaly via method configureTextField(textField: UITextField)
        configureTextField(textField: bottomTextField)
        configureTextField(textField: topTextField)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        
        // disable the camera button in cases when this bool returns false for the camera sourceType
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        // call subscribeToKeybordNotifications() method in viewWillAppear
        subscribeToKeyboardNotifications()
        
        // if there's not yet image in the imageView, disable the share button
        // shareButton.isEnabled = false
        
        if let memeFromDetail = savedMemeForEdit as Meme? {
            // imagePickerView.image = memeFromDetail.image
            // imagePickerView.image = memeFromDetail.memedImage
            self.imagePickerView.image = memeFromDetail.image
            
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // call unsubscribeToKeybordNotifications() method in viewWillDissappear
        unsubscribeFromKeybordNotification()
    }

    // MARK: actions to the buttons to load the UIImagePickerController
    // we’ll call up the UIImagePickerController here
    
    // creating this reusable method, one that is repeated for album and camera @IBActions methods
    func pickImage(sourceType: UIImagePickerController.SourceType) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
        }
    
    @IBAction func album(_ sender: Any) {
        pickImage(sourceType: .photoLibrary)
    }
    
    @IBAction func camera(_ sender: Any) {
        pickImage(sourceType: .camera)
    }
    
    // MARK: - UIImagePickerControllerDelegate Method I.
    // to read the Image Picked from UIImagePickerController - so that selected picture appears in UIImageView
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // will send the data back for us to use in that Swift Dictionary named “info”
        // we have to unpack it from there with a key asking for what media information we want.
        // we just want the image, so that is what we ask for. For reference, the available options of UIImagePickerController.InfoKey are: mediaType, originalImage, editedImage...
        // we got out that part of the dictionary and optionally bound its type-casted form as a UIImage into the constant “pickedImage”.
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // setting the “content mode” of the UIImageView.
            // imagePickerView.contentMode = .scaleToFill // distorted
            // imagePickerView.contentMode = .scaleAspectFit // fit view, minimized to avoid distortion
            imagePickerView.contentMode = .scaleAspectFill // fit view, clipped to avoid distortion
            imagePickerView.image = pickedImage // sets the image of the UIImageView to be the image we just got pack.
            
            // inside didFinishPickingMediaWithInfo we enable the share button to use it i.e. once we have picture we enable share button
            shareButton.isEnabled = true
        }
        dismiss(animated: true, completion: nil) // dismiss image picker after xy image is selected
    }
    
    // MARK: - UIImagePickerControllerDelegate Method II.
    // is called when the user taps the “Cancel” button on top left of image picker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil) // dismiss image picker after button "Cancel" is pressed
    }
    
    // MARK: Text Field Delegate
    // when a user taps inside the textfiels the default text should clear
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }
    }
    
    // MARK: Text Field Delegate
    // when a user presses return, the keyboard should be dismissed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - text style in textFields
    func configureTextField(textField: UITextField) {
        let textStyle: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "Impact", size: 35)!,
            NSAttributedString.Key.strokeWidth: -4]
                as [NSAttributedString.Key : Any]
        
        topTextField.attributedPlaceholder = NSAttributedString(string: "TOP", attributes: textStyle)
        bottomTextField.attributedPlaceholder = NSAttributedString(string: "BOTTOM", attributes: textStyle)
        
        // textField.layer.borderWidth = 0
        // textField.layer.borderColor = UIColor.clear.cgColor
        // ↪ no, go identity inspector/Border style/none or code below
        textField.borderStyle = UITextField.BorderStyle.none
        
        textField.textAlignment = .center
        textField.delegate = self
        
        textField.defaultTextAttributes = textStyle
        textField.textAlignment = NSTextAlignment.center
    }
    
    // MARK: Moving the view functions
    // how do we know when the keybord is about to slide up?
    // NSNotifications provide a way to notice information throughout the program across classes
    // to anounce infomration like the keybord does show/hide, get info on keybord height...
    @objc func keybordWillShow(_ notification: Notification) {
        // To move the view up above the keybord, frame view is reduced by the height of keybord vs original vertical position (y)
        if bottomTextField.isFirstResponder {
                    // view.frame.origin.y = getKeyboardHeight(notification) * (-1)
                    view.frame.origin.y = -getKeyboardHeight(notification)
                }
    }
    
    // get keybord height
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keybordSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keybordSize.cgRectValue.height
    }
    
    // keybord does hide, frame view is again in original vertical position (y)
    @objc func keyboardWillHide(_ notification: Notification) {
            if bottomTextField.isFirstResponder {
                view.frame.origin.y = 0
            }
        }
    
    // MARK: subscribe/sign up to be notified when the keyboard appears
    // see also func func viewWilAppear & viewWillDisappear at the begining of project where the:
        // subscribeToKeyboardNotifications() & unsubscribeFromKeyboardNotifications() methods are called
    func subscribeToKeyboardNotifications() {
        // argument of '#selector' refers to instance method 'keybordWillShow' that is not exposed to Objective-C
        // add '@objc' to expose this instance method to Objective-C
        // NotificationCenter.default.addObserver(<#T##observer: Any##Any#>, selector: <#T##Selector#>, name: <#T##NSNotification.Name?#>, object: <#T##Any?#>)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keybordWillShow(_: )), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: unsubscribe
    func unsubscribeFromKeybordNotification() {
        // NotificationCenter.default.removeObserver(<#T##observer: Any##Any#>, name: <#T##NSNotification.Name?#>, object: <#T##Any?#>)
        // can remove two observers at once like this:
        // NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        // NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self)
    }
    // Every iOS program has one default NotificationCenter, NotificationCenter.default which comes with a number of useful stock notifications, like .UIKeyboardWillShow
    // https://developer.apple.com/documentation/foundation/notification
    
    // MARK: making object to represent MeMe
    // combining image and text
    // grab an image context and let it render the view hierarchy (image & textfields in this case) into a UIImage object.
    
    func generateMemedImage() -> UIImage {
        
        //Hide Toolbar And Navigation Bar
        topNavBar.isHidden = true
        toolbar.isHidden = true
        
        // render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return memedImage
    }
    
    // MARK: save
    // method that initializes a Meme model object
    func save() {
        
        // get the image from the imagePickerView
        let imageView = imagePickerView.image // without this let, in let meme just "image: imagePickerView.image"
        
        // create the meme
        let memedImage = generateMemedImage()
        
        // pack the layers on each other using components from struct set above
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, image: imageView, memedImage: memedImage) // new 2.0
        
        // variable to store memes
        var memes = [Meme]() // instead of forced unwrap var memes: [Meme]! use as it is now
        memes.append(meme)
        
        // add the meme to the memes array in the AppDelegate.swift
        let object = UIApplication.shared.delegate // new 2.0
        let appDelegate = object as! AppDelegate // new 2.0
        appDelegate.memes.append(meme) // new 2.0
    }
    
    // MARK: share
    @IBAction func share(_ sender: Any) {
        
        // generate memed image
        let memedImage = generateMemedImage()
        
        // define an instance of ActivityViewController
        let activityVC = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        // so that iPads won't crash
        activityVC.popoverPresentationController?.sourceView = self.view
        
        // pass the ActivityViewController a memedImage as an activity item
        // when sharing the meme, the save function must not be called if the user decides to cancel the activity view. Therefore adding an if statement here checking the success property.
        activityVC.completionWithItemsHandler = { activity, success, items, error in
            if success {
                self.save()
                self.dismiss(animated: true, completion: nil)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
        // present the VC
        present(activityVC, animated: true, completion: nil)
    }
    
    // MARK: cancel
    @IBAction func cancel(_ sender: Any) {
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        self.imagePickerView.image = nil
        shareButton.isEnabled = false // no picture no share button
        dismiss(animated: true, completion: nil) // new 2.0 cancel button to return to the Sent Memes View
    }
    
}

/*
 Sources used:
 Udacity iOS Nanodegree lessons
 https://www.codingexplorer.com/choosing-images-with-uiimagepickercontroller-in-swift/
 https://stackoverflow.com/questions/35931946/basic-example-for-sharing-text-or-image-with-uiactivityviewcontroller-in-swift
 https://sarunw.com/posts/how-to-add-custom-fonts-to-ios-app/
 https://www.codingexplorer.com/segue-swift-view-controllers
 https://www.ralfebert.com/ios-examples/uikit/uitableviewcontroller/custom-cells
 https://www.youtube.com/watch?v=aU_kTzMZHQ8
 https://developer.apple.com/documentation/uikit/uitableviewdelegate/1614998-tableview
 https://gist.github.com/RNHTTR/417f92e628ef6b300742dd8af94b206f
 https://stackoverflow.com/questions/26390072/how-to-remove-border-of-the-navigationbar-in-swift
 https://www.hackingwithswift.com/example-code/uikit/how-to-swipe-to-delete-uitableviewcells
 https://www.youtube.com/watch?v=F6dgdJCFS1Q
 */



