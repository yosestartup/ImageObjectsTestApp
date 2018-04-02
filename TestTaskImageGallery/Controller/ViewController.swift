//
//  ViewController.swift
//  TestTaskImageGallery
//
//  Created by Oleksandr Bambulyak on 30.03.2018.
//  Copyright © 2018 Oleksandr Bambulyak. All rights reserved.
//

import UIKit
import RealmSwift
class ViewController: UITableViewController {

    var imageTitles = [String]()
    var imagePaths = [String]()
    var imageDescriptions = [String]()
    var imageDates = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        tableView.dataSource = self
        tableView.delegate = self
        var cellId = "cellId"
        tableView.register(PhotoCell.self, forCellReuseIdentifier: cellId)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadImageObjects()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as? PhotoCell

        cell?.textLabel?.text = imageTitles[indexPath.row]
  
        let tempImage: UIImage = UIImage(named: "logo-mark")!
       
        if let url = URL(string: imagePaths[indexPath.row]) {
            do {
                let imageData = try Data(contentsOf: url as URL)
                cell?.profileImage.image = UIImage(data: imageData)
            } catch {
                cell?.profileImage.image = tempImage
                print("Unable to load data: \(error)")
            }
        }
        cell?.timeLabel.text = imageDates[indexPath.row]
        cell?.detailTextLabel?.text = imageDescriptions[indexPath.row]
        return cell!
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageTitles.count
    }
    
    @objc func handleAddImage() {
        let secondViewController = AddImageViewController()
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 99
    }
    
    func loadImageObjects() {
        
        imageTitles.removeAll()
        imagePaths.removeAll()
        imageDescriptions.removeAll()
        imageDates.removeAll()
        
        let realm = try! Realm()
        let allImages = realm.objects(ImageObject.self)
        for object in allImages {
            imageTitles.append(object.imageTitle)
            imageDescriptions.append(object.imageDescription)
            imagePaths.append(object.imagePath)
            imageDates.append(object.imageDate)
        }
        
    }

    func setupUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddImage))
        view.backgroundColor = UIColor.white
    }
}

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}

