//
//  Polygons.swift
//  MetalDay4
//
//  Created by MikiTakahashi on 2018/12/02.
//  Copyright © 2018 MikiTakahashi. All rights reserved.
//

/*
 The MIT License (MIT)
 Copyright (c) 2018 MikiTakahashi
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import simd
import Foundation

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
