//
//  MKMap.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-11-04.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import MapKit

extension MKMapView {
    func polygon(for point: CGPoint) -> MKPolygon? {
        var intersectPoly: MKPolygon?

        let coord = convert(point, toCoordinateFrom: self)
        
        for overlay in overlays {
            if let overlay = overlay as? MKPolygon {
                let renderer = MKPolygonRenderer(polygon: overlay)
                if renderer.path.contains(renderer.point(for: MKMapPoint(coord))) {
                    intersectPoly = overlay
                    break
                }
            }
        }
        
        return intersectPoly
    }
    
    // https://stackoverflow.com/questions/11713788/how-to-detect-taps-on-mkpolylines-overlays-like-maps-app
    func polyline(for point: CGPoint) -> MKPolyline? {
        let coord = convert(point, toCoordinateFrom: self)
        let maxMeters: Double = meters(fromPixel: 22, at: point)
        var nearestDistance: Float = MAXFLOAT
        var nearestPoly: MKPolyline?

        for overlay in overlays {
            if let overlay = overlay as? MKPolyline {
                let distance = Float(distanceOf(pt: MKMapPoint(coord), toPoly: overlay))
                if
                    distance < nearestDistance,
                    Double(distance) <= maxMeters
                {
                    nearestDistance = distance
                    nearestPoly = overlay
                }
            }
        }
        
        return nearestPoly
    }
    
    private func distanceOf(pt: MKMapPoint, toPoly poly: MKPolyline) -> Double {
        var distance = Double(MAXFLOAT)
        
        for n in 0..<poly.pointCount - 1 {
            let ptA = poly.points()[n]
            let ptB = poly.points()[n + 1]
            let xDelta: Double = ptB.x - ptA.x
            let yDelta: Double = ptB.y - ptA.y
            if xDelta == 0.0 && yDelta == 0.0 {
                // Points must not be equal
                continue
            }
            let u: Double = ((pt.x - ptA.x) * xDelta + (pt.y - ptA.y) * yDelta) / (xDelta * xDelta + yDelta * yDelta)
            var ptClosest: MKMapPoint
            
            if u < 0.0 {
                ptClosest = ptA
            } else if u > 1.0 {
                ptClosest = ptB
            } else {
                ptClosest = MKMapPoint(x: ptA.x + u * xDelta, y: ptA.y + u * yDelta)
            }
            
            distance = min(distance, ptClosest.distance(to: pt))
        }
        
        return distance
    }
    
    private func meters(fromPixel px: Int, at pt: CGPoint) -> Double {
        let ptB = CGPoint(x: pt.x + CGFloat(px), y: pt.y)
        let coordA = convert(pt, toCoordinateFrom: self)
        let coordB = convert(ptB, toCoordinateFrom: self)
        
        return MKMapPoint(coordA).distance(to: MKMapPoint(coordB))
    }
}
