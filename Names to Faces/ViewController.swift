//
//  ViewController.swift
//  Names to Faces
//
//  Created by Melis Yazıcı on 31.10.22.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var people = [Person]() // to store all the people in the app

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
    }
    
    @objc func addNewPerson() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true // allows the user to crop the picture they select
        picker.delegate = self // set self as the delegate
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return } // attempt to find the edited image in the dictionary that passed in and typecast to the UIImage
        
        let imageName = UUID().uuidString // uuidString property to extract the unique identifier as a string data type
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName) // to read documents directory for the app and append to that file name "imageName"
        
        // convert the UIImage to a Data object so it can be saved
        if let jpedData = image.jpegData(compressionQuality: 0.8) {
            try? jpedData.write(to: imagePath) // write to the disk
        }
        
        let person = Person(name: "Unknown", image: imageName) // create any person instance passing an unknown name and the image name
        people.append(person) // append it to the people array
        collectionView.reloadData() // reload the collection view
        
        dismiss(animated: true) // dismiss the topmost view controller
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask) // FileManager.default.urls -> ask for the documents directory. We want the path to be relative to the user's home directory
        return paths[0] // returns an array that nearly contains only one thing: the user's documents directory. Pull out the first element and return it.
    }
    
    
    // -- Collection View -- //
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            fatalError("Unable to dequeue PersonCell.")
        }
        return cell
    }


}

