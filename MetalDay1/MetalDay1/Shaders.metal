//
//  File.metal
//  MetalDay1
//
//  Created by MikiTakahashi on 2018/11/29.
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
    float3 pos;
};

struct Uniforms {
    float time;
    float aspectRatio;
    float2 touch;
};
struct VertexOut {
    float4 pos [[ position ]];
    float3 color;
    float time;
};

vertex VertexOut vertexDay1(constant VertexIn *vertexIn [[buffer(0)]],
                            constant Uniforms &uniforms [[buffer(1)]],
                            uint vid [[ vertex_id ]]) {
    float3 pos = vertexIn[vid].pos;
    VertexOut out;
    
    out.pos = float4(pos,1.0);
    out.color = float3((pos.xy+float2(1.0))/2.0, 0.7);
    out.time = uniforms.time;
    
    return out;
}

fragment half4 fragmentDay1(VertexOut vertexIn [[stage_in]]) {
    float4 p = vertexIn.pos;
    float3 c = vertexIn.color;
    float t = vertexIn.time;
    return half4(c.x, c.y, (1.0+cos(3*t))/2.0,1.0);
}
