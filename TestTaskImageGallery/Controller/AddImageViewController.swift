//
//  AddImageViewController.swift
//  TestTaskImageGallery
//
//  Created by Oleksandr Bambulyak on 30.03.2018.
//  Copyright © 2018 Oleksandr Bambulyak. All rights reserved.
//

import Photos
import RealmSwift
import UIKit
import AVKit
import AssetsLibrary


class AddImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var imagePicker = UIImagePickerController()
    var dateString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.hideKeyboard()
        imagePicker.delegate = self
    }
    
    lazy var objectImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "logo-mark")
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectObjectImageView)))
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 111/2
        return imageView
    }()
    
    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    let nameSeparatorView: UIView = {
        let viewSeparator = UIView()
        viewSeparator.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        viewSeparator.translatesAutoresizingMaskIntoConstraints = false
        return viewSeparator
    }()
    
    lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor.white
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Title"
        return textField
    }()
    
    lazy var descriptionTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor.white
        textField.placeholder = "Description"
        return textField
    }()
    
    lazy var addButton: UIButton = {
        let button = UIButton()
        button.setTitle("Test write", for: .normal)
        button.clipsToBounds = true
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitleColor(UIColor.white, for: .normal)
        button.isUserInteractionEnabled = true
        button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleWrite)))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.masksToBounds = true
        return button
    }()
    
    func generateUniqueImageName() -> Int {
        let realm = try! Realm()
        let allImages = realm.objects(ImageObject.self)
        var imageNumber: Int = 0
        if (allImages.count == 0) {
            imageNumber = 1
        } else {
            imageNumber = (allImages.last?.number)! + 1
        }
        return imageNumber
    }
    
    @objc func handleWrite() {
        let realm = try! Realm()
        
        if (isPhotoAndFieldsOk() == true) {
            
            let object = ImageObject()
            
            if let imageObjectTitle = titleTextField.text {
                object.imageTitle = imageObjectTitle
            }
            if let imageObjectDescription = descriptionTextField.text {
                object.imageDescription = imageObjectDescription
            }
            
            let uniqueImageName = generateUniqueImageName()
            object.number = generateUniqueImageName()
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            let imageURL = documentsURL?.appendingPathComponent("\(uniqueImageName).png")
            if let myImage = objectImageView.image {
                do {
                    if let tempImageUrl = imageURL {
                    try UIImageJPEGRepresentation(myImage, 0.4)?.write(to: tempImageUrl)
                        object.imagePath = (imageURL?.absoluteString)!
                    }
                } catch {
                    createAndShowAlertWith(titleText: "Oh!", descriptionText: "Something went wrong!", closeButtonText: "Close")
                }
                }
       
        
            if let dateTempString = dateString {
            object.imageDate = dateTempString
            }
            
            try! realm.write {
                realm.add(object)
                createAndShowAlertWith(titleText: "Good!", descriptionText: "Object saved!", closeButtonText: "Close")
            }
        }
    }
    
    func createAndShowAlertWith(titleText: String, descriptionText:String, closeButtonText: String) {
        let alertController = UIAlertController(title: title, message: descriptionText, preferredStyle: .alert)
        let actionOk = UIAlertAction(title: closeButtonText,
                                     style: .default,
                                     handler: nil)
        alertController.addAction(actionOk)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func openCamera() {
        
    if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
        
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
                
                if response {
                    
                    self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                    self.imagePicker.allowsEditing = true
                    DispatchQueue.main.async(execute: {
                      self.present(self.imagePicker, animated: true, completion: nil)
                    })
               } else {
                    let alertController = UIAlertController(title: "Oh!", message: "You haven't access to the camera resource. You can enable camera in settings", preferredStyle: .alert)
                    //We add buttons to the alert controller by creating UIAlertActions:
                    let actionOk = UIAlertAction(title: "OK",
                                                 style: .default,
                                                 handler: nil) //You can use a block here to handle a press on this button
                    alertController.addAction(actionOk)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery() {
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selected: UIImage?
        
        var currentDate = Date()
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateString = dateFormatter.string(from: currentDate)
        
        if let photoInfo = info[UIImagePickerControllerPHAsset] as? PHAsset {
        if let creationDate = photoInfo.creationDate {
        let tempDateString: String
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        tempDateString = dateFormatter.string(from: creationDate)
        dateString = tempDateString
        }
        }
        
        if let editedImage = info["UIImagePickerEditedImage"] {
            selected = editedImage as? UIImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] {
            selected = originalImage as? UIImage
        }
        
        if let image = selected {
            objectImageView.image = selected
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleSelectObjectImageView() {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallery()
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func isPhotoAndFieldsOk() -> Bool {
        if (objectImageView.image == UIImage(named: "logo-mark")) {
            createAndShowAlertWith(titleText: "Oh!", descriptionText: "You need to choose a different image", closeButtonText: "OK")
            return false
            
        } else if (titleTextField.text == "") {
            createAndShowAlertWith(titleText: "Oh!", descriptionText: "You need to type something in the title field!", closeButtonText: "OK")
            return false
            
        } else if (descriptionTextField.text == "") {
            createAndShowAlertWith(titleText: "Oh!", descriptionText:  "You need to type something to the description field", closeButtonText: "OK")
            return false
        }
        
        return true
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func setupUI() {
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        view.addSubview(objectImageView)
        view.addSubview(addButton)
        inputsContainerView.addSubview(titleTextField)
        inputsContainerView.addSubview(descriptionTextField)
        view.addSubview(inputsContainerView)
         inputsContainerView.addSubview(nameSeparatorView)
        setupConstraints()
    }
    
    func setupConstraints() {
        //Need x, y, width, height cons
        objectImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        objectImageView.bottomAnchor.constraint(equalTo: titleTextField.topAnchor, constant: -12).isActive = true
        objectImageView.widthAnchor.constraint(equalToConstant: 111).isActive = true
        objectImageView.heightAnchor.constraint(equalToConstant: 111).isActive = true
        
        titleTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        titleTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        titleTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        titleTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
     
        descriptionTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        descriptionTextField.topAnchor.constraint(equalTo: titleTextField.bottomAnchor).isActive = true
        descriptionTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        descriptionTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        inputsContainerView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -45).isActive = true

        addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        addButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 10).isActive = true
        addButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -45).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        //Need x, y, width, height cons
        nameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        nameSeparatorView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true

    }

}

extension UIViewController
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}

extension UIColor {
    
    convenience init (r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha:1)
    }
    
}

