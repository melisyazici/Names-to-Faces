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
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) { // if the camera option is available
            let ac = UIAlertController(title: "Source", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Photos", style: .default, handler: { [weak self, weak ac] _ in
                self?.showPickerOptions(fromCamera: false) // if the user selects photos, camera won't turn on
            }))
            
            ac.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self, weak ac] _ in
                self?.showPickerOptions(fromCamera: true) // if the user selects camera, camera will turn on
            }))
            
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            ac.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem // for the ipad compatibility
            
            present(ac, animated: true)
        } else { // if the camera option is not available
            showPickerOptions(fromCamera: false)
        }
    }
    
    func showPickerOptions(fromCamera: Bool) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        if fromCamera {
            picker.sourceType = .camera
        }
        
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
        
        let person = people[indexPath.item]
        
        cell.name.text = person.name // assign person's name to the text of UILabel
        
        let path = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
    // triggered when the user taps a cell
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let person = people[indexPath.item]
        
        let ac = UIAlertController(title: "Person", message: nil, preferredStyle: .alert)
//        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Rename Person", style: .default, handler: { [weak self, weak ac] _ in
            self?.renamePerson(person)
        }))
        
        ac.addAction(UIAlertAction(title: "Delete Person", style: .default, handler: { [weak self, weak ac] _ in
            self?.deletePerson(at: indexPath)
        }))
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // for ipad compatibility
        if let popoverController = ac.popoverPresentationController {
            if let cellView = collectionView.cellForItem(at: indexPath) {
                popoverController.sourceView = cellView
                popoverController.sourceRect = CGRect(x: cellView.bounds.midX, y: cellView.bounds.midY, width: 0, height: 0)
            }
        }
        
        present(ac, animated: true)
    }
    
    func renamePerson(_ person: Person) {
        let ac = UIAlertController(title: "Person's name:", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self, weak ac] _ in
            guard let newName = ac?.textFields?[0].text else { return } // pulls out the text field value
            person.name = newName // assign it to the person's name property
            self?.collectionView.reloadData() // reload the collection view to reflect the change
        }))
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func deletePerson(at indexPath: IndexPath) {
        let ac = UIAlertController(title: "Are you sure you want to delete the person?", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { [weak self, weak ac] _ in
            self?.people.remove(at: indexPath.item)
            self?.collectionView.reloadData()
        }))
        
        present(ac, animated: true)
    }


}

