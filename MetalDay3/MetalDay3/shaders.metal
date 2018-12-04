//
//  shaders.metal
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
    float time;
    float aspectRatio;
    float2 touch;
};

vertex VertexOut vertexDay3(constant VertexIn *vertexIn [[buffer(0)]],
                            constant Uniforms &uniforms [[buffer(1)]],
                            uint vid [[ vertex_id ]]) {
    float3 offset = vertexIn[vid].offset;
    float3 position = vertexIn[vid].position;
    float4 screenCoord = float4(offset, 0.0) + float4(position, 1.0);
    float4 color = vertexIn[vid].color;
    VertexOut out;
    
    float4 pos = float4(screenCoord.x, screenCoord.y*uniforms.aspectRatio, screenCoord.zw);
    
    out.position = pos;
    out.screenCoord = screenCoord;
    out.time = uniforms.time;
    out.aspectRatio = uniforms.aspectRatio;
    out.touch = uniforms.touch;
    return out;
}

float circle(float2 p, float2 center) {
    return 1.0 - smoothstep(0.0, 1.0, length(center-p));
}


float re(float2 p, float2 center, float time) {
    float theta = atan2(p.x-center.x, p.y-center.y);
    float2 norm = float2(cos(10*theta + 3*time), sin(20*theta + 2*time));
    return smoothstep(0.0,1.0,length(norm));
}

float Lissajous(float2 p, float2 center, float time) {
    float theta = atan2(p.x-center.x, p.y-center.y);
    float2 norm = float2(3*cos(theta), 2*sin(theta));
    return smoothstep(0.0,1.0,length(norm));
}


float Mandelbrot(float2 p, float time) {
    int count=0;
    float2 x = p + float2(-0.5,0.0);
    float2 z = float2(cos(time), sin(0.7*time));
    
    for(int i=0; i<360; i++) {
        count++;
        if(length(z) > 2.0) {
            return float(count)/360.0;
        }
        z = float2(z.x*z.x - z.y*z.y, 2.0*z.x*z.y) + x;
    }
    return 1.0;
}

fragment half4 fragmentDay3(VertexOut vertexIn [[stage_in]]) {
    float4 p = vertexIn.screenCoord;
    float2 touch = vertexIn.touch;
    float time = vertexIn.time;
//    half3 c = half3(step(0.5, circle(p.xy, touch)));
    
//    記事内で紹介したお遊び
//    float a = 1.0 - re(p.xy, touch, time);
//    return half4(a,a,a,1.0);
    
//    Mandelbrot
    float3 c = float3(0.30, 0.59, 0.11)*Mandelbrot(p.xy, time);
    return half4(half3(c), 1.0);
//    return half4(c, 1.0);
}


