float4x4 g_matWorldViewProj;
float4 g_lightNormal = { 0.3f, 1.0f, 0.5f, 0.0f };
float3 g_ambient = { 0.3f, 0.3f, 0.3f };

bool g_bUseTexture = true;

float g_brightMin = 0.f;
float g_brightMax = 1.f;
bool g_toneMapping = true;

texture texture1;
sampler textureSampler = sampler_state {
    Texture = (texture1);
    MipFilter = NONE;
    MinFilter = POINT;
    MagFilter = POINT;
};

void VertexShader1(in  float4 inPosition  : POSITION,
                   in  float2 inTexCood   : TEXCOORD0,

                   out float4 outPosition : POSITION,
                   out float2 outTexCood  : TEXCOORD0)
{
    outPosition = inPosition;
    outTexCood = inTexCood;
}

void PixelShader1(in float4 inPosition    : POSITION,
                  in float2 inTexCood     : TEXCOORD0,

                  out float4 outColor     : COLOR)
{
    float4 workColor = (float4)0;
    workColor = tex2D(textureSampler, inTexCood);

    if (g_toneMapping)
    {
        // x / (1 + x) : Reinhard(ラインハルト)のトーンマッピング
        // ラインハルトのトーンマッピングだと明るいところにしか圧縮がかからない。
        // x / 最大輝度、とやると暗いところがさらに暗くなる圧縮がかかる
        // 二つの圧縮を合成して表示する
        float brightness = workColor.r * 0.2 + workColor.g * 0.7 + workColor.b * 0.1;
        
        float4 workColor1 = workColor / (1.0 + workColor);
        float4 workColor2 = workColor / g_brightMax;

        // brightness  0 ~ 1000
        // brightnessN 0 ~ 0.999
        float brightnessN = 1.0 - (1.0 / (1.0 + brightness));
        workColor = (workColor1 * brightnessN) + (workColor2 * (1.0 - brightnessN));
    }

    outColor = saturate(workColor);
}

technique Technique1
{
    pass Pass1
    {
        CullMode = NONE;

        VertexShader = compile vs_3_0 VertexShader1();
        PixelShader = compile ps_3_0 PixelShader1();
   }
}
