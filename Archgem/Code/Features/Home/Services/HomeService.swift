//
//  HomeService.swift
//  Archgem
//
//  Created by Elias Haddad on 11/18/23.
//

import Foundation
import MapKit
import CoreLocation

class HomeService {
    var api:API
    var loc_parameters:GemQuery
    
    init() {
        api = API(to: "/Home/")
        loc_parameters = GemQuery()
    }
    
    func searchGems(params: GemQuery)async->[Gem]? {
        var results:GemResponse?
        do {
            let ret = try await api.makeAsyncRequest("POST", endpoint: "Search/", with:params)
            results = try? JSONDecoder().decode(GemResponse.self, from:ret)
        }
        catch {
            print("ERROR RETRIEVING GEMS")
        }
        
        return results?.gems
    }
}
