//
//  Polygons.swift
//  MetalDay2
//
//  Created by MikiTakahashi on 2018/12/02.
//  Copyright © 2018 MikiTakahashi. All rights reserved.
//

import simd
import Foundation

typealias Position = float3
typealias Color = float4

struct Vertex {
    var offset: float3
    var position: float3
    var color: float4
}

protocol MAModel {
    var vertices: [Vertex]! { get }
    var indices: [Int]! { get }
    var triangles: [Vertex]! { get }
}

struct RegularPolygon: MAModel {
    
    // Model Protocol
    var vertices: [Vertex]!
    var indices: [Int]!
    
    // RegularPolygonのデータ
    var r: Float!
    var n: Int!
    
    // Triangleデータ
    var triangles: [Vertex]! { return indices.map({i->Vertex in vertices[i]})}
    
    init(center: Position, r: Float, n: Int, Color c: Color) {
        self.r = r
        self.n = n
        vertices = [Vertex]()
        indices = [Int]()
        generatePolygon(center: center, r: r, n: n, color: c)
    }
    
    mutating private func generatePolygon(center: Position, r: Float, n: Int, color: Color) {
        vertices = []
        indices = []
        vertices.append(Vertex(offset: center, position: Position(0,0,0), color: color))
        for i in Array(0..<n).map({n -> Float in Float(n)}) {
            let theta = 2 * Float.pi * (i / Float(n))
            let x = r * cos(theta)
            let y = r * sin(theta)
            vertices.append(Vertex(offset: center, position: float3(x, y ,0), color: color) )
        }
        Array(0..<n).map({i->[Int] in [0, 1+i, 1+(i+1)%n]}).forEach({indices += $0})
    }
}
