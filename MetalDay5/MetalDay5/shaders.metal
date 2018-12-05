//
//  shaders.metal
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

vertex VertexOut vertexDay5(constant VertexIn *vertexIn [[buffer(0)]],
                            constant Uniforms &uniforms [[buffer(1)]],
                            uint vid [[ vertex_id ]]) {
    
    float t = uniforms.time;
    float3 offset = vertexIn[vid].offset;
    float3 position = vertexIn[vid].position;
    float4 screenCoord = float4(offset, 0.0) + float4(position, 1.0);
    
    float4 color = vertexIn[vid].color;
    VertexOut out;
    float4 pos = float4(screenCoord.x, screenCoord.y*uniforms.aspectRatio, screenCoord.zw);
    
    out.position = pos;
    out.screenCoord = pos;
    out.color = color;
    out.time = uniforms.time;
    out.aspectRatio = uniforms.aspectRatio;
    out.touch = uniforms.touch;
    return out;
}

fragment half4 fragmentDay5(VertexOut vertexIn [[stage_in]],
                            texture2d<float, access::sample> koaraTexture [[texture(0)]]) {
    // 座標変換
    float4 p = (vertexIn.screenCoord+1.0)/2.0;
    p.y = 1.0-p.y;
    // uniforms
    float2 touch = vertexIn.touch;
    float time = vertexIn.time;
    // サンプルとディストーションの用意
    constexpr sampler nearestSampler(coord::normalized, filter:: nearest);
    float2 d = vertexIn.screenCoord.xy*0.03;
    float2 distortion_x = float2(p.x+d.x, p.y);
    float2 distortion_y = float2(p.x, p.y+d.y);
    float4 koara = koaraTexture.sample(nearestSampler, p.xy);
    // 描画
    float4 Koara_distortion_x = koaraTexture.sample(nearestSampler, distortion_x);
    float4 Koara_distortion_y = koaraTexture.sample(nearestSampler, distortion_y);
    return half4(Koara_distortion_x.x ,Koara_distortion_y.y, koara.z, 1.0);
}
