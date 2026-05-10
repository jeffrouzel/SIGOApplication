//
//  MapResponse.swift
//  SIGOApplication
//
//  Created by training2 on 5/11/26.
//
import Foundation
import MapKit

struct RouteInfo {
    let destinationName: String
    let destinationAddress: String
    let straightLineMeters: Double
    let route: MKRoute?
}
