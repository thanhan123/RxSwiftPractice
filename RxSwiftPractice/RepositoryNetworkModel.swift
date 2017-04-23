//
//  RepositoryNetworkModel.swift
//  RxSwiftPractice
//
//  Created by Dinh Thanh An on 4/21/17.
//  Copyright © 2017 Dinh Thanh An. All rights reserved.
//

import ObjectMapper
import RxAlamofire
import RxCocoa
import RxSwift

struct RepositoryNetworkModel {
    lazy var rx_repositories: Driver<[Repository]> = self.fetchRepositories()
    private var repositoryName: Observable<String>
    
    init(withNameObservable nameObservable: Observable<String>) {
        self.repositoryName = nameObservable
    }
    
    private func fetchRepositories() -> Driver<[Repository]> {
        return repositoryName
            .subscribeOn(MainScheduler.instance) // Make sure we are on MainScheduler
            .do(onNext: { response in
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            })
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMapLatest { text in
                return RxAlamofire
                    .requestJSON(.get, "https://api.github.com/users/\(text)/repos")
                    .debug()
                    .catchError { error in
                        return Observable.never()
                }
            }
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map { (response, json) -> [Repository] in
                if json is Dictionary<String, Any> {
                    return []
                }
                
                if let repos = Mapper<Repository>().mapArray(JSONArray: json as! [[String : Any]]) {
                    return repos
                } else {
                    return []
                }
        }
        .observeOn(MainScheduler.instance) // switch to MainScheduler, UI updates
        .do(onNext: { response in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        })
        .asDriver(onErrorJustReturn: [])
    }
    
}
