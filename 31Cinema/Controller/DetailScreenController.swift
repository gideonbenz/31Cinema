//
//  DetailScreenController.swift
//  31Cinema
//
//  Created by Gideon Benz on 07/05/19.
//  Copyright © 2019 Gideon Benz. All rights reserved.
//

import UIKit
import CoreData

class DetailScreenController: UIViewController {
    @IBOutlet weak var detailTitleTextLabel: UILabel!
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var detailRatingValueLabel: UILabel!
    @IBOutlet weak var detailReleaseTextLabel: UILabel!
    @IBOutlet weak var detailOriginLanguageTextLabel: UILabel!
    @IBOutlet weak var detailOverviewTextLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var moviesCoreData: [MoviesCoreData?]?
    var favoritedCoreData: [FavoritedMoviesCoreData?]?
    var selectedIndexPath: Int?
    var favorited = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDataSource()
    }
    
    private func configureDataSource() {
        guard let selectedIndex = selectedIndexPath
        else { return }
        if let moviesCoreDatas = moviesCoreData {
            detailTitleTextLabel.text = moviesCoreDatas[selectedIndex]?.title ?? ""
            detailImageView.image = UIImage(data: moviesCoreDatas[selectedIndex]?.image ?? Data())
            detailRatingValueLabel.text = String(moviesCoreDatas[selectedIndex]?.voteAverage ?? 0.0)
            let date = convertDateFormaterToNormal(moviesCoreDatas[selectedIndex]?.releaseDate ?? "")
            detailReleaseTextLabel.text = date
            detailOverviewTextLabel.text = moviesCoreDatas[selectedIndex]?.overview ?? ""
            detailOriginLanguageTextLabel.text = moviesCoreDatas[selectedIndex]?.originalLanguage ?? ""
            detailOriginLanguageTextLabel.sizeToFit()
        }
        else {
            if let favoriteCoreDatas = favoritedCoreData {
                detailTitleTextLabel.text = favoriteCoreDatas[selectedIndex]?.title ?? ""
                detailImageView.image = UIImage(data: favoriteCoreDatas[selectedIndex]?.image ?? Data())
                detailRatingValueLabel.text = String(favoriteCoreDatas[selectedIndex]?.voteAverage ?? 0.0)
                let date = convertDateFormaterToNormal(favoriteCoreDatas[selectedIndex]?.releaseDate ?? "")
                detailReleaseTextLabel.text = date
                detailOverviewTextLabel.text = favoriteCoreDatas[selectedIndex]?.overview ?? ""
                detailOriginLanguageTextLabel.text = favoriteCoreDatas[selectedIndex]?.originalLanguage ?? ""
                detailOriginLanguageTextLabel.sizeToFit()
                favoriteButton.setTitle("Favorited", for: .normal)
                favoriteButton.tintColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
            }
        }
    }
    
    private func saveToFavorite() {
        let context = PersistenceService.persistentContainer.viewContext
        if let favoritedMoviesEntityDescription = NSEntityDescription.entity(forEntityName: CoreDataConstant.entityFavoritedMovie, in: context) {
                    guard let selectedIndexPath = selectedIndexPath else { return }
            
                    let favoriteMovies = NSManagedObject(entity: favoritedMoviesEntityDescription, insertInto: context)
                    favoriteMovies.setValue(moviesCoreData?[selectedIndexPath]?.title ?? "" , forKey: CoreDataConstant.title)
                    favoriteMovies.setValue(moviesCoreData?[selectedIndexPath]?.overview ?? "", forKey: CoreDataConstant.overview)
                    favoriteMovies.setValue(moviesCoreData?[selectedIndexPath]?.originalLanguage ?? "", forKey: CoreDataConstant.originalLanguage)
                    favoriteMovies.setValue(moviesCoreData?[selectedIndexPath]?.releaseDate ?? "", forKey: CoreDataConstant.releaseDate)
                    favoriteMovies.setValue(moviesCoreData?[selectedIndexPath]?.voteAverage ?? 0.0, forKey: CoreDataConstant.voteAverage)
                    favoriteMovies.setValue(moviesCoreData?[selectedIndexPath]?.image ?? Data(), forKey: CoreDataConstant.image)
                    favoriteMovies.setValue(selectedIndexPath, forKey: CoreDataConstant.id)
                    do {
                        _ = try PersistenceService.saveContext()
                    }
                    catch let error as Error {
                        print("error Save",error)
                    }
        }
        DataManager.shared.favoriteScreenController.fetchCoreData { (favoritedCoreData) in
            DataManager.shared.favoriteScreenController.favoritedCoreData = favoritedCoreData
        }
    }
    
    private func deleteFromFavorite() {
        let managedContext = PersistenceService.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<FavoritedMovie>(entityName:CoreDataConstant.entityFavoritedMovie)
        guard let selectedIndexPath = self.selectedIndexPath else { return }
        fetchRequest.predicate = NSPredicate(format: "title == %@",moviesCoreData?[selectedIndexPath]?.title ?? "")
        do
        {
            let fetchedResults =  try managedContext.execute(fetchRequest) as? [NSManagedObject]
            for entity in fetchedResults! {
                managedContext.delete(entity)
                print(entity)
            }
        }
        catch _ {
            print("Could not delete")
            
        }
        
        do {
            try PersistenceService.saveContext()
        } catch  {print("Error: Save delete favorite")}
    }
    
    @IBAction func addAsFavorite(_ sender: UIButton) {
        if favorited {
            deleteFromFavorite()
            sender.setTitle("+Favorite", for: .normal)
            sender.tintColor = #colorLiteral(red: 0, green: 0.8235294118, blue: 0.5568627451, alpha: 1)
        }
        else {
            saveToFavorite()
            sender.setTitle("Favorited", for: .normal)
            sender.tintColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
            let alert = UIAlertController(title: "Saved to Favorited", message: "You can open your favorited movies in Favorites Tab", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        favorited = !favorited
    }
}

extension DetailScreenController {
    private func convertDateFormaterToNormal(_ date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "dd MMMM yyyy"
        return  dateFormatter.string(from: date!)
    }
}
