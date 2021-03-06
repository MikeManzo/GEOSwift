//
//  Topology.swift
//
//  Created by Andrea Cremaschi on 22/05/15.
//  Copyright (c) 2015 andreacremaschi. All rights reserved.
//

import Foundation

/// Topological operations
public extension Geometry {
    
    /// - returns: A Polygon that represents all points whose distance from this geometry is less than or equal to the given width.
    func buffer(width: Double) -> Geometry? {
        guard let bufferGEOM = GEOSBuffer_r(GEOS_HANDLE, self.geometry, width, 0) else { return nil }
        return Geometry.create(bufferGEOM, destroyOnDeinit: true)
    }
    
    /// - returns: The smallest Polygon that contains all the points in the geometry.
    func convexHull() -> Polygon? {
        guard let convexHullGEOM = GEOSConvexHull_r(GEOS_HANDLE, self.geometry),
            let convexHull = Geometry.create(convexHullGEOM, destroyOnDeinit: true) as? Polygon else { return nil }
        return convexHull
    }

    /// - returns: a Geometry representing the points shared by this geometry and other.
    func intersection(_ geometry: Geometry) -> Geometry?  {
        guard let intersectionGEOM = GEOSIntersection_r(GEOS_HANDLE, self.geometry, geometry.geometry),
            let intersection = Geometry.create(intersectionGEOM, destroyOnDeinit: true) else { return nil }
        return intersection
    }
    
    /// - returns: A Geometry representing all the points in this geometry and the other.
    func union(_ geometry: Geometry) -> Geometry?  {
        guard let unionGEOM = GEOSUnion_r(GEOS_HANDLE, self.geometry, geometry.geometry),
            let union = Geometry.create(unionGEOM, destroyOnDeinit: true) else { return nil }
        return union
    }
    
    /// - returns: A Geometry representing all the points in this geometry and the other.
    func unaryUnion() -> Geometry?  {
        guard let unionGEOM = GEOSUnaryUnion_r(GEOS_HANDLE, self.geometry),
        let union = Geometry.create(unionGEOM, destroyOnDeinit: true) else { return nil }
        
        return union
    }
    
    /// - returns: A Geometry representing the points making up this geometry that do not make up other.
    func difference(_ geometry: Geometry) -> Geometry?  {
        guard let differenceGEOM = GEOSDifference_r(GEOS_HANDLE, self.geometry, geometry.geometry),
        let difference = Geometry.create(differenceGEOM, destroyOnDeinit: true) else { return nil }
        return difference
    }
    
    /// - returns: The boundary as a newly allocated Geometry object.
    func boundary() -> Geometry?  {
        guard let boundaryGEOM = GEOSBoundary_r(GEOS_HANDLE, self.geometry),
        let boundary = Geometry.create(boundaryGEOM, destroyOnDeinit: true) else { return nil }
        return boundary
    }
    
    /// - returns: A Waypoint representing the geometric center of the geometry. The point is not guaranteed to be on the interior of the geometry.
    func centroid() -> Waypoint? {
        guard let centroidGEOM = GEOSGetCentroid_r(GEOS_HANDLE, self.geometry),
        let centroid = Geometry.create(centroidGEOM, destroyOnDeinit: true) as? Waypoint else { return nil }
        return centroid
    }
    
    /// - returns: A Polygon that represents the bounding envelope of this geometry.
    func envelope() -> Geometry? {
        guard let envelopeGEOM = GEOSEnvelope_r(GEOS_HANDLE, self.geometry) else {
            return nil
        }
        return Geometry.create(envelopeGEOM, destroyOnDeinit: true) 
    }
    
    /// - returns: A POINT guaranteed to lie on the surface.
    func pointOnSurface() -> Waypoint? {
        guard let pointOnSurfaceGEOM = GEOSPointOnSurface_r(GEOS_HANDLE, self.geometry),
        let pointOnSurface = Geometry.create(pointOnSurfaceGEOM, destroyOnDeinit: true) as? Waypoint else { return nil }
        
        return pointOnSurface
    }
    
    /// - returns: The nearest point of this geometry with respect to `geometry`.
    func nearestPoint(_ geometry: Geometry) -> Coordinate {
        return nearestPoints(geometry)[0]
    }
    
    /// - returns: The nearest points in the geometries, ownership to caller.
    func nearestPoints(_ geometry: Geometry) -> [Coordinate] {
        let nearestPointsCoordinateList = GEOSNearestPoints_r(GEOS_HANDLE, self.geometry, geometry.geometry)
        var x0 : Double = 0
        var y0 : Double = 0
        GEOSCoordSeq_getX_r(GEOS_HANDLE, nearestPointsCoordinateList, 0, &x0)
        GEOSCoordSeq_getY_r(GEOS_HANDLE, nearestPointsCoordinateList, 0, &y0)
        
        var x1 : Double = 0
        var y1 : Double = 0
        GEOSCoordSeq_getX_r(GEOS_HANDLE, nearestPointsCoordinateList, 1, &x1)
        GEOSCoordSeq_getY_r(GEOS_HANDLE, nearestPointsCoordinateList, 1, &y1)
        
        return [Coordinate(x: x0, y: y0), Coordinate(x: x1, y: y1)]
    }
    
    /// - returns: The DE-9IM intersection matrix (a string) representing the topological relationship between this geometry and the other.
    func relationship(_ geometry: Geometry) -> String {
        guard let CString = GEOSRelate_r(GEOS_HANDLE, self.geometry, geometry.geometry) else { return "" }
        return String(cString: CString)
    }
}
