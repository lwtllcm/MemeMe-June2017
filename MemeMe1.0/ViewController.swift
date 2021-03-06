//
//  ViewController.swift
//  MemeMe1.0
//
//  Created by Laurie Wheeler on 1/10/16.
//  Copyright © 2016 Student. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var meme: Meme?
    
    //outlets
    @IBOutlet weak var imagePickerView: UIImageView!
    
    @IBOutlet weak var topText: UITextField!
    
    @IBOutlet weak var bottomText: UITextField!
    
    //delegate
    let textFieldDelegate = TextFieldDelegate()
    
    //memeTextAttributes
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -5.0
    ]
    
    //buttons
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    
    // viewDidLoad, viewWillAppear, viewWillDisappear
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        
        if let image = meme?.originalImage {
            print("meme passed")
            imagePickerView.backgroundColor = UIColor.blackColor()
            imagePickerView.image = image
            setTextFields(topText)

            topText.text = " "
            topText.enabled = true
            
            setTextFields(bottomText)

            bottomText.text = " "
            bottomText.enabled = true
            imagePickerView.contentMode = .ScaleAspectFit
            
            navigationController?.navigationBarHidden = false
            
            shareButton.enabled = true
            cancelButton.enabled = true
        }
        else {
        
        imagePickerView.backgroundColor = UIColor.blackColor()
        
        setTextFields(topText)
        topText.text = "TOP"
        
        setTextFields(bottomText)
        bottomText.text = "BOTTOM"
        shareButton.enabled = false
        }
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        print("viewWillAppear")
        super.viewWillAppear(animated)
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        subscribeToKeyboardNotifications()
        subscribeToKeyboardWillHideNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        print("viewWillDisappear")
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func setTextFields(textField:UITextField) {
        print("setTextFields")
        textField.defaultTextAttributes = memeTextAttributes
        textField.backgroundColor = UIColor.clearColor()
        
        textField.textAlignment = NSTextAlignment.Center
        textField.adjustsFontSizeToFitWidth = true
        textField.delegate = textFieldDelegate
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //pick image methods
    
    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
        print("pickAnImagefromAlbum")
        let sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        pickImage(sourceType)
    }
    
    @IBAction func pickAnImageFromCamera(sender: AnyObject) {
        print("pickAnImagefromCamera")
        let sourceType = UIImagePickerControllerSourceType.Camera
        pickImage(sourceType)
        
    }
    
    func pickImage(sourceImageType:UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceImageType
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("didFinishPickingImage")
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
            imagePickerView.contentMode = .ScaleAspectFit
            
        }
        
     
        
        dismissViewControllerAnimated(true, completion:{() -> Void in
            self.shareButton.enabled = true
        })
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("imagePickerControllerDidCancel")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //keyboard methods
    
    func keyboardWillShow(notification: NSNotification) {
        print("keyboardWillShow")
        if bottomText.isFirstResponder() {
            view.frame.origin.y = getKeyboardHeight(notification) * -1
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        print("keyboardWillHide")
        if bottomText.isFirstResponder() {
            view.frame.origin.y = 0.0
        }
    }
    
    func getKeyboardHeight(notification:NSNotification) -> CGFloat {
        print("getKeyboardHeight")
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    func subscribeToKeyboardNotifications() {
        print("subscribeToKeyboardNotifications")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func subscribeToKeyboardWillHideNotifications() {
        print("subscribeToKeyboardNotifications")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        print("unsubscribeFromKeyboardNotifications")
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardWillHideNotifications() {
        print("unsubscribeFromKeyboardNotifications")
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    //text methods
    func textFieldDidBeginEditing( textField: UITextField) {
        print("textFieldDidBeginEditing")
        textField.text = ""
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        return true
    }
    
    //meme methods
    func saveMeme() {
        print("saveMeme")
        let meme = Meme(
            memeTopText: topText.text!,
            memeBottomText: bottomText.text!,
            originalImage: imagePickerView.image!,
            memedImage: generateMemedImage())
        
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
        
        shareButton.enabled = true
    }
    
    func generateMemedImage() -> UIImage {
        print("generateMemedImage")
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        shareButton.enabled = true
        return memedImage
    }
    
    @IBAction func shareMeme(sender: AnyObject) {
        print("shareMeme")
        
        let memedImage = generateMemedImage()
        let shareController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        //helpful info on completion block https://discussions.udacity.com/t/im-not-understanding-the-uiactivityviewcontroller-completionwithitemshandler/14271/9
        
        shareController.completionWithItemsHandler = {activity, completed, items, error in
            if completed {
                self.saveMeme()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
        presentViewController(shareController, animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonAction(sender: AnyObject) {
        print("cancelButtonAction")
        dismissViewControllerAnimated(true, completion: nil)
    }
}
