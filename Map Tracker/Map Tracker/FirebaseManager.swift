//
//  FirebaseManager.swift
//  Map Tracker
//
//  Created by Jad Charbatji on 3/23/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
import CoreLocation

class FirebaseManager {
    
    init() {
        signInAnonymously { result in
            switch result {
            case .success:
                print("Signed in anonymously")
            case .failure(let error):
                print("Error signing in anonymously: \(error)")
            }
        }
    }

    
    private let db = Firestore.firestore()

    func signInAnonymously(completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signInAnonymously { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // 'saveRouteToFirestore' method here specifically handles encoding the 'Route' object as JSON and saving it to Firestore under the current user's collection
    
    func saveRouteToFirestore(route: Route, completion: @escaping (Result<Void, Error>) -> Void) {
        //user auth
        guard let userId = Auth.auth().currentUser?.uid else {
                completion(.failure(NSError(domain: "FirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not signed in"])))
                return
            }
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let routeData = try encoder.encode(route)
            let routeJson = try JSONSerialization.jsonObject(with: routeData) as! [String: Any]
            
            db.collection("users").document(userId).collection("routes").addDocument(data: routeJson) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }

    func fetchRoutes(completion: @escaping (Result<[Route], Error>) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not signed in"])))
            return
        }
        
        print("Fetching routes for user: \(userID)")
        
        db.collection("users").document(userID).collection("routes").getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                let routes = snapshot?.documents.compactMap { document -> Route? in
                    let result = Result {
                        let data = try JSONSerialization.data(withJSONObject: document.data(), options: [])
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        return try decoder.decode(Route.self, from: data)
                    }
                    switch result {
                    case .success(let route):
                        return route
                    case .failure(let error):
                        print("Error decoding route: \(error)")
                        return nil
                    }
                } ?? []
                completion(.success(routes))
            }
        }
    }
    
    // Add any other Firebase-related functions here, such as deleting routes
}
