//
//  File.metal
//  MetalDay1
//
//  Created by MikiTakahashi on 2018/11/29.
//  Copyright © 2018 MikiTakahashi. All rights reserved.
//

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
