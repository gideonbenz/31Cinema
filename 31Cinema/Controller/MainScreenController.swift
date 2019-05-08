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
    @IBOutlet weak var moviesSearchBar: UISearchBar!
    
    var collectionViewFlowLayout: UICollectionViewFlowLayout!
    var moviesObjects : MoviesObjects?
    var moviesCoreData : [MoviesCoreData?]?
    var moviesDataSearch = [MoviesCoreData?]()
    var isConnected = false
    var isSearching = false
    let dispatchGroup = DispatchGroup()
    var imageDatas = [Data]()
    var selectedIndexPath: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureNetwork()
        configureSearchBar()
    }
    override func viewDidLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupCollectionCellItemSize()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.toDetailScreen {
            let detailNewsController = segue.destination as! DetailScreenController
            if isSearching {
                guard let selectedIndexPath = selectedIndexPath
                    else { return }
                detailNewsController.selectedIndexPath = selectedIndexPath
                detailNewsController.moviesCoreData = moviesDataSearch
            }
            else {
                guard let selectedIndexPath = selectedIndexPath,
                    let moviesCoreDatas = moviesCoreData
                    else { return }
                detailNewsController.selectedIndexPath = selectedIndexPath
                detailNewsController.moviesCoreData = moviesCoreDatas
            }
        }
    }
    
    private func configureNetwork() {
        let connectionStatus = Reachability().checkReachable()
        connectionStatus ? isConnected == true : isConnected == false
        if isConnected {
            fetchCoreData { (moviesCoreData) in
                let alert = UIAlertController(title: "No Connection", message: "please turn on your internet connection and re-open the apps to update new movies", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                self.moviesCoreData = moviesCoreData
                self.moviesCollectionView.reloadData()
            }
        }
        else {
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
        
    }
    
    private func configureCollectionView() {
        moviesCollectionView.delegate = self
        moviesCollectionView.dataSource = self
        let nib = UINib(nibName: Constant.moviesNibCollectionCell, bundle: nil)
        moviesCollectionView.register(nib, forCellWithReuseIdentifier: Constant.moviesIdentifierCollectionCell)
    }
    
    private func configureSearchBar() {
        moviesSearchBar.delegate = self
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
        if let currentMoviesEntityDescription = NSEntityDescription.entity(forEntityName: CoreDataConstant.entityCurrentMovie, in: context) {
            if !firstRun {
                for i in 0..<title.count {
                    let currentMovies = NSManagedObject(entity: currentMoviesEntityDescription, insertInto: context)
                    currentMovies.setValue(title[i], forKey: CoreDataConstant.title)
                    currentMovies.setValue(overview[i], forKey: CoreDataConstant.overview)
                    currentMovies.setValue(originalLanguage[i], forKey: CoreDataConstant.originalLanguage)
                    currentMovies.setValue(releaseDate[i], forKey: CoreDataConstant.releaseDate)
                    currentMovies.setValue(voteAverage[i], forKey: CoreDataConstant.voteAverage)
                    currentMovies.setValue(imageDatas[i], forKey: CoreDataConstant.image)
                    currentMovies.setValue(i, forKey: CoreDataConstant.id)
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
            else {
                updateCoreData(title: title, overview: overview, originalLanguage: originalLanguage, releaseDate: releaseDate, voteAverage: voteAverage, imageDatas: imageDatas) { (movieCoreDatas) in
                    DispatchQueue.main.async {
                        self.moviesCoreData = movieCoreDatas
                        self.moviesCollectionView.reloadData()
                    }
                }
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
    
    private func updateCoreData(title: [String], overview: [String], originalLanguage: [String], releaseDate: [String], voteAverage: [Double], imageDatas: [Data], completion: ([MoviesCoreData?]) -> Void) {
        let context = PersistenceService.persistentContainer.viewContext
        let request = NSBatchUpdateRequest(entityName: CoreDataConstant.entityCurrentMovie)
        
        for i in 0..<title.count {
            request.propertiesToUpdate = [CoreDataConstant.title: title[i]]
            request.propertiesToUpdate = [CoreDataConstant.overview: overview[i]]
            request.propertiesToUpdate = [CoreDataConstant.voteAverage: voteAverage[i]]
            request.propertiesToUpdate = [CoreDataConstant.releaseDate: releaseDate[i]]
            request.propertiesToUpdate = [CoreDataConstant.originalLanguage: originalLanguage[i]]
            request.propertiesToUpdate = [CoreDataConstant.image: imageDatas[i]]
            request.propertiesToUpdate = [CoreDataConstant.id: i]
            do {
                try context.execute(request) as! NSBatchUpdateResult
            }
            catch {
                print("failed update")
            }
            fetchCoreData { (moviesCoredata) in
                completion(moviesCoredata)
            }
        }
    }
}

extension MainScreenController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isSearching {
                return self.moviesDataSearch.count
        }
        else {
            if self.moviesCoreData != nil {
                return self.moviesCoreData?.count ?? 0
            }
            else {
                return 10
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isSearching {
            if self.moviesDataSearch != nil {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.moviesIdentifierCollectionCell, for: indexPath) as! MoviesCollectionViewCell
                cell.moviesImageView.image = UIImage(data: moviesDataSearch[indexPath.row]?.image ?? Data())
                return cell
            }
            else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.moviesIdentifierCollectionCell, for: indexPath) as! MoviesCollectionViewCell
                cell.moviesImageView.image = UIImage(named: "1")
                return cell
            }
        }
        else {
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        selectedIndexPath = indexPath.row
        performSegue(withIdentifier: Segue.toDetailScreen, sender: self.prepare)
    }
}

extension MainScreenController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            isSearching = false
            moviesCollectionView.reloadData()
        }
        else {
            moviesDataSearch = moviesCoreData?.filter({($0!.title.lowercased().prefix(searchText.count)) == searchText.lowercased()}) as! [MoviesCoreData]
            isSearching = true
            moviesCollectionView.reloadData()
        }
    }
}
