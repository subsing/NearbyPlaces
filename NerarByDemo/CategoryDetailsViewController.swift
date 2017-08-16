//
//  CategoryDetailsViewController.swift
//  NerarByDemo
//
//  Created by Subhankar Singha on 8/13/17.
//  Copyright © 2017 Subhankar Singha. All rights reserved.
//

import UIKit

class CategoryDetailsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var detailsCollectionView: UICollectionView!
    let reuseIdentifier = "cell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Places list"
        self.detailsCollectionView.register(UINib(nibName: "PlacesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ServiceData.vicinity.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! PlacesCollectionViewCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        if ServiceData.openNow[indexPath.item] == 0 {
            cell.lblOpenOrClosed.text = "Open"
        }
        else {
            cell.lblOpenOrClosed.text = "Closed"
        }
        cell.vicinity.text = ServiceData.vicinity[indexPath.item]
        cell.placeName.text = ServiceData.palceName[indexPath.item]
        if indexPath.row < ServiceData.palceName.count {
        let url = URL(string: ServiceData.icon[indexPath.row])
        let data = try? Data(contentsOf: url!)
        
        if data != nil {
            let image = UIImage(data: data!)
            cell.placeImage.image = image
            }
        }
        for _ in ServiceData.types{
             let typesData = ServiceData.types[indexPath.item]
            if typesData.count > indexPath.row {
                cell.firstType.text = "\u{2022} \(typesData[0])"
                cell.secondType.text = "\u{2022} \(typesData[1])"
                cell.thirdtype.text = "\u{2022} \(typesData[2])"
            }
        }
       
        cell.backgroundColor = UIColor.cyan
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 10
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let size: CGSize = CGSize(width: collectionView.bounds.size.width, height: 200.0)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
        let detailsPage: DetailsMapViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailsMapViewController") as! DetailsMapViewController
        detailsPage.selectedIndex = indexPath.item
        self.navigationController?.pushViewController(detailsPage, animated: true)

        
    }
}
