//
//  WallpaperController.swift
//  Coder Weather
//
//  Created by Coder ACJHP on 4.08.2018.
//  Copyright © 2018 Coder ACJHP. All rights reserved.
//

import UIKit

class WallpaperController: UIViewController {

    var width = CGFloat()
    var height = CGFloat()
    var selectedImage: UIImage?
    let userSettings = Setting.shared
    @IBOutlet weak var cameraIcon: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageContainer: UIImageView!
    @IBOutlet weak var saveSettings: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.width = self.collectionView.frame.size.width
        self.height = self.collectionView.frame.size.height
        
        adjustImageContainersView()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        setupImageChoosing()
    }

    private func adjustImageContainersView() {
        cameraIcon.layer.cornerRadius = 5.0
        cameraIcon.layer.masksToBounds = true
        imageContainer.layer.cornerRadius = 5.0
        imageContainer.layer.masksToBounds = true
        saveSettings.layer.cornerRadius = 5.0
    }
    
    private func setupImageChoosing() {
        imageContainer.isUserInteractionEnabled = true
        cameraIcon.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tappedOn(_:)))
        let cameraTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tappedOn(_:)))
        imageContainer.addGestureRecognizer(imageTapRecognizer)
        cameraIcon.addGestureRecognizer(cameraTapRecognizer)
    }
    
    @objc private func tappedOn(_ gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        if gestureRecognizer.view == imageContainer {
            imagePicker.sourceType = .photoLibrary
        } else if gestureRecognizer.view == cameraIcon {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.sourceType = .camera
            } else {
                showCustomErrorMsgWithAlert(errorMessage: "Device's 📷 unusable right now!")
            }
        }
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func savePressed(_ sender: UIButton) {
        userSettings.setWallpaper(image: selectedImage!)
        let informUser = UIAlertController(title: "Success", message: "Wallpaper changed successfully 🎉", preferredStyle: .alert)
        informUser.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            // Return to settings view
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(informUser, animated: true, completion: nil)
    }
    
    func showCustomErrorMsgWithAlert(errorMessage: String) {
        let alert = UIAlertController(title: "Warning", message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
        let cancelButton = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
    }
}

extension WallpaperController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK :- Adjust pagination indicator dots and current card header
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let allCells = collectionView.visibleCells as! [ImageCell]
        allCells.forEach { (currentCell) in
            currentCell.setUnSelected()
            currentCell.focusIsLost()
        }        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // in case you you want the cell to be 80% of your controllers view
        return CGSize(width: width * 0.8, height: height * 0.9)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return StaticDatas.sharedInstance.imageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let customCell  = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        customCell.imageContainer.image = StaticDatas.sharedInstance.imageList[indexPath.item]
        return customCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentCell = collectionView.cellForItem(at: indexPath) as! ImageCell
        selectedImage = currentCell.imageContainer.image!
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if picker.sourceType == .camera {
            cameraIcon.image = info[UIImagePickerControllerEditedImage] as? UIImage
            self.selectedImage = cameraIcon.image
            imageContainer.image = #imageLiteral(resourceName: "SelectFromGalery")
        } else {
            imageContainer.image = info[UIImagePickerControllerEditedImage] as? UIImage
            self.selectedImage = imageContainer.image
            cameraIcon.image = #imageLiteral(resourceName: "SelectFromCamera")
        }
        self.dismiss(animated: true, completion: nil)
    }
}
