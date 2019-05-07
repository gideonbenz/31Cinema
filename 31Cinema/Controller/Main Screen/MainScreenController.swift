//
//  MainScreenController.swift
//  31Cinema
//
//  Created by Gideon Benz on 06/05/19.
//  Copyright © 2019 Gideon Benz. All rights reserved.
//

import UIKit
import CoreData

class MainScreenController: UIViewController {
    @IBOutlet weak var moviesCollectionView: UICollectionView!
    
    var collectionViewFlowLayout: UICollectionViewFlowLayout!
    var moviesObjects : MoviesObjects?
    var moviesCoreData : [MoviesCoreData?]?
    var isConnected = false
    var isSearching = false
    let dispatchGroup = DispatchGroup()
    var imageDatas = [Data]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureNetwork()
    }
    override func viewDidLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupCollectionCellItemSize()
    }
    
    private func configureNetwork() {
        let networkService = NetworkService()
        networkService.getMovieService { (movies) in
            self.moviesObjects = movies
            let moviesCount = movies?.movieResult.count ?? 0
            var getImageString = [String]()
            if let imageString = movies?.movieResult {
                for i in 0..<moviesCount {
                    getImageString.append("https://image.tmdb.org/t/p/w500/\(imageString[i]?.imageString ?? "")")
                }
            }
            self.getImageBinaryData(imageString: getImageString, completion: { (nilData) in
                let mappedTitle = self.moviesObjects?.movieResult.map{$0?.title ?? ""}
                let mappedOverview = self.moviesObjects?.movieResult.map{$0?.overview ?? ""}
                let mappedOriginalLanguage = self.moviesObjects?.movieResult.map{$0?.originalLanguage ?? ""}
                let mappedReleaseDate = self.moviesObjects?.movieResult.map{$0?.releaseDate ?? ""}
                let mappedVoteAverage = self.moviesObjects?.movieResult.map{$0?.voteAverage ?? 0}
                
                guard let title = mappedTitle,
                    let overview = mappedOverview,
                    let originalLanguage = mappedOriginalLanguage,
                    let releaseDate = mappedReleaseDate,
                    let voteAverage = mappedVoteAverage
                else { return }
                
                self.setCacheCoreDataCotainer(title: title, overview: overview, originalLanguage: originalLanguage, releaseDate: releaseDate, voteAverage: voteAverage, imageDatas: self.imageDatas)
            })
        }
    }
    
    private func configureView() {
        moviesCollectionView.delegate = self
        moviesCollectionView.dataSource = self
        let nib = UINib(nibName: Constant.moviesNibCollectionCell, bundle: nil)
        moviesCollectionView.register(nib, forCellWithReuseIdentifier: Constant.moviesIdentifierCollectionCell)
    }
    
    private func setupCollectionCellItemSize() {
        if collectionViewFlowLayout == nil {
            let numberOfItemPerRow: CGFloat = 2
            let lineSpacing: CGFloat = 2
            let interItemSpacing: CGFloat = 2
            let size = (moviesCollectionView.frame.width - (numberOfItemPerRow - 1) * interItemSpacing) / lineSpacing
            collectionViewFlowLayout = UICollectionViewFlowLayout()
            collectionViewFlowLayout.itemSize = CGSize(width: size, height: size)
            collectionViewFlowLayout.sectionInset = UIEdgeInsets.zero
            collectionViewFlowLayout.minimumLineSpacing = lineSpacing
            collectionViewFlowLayout.minimumInteritemSpacing = interItemSpacing
            collectionViewFlowLayout.scrollDirection = .vertical
            moviesCollectionView.setCollectionViewLayout(collectionViewFlowLayout, animated: true)
        }
    }
    
    private func getImageBinaryData(imageString: [String] ,completion: @escaping (([Int]) -> Void)) {
        var nilData = [Int]()
        for i in 0..<imageString.count {
            self.imageDatas.append(Data())
            if let url = URL(string: imageString[i]) {
                let request = URLRequest(url: url)
                let networkProcessor = NetworkProcessor(request: request)
                dispatchGroup.enter()
                networkProcessor.downloadDataFromURL { (data, response, error) in
                    if let imageData = data {
                        self.imageDatas[i] = imageData
//                        print(self.imageDatas[i])
                        self.dispatchGroup.leave()
                    }
                }
            }
            else {nilData.append(i)}
        }
        dispatchGroup.notify(queue: .global()) {
            completion(nilData)
        }
    }
    
    private func setCacheCoreDataCotainer(title: [String], overview: [String], originalLanguage: [String], releaseDate: [String], voteAverage: [Double], imageDatas: [Data]) {
        let firstRun = UserDefaults.standard.bool(forKey: "firstRun") as Bool
        let context = PersistenceService.persistentContainer.viewContext
        if let currentMoviesEntityDescription = NSEntityDescription.entity(forEntityName: "CurrentMovie", in: context) {
            if !firstRun {
                for i in 0..<title.count {
                    let currentMovies = NSManagedObject(entity: currentMoviesEntityDescription, insertInto: context)
                    currentMovies.setValue(title[i], forKey: CoreDataConstant.title)
                    currentMovies.setValue(overview[i], forKey: CoreDataConstant.overView)
                    currentMovies.setValue(originalLanguage[i], forKey: CoreDataConstant.originalLanguage)
                    currentMovies.setValue(releaseDate[i], forKey: CoreDataConstant.releaseDate)
                    currentMovies.setValue(voteAverage[i], forKey: CoreDataConstant.voteAverage)
                    currentMovies.setValue(imageDatas[i], forKey: CoreDataConstant.image)
                    do {
                       _ = try PersistenceService.saveContext()
                    }
                    catch let error as Error {
                        print("error Save",error)
                    }
                }
                fetchCoreData { (movieCoreDatas) in
                    
                    DispatchQueue.main.async {
                        self.moviesCoreData = movieCoreDatas
                        self.moviesCollectionView.reloadData()
                    }
                }
                UserDefaults.standard.set(true, forKey: "firstRun")
            }
        }
    }
    
    private func fetchCoreData(completion: ([MoviesCoreData?]) -> Void) {
        var moviesCoreDatas = [MoviesCoreData?]()
        let fetchRequest: NSFetchRequest<CurrentMovies> = CurrentMovies.fetchRequest()
        do {
            let currentMovieDatas = try PersistenceService.context.fetch(fetchRequest)
            for currentMovieData in currentMovieDatas {
                let moviesCoreData = MoviesCoreData(movieCoreData: currentMovieData)
                moviesCoreDatas.append(moviesCoreData)
            }
            completion(moviesCoreDatas)
        } catch {
            print("error fetch core data")
        }
    }
    
}

extension MainScreenController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.moviesCoreData != nil {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.moviesIdentifierCollectionCell, for: indexPath) as! MoviesCollectionViewCell
            cell.moviesImageView.image = UIImage(data: moviesCoreData?[indexPath.row]?.image ?? Data())
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.moviesIdentifierCollectionCell, for: indexPath) as! MoviesCollectionViewCell
            cell.moviesImageView.image = UIImage(named: "1")
            return cell
        }
    }
    
    
}
