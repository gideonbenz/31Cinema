//
//  FavoritedScreenController.swift
//  31Cinema
//
//  Created by Gideon Benz on 07/05/19.
//  Copyright © 2019 Gideon Benz. All rights reserved.
//

import UIKit
import CoreData

class FavoritedScreenController: UIViewController {
    @IBOutlet weak var favoritedCollectionView: UICollectionView!
    var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    var favoritedCoreData : [FavoritedMoviesCoreData?]?
    var selectedIndexPath: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        configureCoreData()
        favoritedCollectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        setupCollectionCellItemSize()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.toDetailScreen {
            let detailNewsController = segue.destination as! DetailScreenController
            guard let selectedIndexPath = selectedIndexPath,
                let favoriteCoreDatas = favoritedCoreData
                else { return }
            
            detailNewsController.selectedIndexPath = selectedIndexPath
            detailNewsController.favoritedCoreData = favoriteCoreDatas
        }
    }
    
    private func configureCollectionView() {
        favoritedCollectionView.delegate = self
        favoritedCollectionView.dataSource = self
        let nib = UINib(nibName: Constant.moviesNibCollectionCell, bundle: nil)
        favoritedCollectionView.register(nib, forCellWithReuseIdentifier: Constant.moviesIdentifierCollectionCell)
    }
    
    private func setupCollectionCellItemSize() {
        if collectionViewFlowLayout == nil {
            let numberOfItemPerRow: CGFloat = 2
            let lineSpacing: CGFloat = 2
            let interItemSpacing: CGFloat = 2
            let size = (favoritedCollectionView.frame.width - (numberOfItemPerRow - 1) * interItemSpacing) / lineSpacing
            collectionViewFlowLayout = UICollectionViewFlowLayout()
            collectionViewFlowLayout.itemSize = CGSize(width: size, height: size)
            collectionViewFlowLayout.sectionInset = UIEdgeInsets.zero
            collectionViewFlowLayout.minimumLineSpacing = lineSpacing
            collectionViewFlowLayout.minimumInteritemSpacing = interItemSpacing
            collectionViewFlowLayout.scrollDirection = .vertical
            favoritedCollectionView.setCollectionViewLayout(collectionViewFlowLayout, animated: true)
        }
    }
    
    private func configureCoreData() {
        fetchCoreData { (favoritedCoreData) in
            self.favoritedCoreData = favoritedCoreData
            self.favoritedCollectionView.reloadData()
        }
    }
    
    func fetchCoreData(completion: ([FavoritedMoviesCoreData?]) -> Void) {
        var favoriteCoreDatas = [FavoritedMoviesCoreData?]()
        let fetchRequest: NSFetchRequest<FavoritedMovie> = FavoritedMovie.fetchRequest()
        do {
            let favoritedMovieDatas = try PersistenceService.context.fetch(fetchRequest)
            for favoritedMovieData in favoritedMovieDatas {
                let favoritedMovieCoreData = FavoritedMoviesCoreData(movieCoreData: favoritedMovieData)
                favoriteCoreDatas.append(favoritedMovieCoreData)
            }
            completion(favoriteCoreDatas)
        } catch {
            print("error fetch core data")
        }
    }
}

extension FavoritedScreenController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if favoritedCoreData != nil {
            return favoritedCoreData?.count ?? 0
        }
        else {
              return 10
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if favoritedCoreData != nil {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.moviesIdentifierCollectionCell, for: indexPath) as! MoviesCollectionViewCell
            cell.moviesImageView.image = UIImage(data: favoritedCoreData?[indexPath.row]?.image ?? Data())
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.moviesIdentifierCollectionCell, for: indexPath) as! MoviesCollectionViewCell
        cell.moviesImageView.image = UIImage(named: "1")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath.row
        performSegue(withIdentifier: Segue.toDetailScreen, sender: self.prepare)
    }
    
    
}
