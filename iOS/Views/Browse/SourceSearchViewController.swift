//
//  SourceSearchViewController.swift
//  Aidoku (iOS)
//
//  Created by Skitty on 1/23/22.
//

import UIKit

class SourceSearchViewController: MangaCollectionViewController {
    
    let source: Source
    var query: String?
    
    let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    init(source: Source, query: String? = nil) {
        self.source = source
        self.query = query
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        title = "Search"
        navigationItem.largeTitleDisplayMode = .never
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        searchController.searchBar.text = query
        
        navigationItem.hidesSearchBarWhenScrolling = false
        
        activityIndicator.startAnimating()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        Task {
            await doSearch()
            UIView.animate(withDuration: 0.3) {
                self.activityIndicator.alpha = 0
            }
            reloadData()
        }
    }
    
    func doSearch() async {
        let result = try? await source.fetchSearchManga(query: query ?? "")
        manga = result?.manga ?? []
    }
}

// MARK: - Search Bar Delegate
extension SourceSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard searchBar.text != query else { return }
        query = searchBar.text
        manga = []
        reloadData()
        activityIndicator.alpha = 1
        Task {
            await doSearch()
            UIView.animate(withDuration: 0.3) {
                self.activityIndicator.alpha = 0
            }
            reloadData()
        }
    }
}
