// Apply quaternion rotation to a vector point
// A quaternion is basically a 4d number containing an angle and a 3d vector telling what angle it applies in. It's all just vector math!
// int quatTransform(float3 p, float4 q)
// {
//     
// }

int sdfSphere(float3 rayPos)
{
    return sqrt(pown(rayPos.x, 2) + pown(rayPos.y, 2) + pown(rayPos.z, 2)) - 4.0f;
}

int sdfScene(float3 rayPos)
{
    return sdfSphere(rayPos);
}

__kernel void render(__global int3 *pixels, __global int2 *resBuf)
{
    int id = get_global_id(0);
    int2 res = resBuf[0];

    // printf("render instance %d\n", id);
    // int2 res = (int2)(40, 20);
    int2 pix = (int2)(id % res.x, id / res.x);
    // One character in my terminal is 8px*17px
    // Floats so that rayDir is a float3 because C math is weird
    float scrWidth = res.x * 0.8f;
    float scrHeight = res.y * 1.7f;
    float focalLength = 1.0f;
    float thres = 0.1f;

    int3 color = (int3)(0, 0, 0);

    float3 cameraPos = (float3)(0.0f, -5.0f, 0.0f);
    float4 cameraDir;
    float3 rayPos = cameraPos;
    float3 rayDir = (float3)((pix.x - (res.x / 2)) * (scrWidth / res.x), focalLength, ((res.y / 2) - pix.y) * (scrHeight / res.y));
    rayDir /= sqrt(pown(rayDir.x, 2) + pown(rayDir.y, 2) + pown(rayDir.z, 2));

    if (id == 10)
    {
        printf("id %d: res=(%d, %d) rayDir=(%.3f, %.3f, %.3f)\n", id, res.x, res.y, rayDir.x, rayDir.y, rayDir.z);
    }

    float dst;
    int i;
    pixels[id] = (int3)(0, 0, 0);    // Default to black if the ray didn't collide with the scene
    for (i = 0; i < 100; i++)
    {
        dst = sdfScene(rayPos);
        if (id == 210)
        {
            printf("id %d: dst=%.3f rayPos=(%.3f, %.3f, %.3f)\n", id, dst, rayPos.x, rayPos.y, rayPos.z);
        }
        if (dst < thres)
        {
            pixels[id] = (int3)(255, 255, 255);
            // printf("id %d: collided\n", id);
            break;
        }
        rayPos += rayDir * dst;
    }

    // pixels[id] = (int3)((int)((float)(pix.x) / res.x * 256), (int)((float)(pix.y) / res.y * 256), (int)(id / (float)(res.x * res.y) * 256));

    // How to raymarch in 1 easy step and 3 easy loop steps:
    // 1. Calculate ray begin position and direction
    // 2. Loop:
        // 1. scene distance = sdfScene(ray position)
        // 2. if scene distance <= threshold: break
        // 3. ray position += ray direction * scene distance
}
