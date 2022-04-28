// Apply quaternion rotation to a vector point
// A quaternion is basically a 4d number containing an angle and a 3d vector telling what angle it applies in. It's all just vector math!
// int quatTransform(float3 p, float4 q)
// {
//     
// }

float degToRad(float deg)
{
    float pi = 3.1415926535897932384626f;
    return deg * pi / 180;
}

float radToDeg(float rad)
{
    float pi = 3.1415926535897932384626f;
    return rad * 180 / pi;
}

int sdfSphere(float3 rayPos)
{
    float3 spherePos = (float3)(0.0, 0.0f, 0.0f);
    float sphereRad = 0.1f;
    return length(rayPos - spherePos) - sphereRad;
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

    // Camera attributes
    float FoV = degToRad(70.0f);  // Angle between sides of the screen and the focal point (radians)
    float pixStretch = 1.0f;     // Ratio of the height of a pixel over the width
    float focalLen = 1.0f;
    float2 scrSize; scrSize.x = 2 * focalLen * tan(FoV / 2); scrSize.y = res.y * (scrSize.x / res.x) * pixStretch;
    float thres = 0.01f;

    // Ray calculations
    int2 pix = (int2)(id % res.x, id / res.x);
    float3 cameraPos = (float3)(0.0f, -5.0f, 0.0f);
    float4 cameraDir;
    float3 rayPos = cameraPos;
    float3 rayDir = (float3)((pix.x - (res.x / 2)) * (scrSize.x / res.x), focalLen, ((res.y / 2) - pix.y) * (scrSize.y / res.y));
    rayDir /= sqrt(pown(rayDir.x, 2) + pown(rayDir.y, 2) + pown(rayDir.z, 2));

    if (id == 0) printf("id %d: scrSize=(%.3f, %.3f)\n", id, scrSize.x, scrSize.y);

    // Marching
    float dstScene;
    float dstTotal = 0;
    float dstMax = 1000;
    int i;
    int maxSteps = 100;
    pixels[id] = (int3)(24, 161, 240);    // Default to black if the ray didn't collide with the scene
    for (i = 0; i < maxSteps; i++)
    {
        dstScene = sdfScene(rayPos);
        dstTotal += dstScene;

        if (dstTotal > dstMax) break;

        // if (id == 210) printf("id %d: dstScene=%.3f rayPos=(%.3f, %.3f, %.3f)\n", id, dstScene, rayPos.x, rayPos.y, rayPos.z);
        if (dstScene < thres)
        {
            pixels[id] = (int3)(255, 255, 255);
            // printf("id %d: collided\n", id);
            break;
        }
        rayPos += rayDir * dstScene;
    }

    // Test bit that draws a field of color
    // pixels[id] = (int3)((int)((float)(pix.x) / res.x * 256), (int)((float)(pix.y) / res.y * 256), (int)(id / (float)(res.x * res.y) * 256));

    // How to raymarch in 1 easy step and 3 easy loop steps:
    // 1. Calculate ray begin position and direction
    // 2. Loop:
        // 1. scene distance = sdfScene(ray position)
        // 2. if scene distance <= threshold: break
        // 3. ray position += ray direction * scene distance
}
