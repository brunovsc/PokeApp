//
//  PokemonDetailsViewModel.swift
//  PokeApp
//
//  Created by Eduardo Sanches Bocato on 22/05/18.
//  Copyright © 2018 Bocato. All rights reserved.
//

import Foundation
import RxSwift

class PokemonDetailsViewModel {
    
    // MARK: - ViewState
    enum PokemonDetailsViewState {
        case loading(Bool)
        case error(NetworkError)
        case noData
    }
    
    // MARK: - Dependencies
    private let pokemonService = PokemonService()
    private let disposeBag = DisposeBag()
    
    // MARK: - Properties
    private var pokemonId: Int
    var isLoadingPokemonImage = Variable<Bool>(true)
    var viewState = Variable<PokemonDetailsViewState>(.loading(true))
    private var pokemonData: Pokemon?
    var pokemonImage = Variable<UIImage?>(nil)
    var pokemonNumber = Variable<String?>(nil)
    var pokemonName = Variable<String?>(nil)
    var pokemonAbilities = Variable<[String]>([])
    var pokemonStats = Variable<[String]>([])
    var pokemonMoves = Variable<[String]>([])

    // MARK: - Initialization
    required init(pokemonId: Int) {
        self.pokemonId = pokemonId
    }
    
    // MARK: - API Calls
    func loadPokemonData() {
        viewState.value = .loading(true)
        pokemonService.getDetailsForPokemon(withId: pokemonId)
            .subscribe(onNext: { (pokemonData, _) in
                
                guard let pokemonData = pokemonData,
                    let imageURL = pokemonData.imageURL,
                    let number = pokemonData.id,
                    let name = pokemonData.name,
                    let abilities = pokemonData.abilities,
                    let stats = pokemonData.stats,
                    let moves = pokemonData.moves else {
                        self.viewState.value = .noData
                    return
                }
                
                self.pokemonData = pokemonData
                
                self.downloadImage(from: imageURL)
                self.pokemonNumber.value = "#\(number)"
                self.pokemonName.value = name.capitalizingFirstLetter()
                self.pokemonAbilities.value = self.extractAbilityNames(from: abilities)
                self.pokemonStats.value = self.extractStatStrings(from: stats)
                self.pokemonMoves.value = self.extractMoveStrings(from: moves)
                
            }, onError: { (error) in
                let networkError = error as! NetworkError
                self.viewState.value = .error(networkError)
            }, onCompleted: {
                self.viewState.value = .loading(false)
            })
            .disposed(by: disposeBag)
    }
    
    private func downloadImage(from itemURL: String?) {
        guard let urlString = itemURL, let imageURL = URL(string: urlString) else {
            pokemonImage.value = UIImage.fromResource(withName: .openPokeball)
            self.isLoadingPokemonImage.value = false
            return
        }
        DispatchQueue.main.async {
            let pokemonImageViewHolder = UIImageView()
            pokemonImageViewHolder.kf.setImage(with: imageURL, placeholder: nil, options: nil, progressBlock: nil) { (image, error, cache, url) in
                guard error != nil else {
                    self.pokemonImage.value = image
                    self.isLoadingPokemonImage.value = false
                    return
                }
            }
        }
    }
    
    private func extractAbilityNames(from abilities: [Ability]) -> [String] {
        var abilityNames = [String]()
        for ability in abilities {
            if let abilityName = ability.ability?.name?.capitalizingFirstLetter() {
                abilityNames.append(abilityName)
            }
        }
        return abilityNames
    }
    
    private func extractStatStrings(from stats: [Stat]) -> [String] {
        var statStrings = [String]()
        for stat in stats {
            if let statName = stat.stat?.name?.capitalizingFirstLetter(), let baseStat = stat.baseStat {
                let statString = "\(statName) (\(baseStat))"
                statStrings.append(statString)
            }
        }
        return statStrings
    }
    
    private func extractMoveStrings(from moves: [Move]) -> [String] {
        var moveStrings = [String]()
        for move in moves {
            if let moveName = move.move?.name?.capitalizingFirstLetter(), let learnedAtLevel = move.versionGroupDetails?.first?.levelLearnedAt {
                let moveString = "\(moveName) - Learned at LVL: \(learnedAtLevel)"
                moveStrings.append(moveString)
            }
        }
        return moveStrings
    }
    
}