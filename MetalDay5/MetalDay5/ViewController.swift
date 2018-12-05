//
//  ViewController.swift
//  MetalDay5
//
//  Created by MikiTakahashi on 2018/12/05.
//  Copyright © 2018 MikiTakahashi. All rights reserved.
//

/*
 The MIT License (MIT)
 Copyright (c) 2018 MikiTakahashi
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit
import Metal
import MetalKit

class ViewController: UIViewController {
    private var renderer: Renderer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let mtlDevice = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported on this device")
            return
        }
        let (w,h) = (view.frame.width,view.frame.height)
        let mtkViewFrame = CGRect(x: 0, y: h/2 - 2*w/3,width: w, height: 4*w/3)
        let mtkView = MTKView(frame: mtkViewFrame, device: mtlDevice)
        mtkView.device = mtlDevice
        mtkView.framebufferOnly = true
        mtkView.preferredFramesPerSecond = 60
        mtkView.colorPixelFormat = .bgra8Unorm
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        renderer = Renderer(metalKitView: mtkView)
        
        view.insertSubview(mtkView, at: 0)
        let aspect = Float(mtkView.frame.height/mtkView.frame.width)
        var vertices = [float3(-1,-aspect,0), float3(1,-aspect,0), float3(-1,aspect,0), float3(1,aspect,0)]
            .map({p -> Vertex in Vertex(offset: float3(0), position: p,color: Color(0.0,0.0,0.0,1.0))})
        renderer.setVertices([0,1,2,2,1,3].map({i -> Vertex in vertices[i]}))
        renderer.start()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
}
