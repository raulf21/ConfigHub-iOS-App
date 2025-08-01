//
//  SatelliteCoverageMapView.swift
//  ConfigHub
//
//  Created by Raul Flores on 7/30/25.
//
import SwiftUI
import MapKit

// A simple struct for identifiable map annotations
struct SatelliteLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct SatelliteCoverageMapView: View {
    // State for the map's camera position
    @State private var position: MapCameraPosition = .automatic

    // Mock data for satellite locations
    let satelliteLocations: [SatelliteLocation] = [
        SatelliteLocation(coordinate: .init(latitude: 37.7749, longitude: -122.4194)), // SF
        SatelliteLocation(coordinate: .init(latitude: 34.0522, longitude: -118.2437)), // LA
        SatelliteLocation(coordinate: .init(latitude: 40.7128, longitude: -74.0060))    // NYC
    ]
    
    var body: some View {
        // Use Map for a realistic coverage view
        Map(position: $position) {
            ForEach(satelliteLocations) { location in
                Annotation("Satellite", coordinate: location.coordinate) {
                    Image(systemName: "antenna.radiowaves.left.and.right.circle.fill")
                        .font(.title)
                        .foregroundColor(.indigo)
                        .background(.white)
                        .clipShape(Circle())
                }
            }
        }
        .mapStyle(.imagery(elevation: .realistic)) // Use satellite imagery style
        .navigationTitle("Coverage Map")
    }
}
