//
//  MemeViewController.swift
//  MemeMe
//
//  Created by david lobo on 07/04/2016.
//  Copyright © 2016 David Lobo. All rights reserved.
//

import UIKit

class MemeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, FontTableViewControllerDelegate {
    
    struct MemeControllerDefaults {
        static let FontName = "Impact"
        static let TopTextFieldText = "TOP"
        static let BottomTextFieldText = "BOTTOM"
    }
    
    // Properties
    
    var activeField: UITextField!
    var keyboardHeight: CGFloat = 0
    var currentFontname: String?
    //let defaultFontName: String = "Impact"
    
    var memeTextAttributes: [String: AnyObject]?
    
    // IB Outlets
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet var imagePickerView: UIImageView!
    
    // MARK: - ViewController lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        shareButton.enabled = false
        cancelButton.enabled = false
        
        setDefaultFont()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        bottomTextField.delegate = self
        topTextField.delegate = self
        
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        if let memeTextAttributes = memeTextAttributes {
            bottomTextField.defaultTextAttributes = memeTextAttributes
            topTextField.defaultTextAttributes = memeTextAttributes
        }
        
        topTextField.backgroundColor = UIColor.clearColor()
        bottomTextField.backgroundColor = UIColor.clearColor()
        
        bottomTextField.textAlignment = .Center
        topTextField.textAlignment = .Center
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let navController = segue.destinationViewController as! UINavigationController
        let fontController = navController.viewControllers[0] as! FontTableViewController
        
        fontController.delegate = self
        fontController.currentFontname = currentFontname
    }
    
    // MARK: - UINavigationControllerDelegate
    
    override func prefersStatusBarHidden() -> Bool {
        
        return true
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        activeField = textField
        
        var defaultText: String?
        
        if textField == topTextField {
            defaultText = MemeControllerDefaults.TopTextFieldText
        } else if textField == bottomTextField {
            defaultText = MemeControllerDefaults.BottomTextFieldText
        }
        
        if let defaultText = defaultText {
            if textField.text == defaultText {
                textField.text = ""
            }
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        self.activeField = nil
        
        var defaultText: String?
        
        if textField == topTextField {
            defaultText = MemeControllerDefaults.TopTextFieldText
        } else if textField == bottomTextField {
            defaultText = MemeControllerDefaults.BottomTextFieldText
        }
        
        if let textFieldText = textField.text {
            if textFieldText.isEmpty {
                textField.text = defaultText
            }
        }
        
        cancelButton.enabled = true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imagePickerView.image = image
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
        }
        
        if imagePickerView.image != nil {
            cancelButton.enabled = true
            shareButton.enabled = true
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Keyboard notifications
    
    func keyboardWillShow(notification: NSNotification) {
        
        scrollKeyboardUp(notification)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        scrollKeyboardDown()
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - IB actions
    
    @IBAction func pickAnImageFromAlbum (sender: AnyObject) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.allowsEditing = true
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromCamera (sender: AnyObject) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func shareMeme(sender: AnyObject) {
        
        if (imagePickerView.image != nil) {
            let meme = save()
            let controller = UIActivityViewController(activityItems: [meme.memedImage], applicationActivities: nil)
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        topTextField.text = MemeControllerDefaults.TopTextFieldText
        bottomTextField.text = MemeControllerDefaults.BottomTextFieldText
        imagePickerView.image = nil
        setDefaultFont()
        cancelButton.enabled = false
        shareButton.enabled = false
    }
    
    // MARK: - Helper functions
    
    func setDefaultFont() {
        changeFont(MemeControllerDefaults.FontName)
    }
    
    func changeFont(fontName: String) {
        currentFontname = fontName
        
        memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: currentFontname!, size: 40)!,
            NSStrokeWidthAttributeName : -3.0
        ]
        
        if let memeTextAttributes = memeTextAttributes {
            topTextField.defaultTextAttributes = memeTextAttributes
            bottomTextField.defaultTextAttributes = memeTextAttributes
        }
        
        bottomTextField.textAlignment = .Center
        topTextField.textAlignment = .Center
    }
    
    func save() -> Meme {
        let memedImage = generateMemedImage()
        
        // create the meme
        let meme = Meme( topTextField: topTextField.text!, bottomTextField: bottomTextField.text!, originalImage:
            imagePickerView.image!, memedImage: memedImage)
        
        return meme
    }
    
    func generateMemedImage() -> UIImage
    {
        // hide the toolbars for the screen capture
        bottomToolbar.hidden = true
        topToolbar.hidden = true
        
        // render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame,
            afterScreenUpdates: true)
        
        let memedImage : UIImage =
        UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // show the toolbars again
        bottomToolbar.hidden = false
        topToolbar.hidden = false
        
        return memedImage
    }
    
    func scrollKeyboardDown() {
        if activeField == bottomTextField {
            //print("kb will hide \(keyboardHeight)")
            view.frame.origin.y = 0
        }
    }
    
    func scrollKeyboardUp(notification: NSNotification) {
        if activeField == bottomTextField {
            keyboardHeight = getKeyboardHeight(notification)
            //print("kb will show \(keyboardHeight)")
            view.frame.origin.y = 0 - keyboardHeight
        }
    }
    
    func subscribeToKeyboardNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:"    , name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:"    , name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillHideNotification, object: nil)
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    // MARK: - FontTableViewControllerDelegate
    
    func didFinishTask(sender: FontTableViewController) {
        //print("didFinishTask \(sender.currentFontname)")
        
        if let fontName = sender.currentFontname {
            changeFont(fontName)
            cancelButton.enabled = true
        }
        
    }
}