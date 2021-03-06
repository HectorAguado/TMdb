//
//  ShowPresenter.swift
//  TMDbCore
//
//  Created by Hector Aguado on 17/12/2018.
//  Copyright © 2018 Guille Gonzalez. All rights reserved.
//

import RxSwift

final class ShowPresenter: DetailPresenter {
    
    private let detailNavigation: PushDetailNavigator
    
    private let repository: ShowRepositoryProtocol
    private let identifier: Int64
    private let disposeBag = DisposeBag()
    
    weak var view: DetailView?

    init(detailNavigation: PushDetailNavigator, repository: ShowRepositoryProtocol, identifier: Int64) {
        self.repository = repository
        self.identifier = identifier
        self.detailNavigation = detailNavigation
    }
    
    func didLoad() {
        view?.setLoading(true)
        
        repository.show(withIdentifier: identifier)
            .map { [weak self] show in
                self?.detailSections(for: show) ?? []
            }
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] sections in
                    self?.view?.update(with: sections)
                },
                onDisposed: { [weak self] in
                    self?.view?.setLoading(false)
            })
            .disposed(by: disposeBag)
    }
    
    func didSelect(item: PosterStripItem) {
        detailNavigation.navigateToPerson(withIdentifier: item.identifier)
    }
    
    private func detailSections(for show: ShowDetail) -> [DetailSection] {
        var detailSections: [DetailSection] = [
            .header(DetailHeader(show: show))
        ]
        
        if let overview = show.overview {
            detailSections.append(.about(title: "Overview", detail: overview))
        }
        
        let items = show.credits?.cast.map { PosterStripItem(castMember: $0) }
        
        if let items = items {
            detailSections.append(.posterStrip(title: "Cast", items: items))
        }
        
        return detailSections
    }
}


