//
//  RestaurantData.swift
//  Sorted
//
//  Created by NgQuocThang on 1/5/19.
//  Copyright © 2019 NgQuocThang. All rights reserved.
//


// Follow class tutorial
import UIKit

class RestaurantListData: NSObject, Decodable {
    var restaurants: [RestaurantData]?
    
    private enum CodingKeys: String, CodingKey {
        case restaurants = "restaurants"
    }
}

class RestaurantData: NSObject, Decodable {
    var id: String
    var name: String
    var address: String
    var latitude: String
    var longitude: String
    var aggregate_rating: String
    var average_cost_for_two: Int
    var price_range: Int
    var rating_color: String
    var cuisine: String
    var rating_text: String
    var phone_numbers: String
    var votes: String
    var currency: String
    
    private enum RootKeys: String, CodingKey {
        case restaurant
    }
    private enum RestaurantKeys: String, CodingKey {
        case id
        case name
        case location
        case cuisines
        case average_cost_for_two
        case price_range
        case user_rating
        case phone_numbers
        case currency
    }
    private enum locationKeys: String, CodingKey {
        case address
        case latitude
        case longitude
    }
    
    private enum ratingKeys: String, CodingKey {
        case aggregate_rating
        case rating_color
        case rating_text
        case votes
    }

    required init(from decoder: Decoder) throws {
        // Get the root container first
        let rootContainer = try decoder.container(keyedBy: RootKeys.self)
        // Get the container has restaurant details
        let restaurantContainer = try rootContainer.nestedContainer(keyedBy: RestaurantKeys.self, forKey: .restaurant)
        // Get container has location details
        let locationContainer = try? restaurantContainer.nestedContainer(keyedBy: locationKeys.self, forKey: .location)
        let ratingContainer = try? restaurantContainer.nestedContainer(keyedBy: ratingKeys.self, forKey: .user_rating)
        
        self.id = try restaurantContainer.decode(String.self, forKey: .id)
        self.name = try restaurantContainer.decode(String.self, forKey: .name)
        self.cuisine = try restaurantContainer.decode(String.self, forKey: .cuisines)
        self.currency = try restaurantContainer.decode(String.self, forKey: .currency)
        do {
            self.average_cost_for_two = try restaurantContainer.decode(Int.self, forKey: .average_cost_for_two)
        } catch {
            self.average_cost_for_two = 0
        }
        do {
            self.price_range = try restaurantContainer.decode(Int.self, forKey: .price_range)
        } catch {
            self.price_range = 0
        }
        do {
            self.phone_numbers = try restaurantContainer.decode(String.self, forKey: .phone_numbers)
        } catch {
            self.phone_numbers = "Not Available"
        }
        
        self.address = try (locationContainer?.decode(String.self, forKey: .address))!
        self.longitude = try (locationContainer?.decode(String.self, forKey: .longitude))!
        self.latitude = try (locationContainer?.decode(String.self, forKey: .latitude))!
        
        do {
            self.aggregate_rating = try (ratingContainer?.decode(String.self, forKey: .aggregate_rating))!
        } catch {
            self.aggregate_rating = "-"
        }
//        self.aggregate_rating = try ratingContainer?.decode(String.self, forKey: .aggregate_rating)
        self.rating_color = try (ratingContainer?.decode(String.self, forKey: .rating_color))!
        self.rating_text = try (ratingContainer?.decode(String.self, forKey: .rating_text))!
        do {
            self.votes = try (ratingContainer?.decode(String.self, forKey: .votes))!
        } catch {
            self.votes = "Not available"
        }
    }
}
