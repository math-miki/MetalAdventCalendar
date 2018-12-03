//
//  ViewController.swift
//  MetalDay3
//
//  Created by MikiTakahashi on 2018/12/03.
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
import MetalKit

class ViewController: UIViewController {
    private var renderer: Renderer!
    private var aspect: Float!
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let mtlDevice = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported on this device")
            return
        }
        let mtkView = MTKView(frame: view.frame, device: mtlDevice)
        mtkView.device = mtlDevice
        mtkView.framebufferOnly = true
        mtkView.preferredFramesPerSecond = 60
        renderer = Renderer(metalKitView: mtkView)
        
        view = mtkView
        aspect = Float(view.frame.size.height / view.frame.size.width)
        let vertices = [Position(-1.0,-aspect,0),
                        Position(1.0,-aspect,0),
                        Position(-1.0,aspect,0),
                        Position(1.0,-aspect,0),
                        Position(-1.0,aspect,0),
                        Position(1.0,aspect,0)]
        renderer.setVertices(vertices.map({v -> Vertex in Vertex(offset: Position(0,0,0), position: v, color: Color(0,0,0,1))}))
        renderer.start()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(touches.first == nil) { return }
        let loc = touches.first!.location(in: view)
        let resolution = view.frame.size
        renderer.applyTouch(touch: float2(Float((loc.x/resolution.width)*2.0-1.0),-Float((loc.y/resolution.height)*2.0-1.0)*aspect))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(touches.first == nil) { return }
        let loc = touches.first!.location(in: view)
        let resolution = view.frame.size
        renderer.applyTouch(touch: float2(Float((loc.x/resolution.width)*2.0-1.0),-Float((loc.y/resolution.height)*2.0-1.0)*aspect))
    }
}

