//
//  shaders.metal
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

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float3 offset;
    float3 position;
    float4 color;
};

struct Uniforms {
    float time;
    float aspectRatio;
    float2 touch;
};

struct VertexOut {
    float4 position [[ position ]];
    float4 screenCoord;
    float4 color;
    float time;
    float aspectRatio;
    float2 touch;
};

vertex VertexOut vertexDay4(constant VertexIn *vertexIn [[buffer(0)]],
                            constant Uniforms &uniforms [[buffer(1)]],
                            uint vid [[ vertex_id ]]) {
    
    float t = uniforms.time;
    float3 offset = vertexIn[vid].offset;
    float3 position = vertexIn[vid].position;
    float4 screenCoord = float4(offset, 0.0) + float4(position, 1.0);
//    ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
//    回転用
//    float4x4 applyMatrix = float4x4(float4((1.1+0.2*cos(3*t))*cos(3*t),sin(3*t),0,0),
//                                    float4(-sin(3*t),(1.1+0.2*cos(3*t))*cos(3*t),0,0),
//                                    float4(0,0,1,0),
//                                    float4(0,0,0,1));
//    float4 screenCoord = float4(offset, 0.0) + applyMatrix * float4(position, 1.0);
    
    
    float4 color = vertexIn[vid].color;
    VertexOut out;
    
    
    float4 pos = float4(screenCoord.x, screenCoord.y*uniforms.aspectRatio, screenCoord.zw);
    
    out.position = pos;
    out.screenCoord = screenCoord;
    out.color = color;
    out.time = uniforms.time;
    out.aspectRatio = uniforms.aspectRatio;
    out.touch = uniforms.touch;
    return out;
}

fragment half4 fragmentDay4(VertexOut vertexIn [[stage_in]],
                            texture2d<float, access::sample> koaraTexture [[texture(0)]]) {
    float4 p = (vertexIn.screenCoord+1.0)/2.0;
    p.y = 1.0-p.y;
    constexpr sampler nearestSampler(coord::normalized, filter:: nearest);
    float4 koara = koaraTexture.sample(nearestSampler, p.xy);
    float2 touch = vertexIn.touch;
    float time = vertexIn.time;
    return half4(koara);
}
