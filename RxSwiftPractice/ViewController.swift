//
//  ViewController.swift
//  RxSwiftPractice
//
//  Created by Dinh Thanh An on 4/20/17.
//  Copyright © 2017 Dinh Thanh An. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import ObjectMapper
import RxAlamofire

//struct Repository: Mappable {
//    
//    let identifier: Int
//    let language: String
//    let name: String
//    let fullName: String
//    
//    init(map: Mapper) throws {
//        try identifier = map.from("id")
//        try language = map.from("language")
//        try name = map.from("name")
//        try fullName = map.from("full_name")
//    }
//}
//
//struct Issue: Mappable {
//    
//    let identifier: Int
//    let number: Int
//    let title: String
//    let body: String
//    
//    init(map: Mapper) throws {
//        try identifier = map.from("id")
//        try number = map.from("number")
//        try title = map.from("title")
//        try body = map.from("body")
//    }
//}

class RepositoriesViewController: UIViewController {
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    let disposeBag = DisposeBag()
    var repositoryNetworkModel: RepositoryNetworkModel!
    
    var rx_searchBarText: Observable<String> {
        return searchBar
            .rx
            .text
            .filter { $0!.characters.count > 0 }
            .throttle(0.5, scheduler : MainScheduler.instance)
            .map(){text -> String in
                if(text == nil){
                    return ""
                }else{
                    return text!
                }
            }
            .distinctUntilChanged()
    }
    
//    var issueTrackerModel: IssueTrackerModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRx()
    }
    
    func setupRx() {
        repositoryNetworkModel = RepositoryNetworkModel(withNameObservable: rx_searchBarText)
        
        repositoryNetworkModel
            .rx_repositories
            .drive(tableView.rx.items) { (tv, i, repository) in
                let cell = tv.dequeueReusableCell(withIdentifier: "repositoryCell", for: IndexPath(row: i, section: 0))
                cell.textLabel?.text = repository.name
                
                return cell
            }
            .addDisposableTo(disposeBag)
        
        repositoryNetworkModel
            .rx_repositories
            .drive(onNext: { repositories in
                if repositories.count == 0 {
                    let alert = UIAlertController(title: ":(", message: "No repositories for this user.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    if self.navigationController?.visibleViewController?.isMember(of: UIAlertController.self) != true {
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            })
            .addDisposableTo(disposeBag)
    }
    
}
