//
//  Renderer.swift
//  MetalDay4
//
//  Created by MikiTakahashi on 2018/12/04.
//  Copyright © 2018 MikiTakahashi. All rights reserved.
//

/*
 The MIT License (MIT)
 Copyright (c) 2018 MikiTakahashi
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation
import Metal
import MetalKit


class Renderer:NSObject {
    // local datas
    private var vertices: [Vertex]!
    private var vertexBuffer: MTLBuffer!
    private var indices: [UInt16]!
    private var indexBuffer: MTLBuffer!
    // for MetalAPI
    private var mtlDevice: MTLDevice!
    private var mtkview: MTKView!
    
    private var commandQueue: MTLCommandQueue!
    private var pipelineState: MTLRenderPipelineState!
    
    private var uniforms: Uniforms!
    private var preferredFramesTime: Float!
    
    // Textures
    private var koaraTexture: MTLTexture!
    
    init(metalKitView mtkView: MTKView) {
        super.init()
        self.mtkview = mtkView
        
        guard let device = mtkView.device else {
            print("mtkview doesn't have mtlDevice")
            return
        }
        
        self.mtlDevice = device
        
        commandQueue = device.makeCommandQueue()
        vertices = [Vertex]()
        indices = [UInt16]()
        uniforms = Uniforms(time: Float(0.0), aspectRatio: Float(0.0), touch: float2())
        uniforms.aspectRatio = Float(mtkView.frame.size.width / mtkView.frame.size.height)
        preferredFramesTime = 1.0 / Float(mtkView.preferredFramesPerSecond)
    }
    
    private func buildPipeline() {
        let library = mtlDevice.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "vertexDay4")
        let fragmentFunction = library?.makeFunction(name: "fragmentDay4")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        do {
            try pipelineState = mtlDevice.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error {
            print("Failed to create pipeline state, error: ", error)
        }
    }
    
    private func buildBuffer() {
        vertexBuffer = mtlDevice.makeBuffer(bytes: vertices, length: vertices.count*MemoryLayout<Vertex>.stride, options: [])
    }
    
}

extension Renderer: MTKViewDelegate{
    
    public func draw(in view: MTKView) {
        uniforms.time += preferredFramesTime
        guard let drawable = view.currentDrawable,
            let renderPassDescriptor = view.currentRenderPassDescriptor else {
                print("cannot get drawable or renderPassDescriptor")
                return
        }
        let commandBuffer = commandQueue.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        commandEncoder?.setRenderPipelineState(pipelineState)
        commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder?.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 1)
        commandEncoder?.setFragmentTexture(koaraTexture, index: 0)
        commandEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
        commandEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
}

// for use Texture
extension Renderer {
    
    private func buildTexture() {
        koaraTexture = imageTexture(imageName: "koara.jpg", device: mtlDevice)
    }
    
    private func imageTexture(imageName: String, device: MTLDevice) -> MTLTexture? {
        guard let image = UIImage(named: imageName)?.cgImage else {
            return nil
        }
        let (w,h) = (image.width, image.height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let rawData = calloc(h*w*4, MemoryLayout<UInt8>.size)
        
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * w
        let bitsPerComponent = 8
        
        let options = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        
        let context = CGContext(data: rawData, width: w, height: h,
                                bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow,
                                space: colorSpace, bitmapInfo: options)
        
        context?.draw(image, in: CGRect(x: 0, y: 0, width: CGFloat(w), height: CGFloat(h)))
        
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: w, height: h, mipmapped: false)
        let texture = device.makeTexture(descriptor: textureDescriptor)
        
        let region = MTLRegionMake2D(0, 0, w, h)
        
        texture?.replace(region: region, mipmapLevel: 0, slice: 0, withBytes: rawData!, bytesPerRow: bytesPerRow, bytesPerImage: bytesPerRow*h)
        
        free(rawData)
        
        return texture
    }
}


extension Renderer {
    public func setVertices(_ vertices: [Vertex]) {
        self.vertices += vertices
    }
    public func setIndices(_ indices: [Int]) {
        self.indices += indices.map({ (n) -> UInt16 in
            return UInt16(n)
        })
    }
    public func start () {
        buildBuffer()
        buildPipeline()
        buildTexture()
        mtkview.delegate = self
    }

public func rebuildGame() {
    
}

    
    public func applyTouch(touch: float2) {
        uniforms.touch = touch
    }
}
