//
//  SaveViewController.swift
//  padpad
//
//  Created by 栗圆 on 3/17/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//
// learn about camera and libray CITE: https://makeapppie.com/2016/06/28/how-to-use-uiimagepickercontroller-for-a-camera-and-photo-library-in-swift-3-0/

// learn add done button CITE: http://stackoverflow.com/questions/28338981/how-to-add-done-button-to-numpad-in-ios-8-using-swift

import UIKit

class SaveMixTableViewController: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    let picker = UIImagePickerController()
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var diaryTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var myImageView: UIImageView!
    
    var image: UIImage?
    
    @IBAction func photoFromLibrary(_ sender: UIBarButtonItem) {
            picker.allowsEditing = false
            picker.sourceType = .photoLibrary
            picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            picker.modalPresentationStyle = .popover
            present(picker, animated: true, completion: nil)
            picker.popoverPresentationController?.barButtonItem = sender
        }
    @IBAction func shootPhoto(_ sender: UIBarButtonItem) {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                picker.allowsEditing = false
                picker.sourceType = UIImagePickerControllerSourceType.camera
                picker.cameraCaptureMode = .photo
                picker.modalPresentationStyle = .fullScreen
                present(picker,animated: true,completion: nil)
            } else {
                noCamera()
            }
        }
    func noCamera(){
            let alertVC = UIAlertController(
                title: "No Camera",
                message: "Sorry, this device has no camera",
                preferredStyle: .alert)
            let okAction = UIAlertAction(
                title: "OK",
                style:.default,
                handler: nil)
            alertVC.addAction(okAction)
            present(
                alertVC,
                animated: true,
                completion: nil)
        }
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        var  chosenImage = UIImage()
        chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        myImageView.contentMode = .scaleAspectFit //3
        myImageView.image = chosenImage //4
        image = chosenImage
        dismiss(animated:true, completion: nil) //5
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        picker.delegate = self
        datePicker.date = Date()
        nameTextField.delegate = self
        datePicker.maximumDate = Date()
        addDoneButtonOnKeyboard()
        }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.doneButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Arial", size: 20.0)!, NSForegroundColorAttributeName: UIColor.lightGray], for: .disabled)
        self.doneButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Arial", size: 20.0)!, NSForegroundColorAttributeName: UIColor.blue], for: .normal)
    }
    
    private func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.nameTextField.inputAccessoryView = doneToolbar
    }
    func doneButtonAction() {
        self.nameTextField.resignFirstResponder()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.restorationIdentifier != nil, textField.restorationIdentifier! == "NameTextField" {
            if textField.text != nil, textField.text! != "" {
                doneButton.isEnabled = true
                return
            }
            doneButton.isEnabled = false
        }
    }
}
