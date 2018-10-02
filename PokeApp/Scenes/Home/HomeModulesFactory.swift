//
//  HomeModulesFactory.swift
//  PokeApp
//
//  Created by Eduardo Sanches Bocato on 12/07/18.
//  Copyright © 2018 Bocato. All rights reserved.
//

import Foundation

protocol HomeModulesFactoryProtocol { // TODO: Refactor...
    // MARK: - Builders
    func buildPokemonDetailsModule(pokemonId: Int,
                                   router: RouterProtocol)
        -> (coordinator: DetailsCoordinatorProtocol, controller: PokemonDetailsViewController)

}

// Implementation
class HomeModulesFactory: HomeModulesFactoryProtocol {
    
    func buildPokemonDetailsModule(pokemonId: Int,
                                   router: RouterProtocol)
        -> (coordinator: DetailsCoordinatorProtocol, controller: PokemonDetailsViewController) {
            
            let pokemonDetailsCoordinator = DetailsCoordinator(router: router)
            let viewModel = PokemonDetailsViewModel(pokemonId: pokemonId, services: PokemonService(), actionsDelegate: pokemonDetailsCoordinator)
            let pokemonDetailsViewController = PokemonDetailsViewController.newInstanceFromStoryBoard(viewModel: viewModel)
            
            return (pokemonDetailsCoordinator, pokemonDetailsViewController)
    }
    
}