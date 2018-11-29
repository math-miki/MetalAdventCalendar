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
struct VertexOut {
    float4 pos [[ position ]];
    float4 color;
};
vertex VertexOut vertexDay1(constant VertexIn *vertexIn [[buffer(0)]],
                            uint vid [[ vertex_id ]]) {
    float3 pos = vertexIn[vid].pos;
    VertexOut out;
    
    out.pos = float4(pos,1.0);
    out.color = float4((pos.xy+float2(1.0))/2.0, 0.7, 1.0);
    
    return out;
}

fragment half4 fragmentDay1(VertexOut vertexIn [[stage_in]]) {
    return half4(255.0,1.0,1.0,1.0);
}
