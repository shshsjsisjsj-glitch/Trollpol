//
//  JHCJVectorHeader.h
//  libShadowTrackerExtraDylib
//
//  Created by 仔仔 on 2024/1/20.
//

#ifndef JHCJVectorHeader_h
#define JHCJVectorHeader_h

#include <arm_neon.h>
struct Vector2 {
    float X;
    float Y;

    Vector2() {
        this->X = 0;
        this->Y = 0;
    }

    Vector2(float x, float y) {
        this->X = x;
        this->Y = y;
    }
    
    static float Distance(Vector2 a, Vector2 b) {
        Vector2 vector = Vector2(a.X - b.X, a.Y - b.Y);
        return sqrt((vector.X * vector.X) + (vector.Y * vector.Y));
    }

    Vector2 &operator+=(const Vector2 &v) {
        X += v.X;
        Y += v.Y;
        return *this;
    }

    Vector2 &operator-=(const Vector2 &v) {
        X -= v.X;
        Y -= v.Y;
        return *this;
    }
};

static struct Vector3{
    float x;
    float y;
    float z;
}*LPVector3;

static struct Vector4{
    float x;
    float y;
    float z;
    float l;
    float sx;
    float sy;
}*LPVector4;


//Vector3
class CVector3
{
public:
    CVector3() : x(0.f), y(0.f), z(0.f)
    {
        
    }
    
    CVector3(float _x, float _y, float _z) : x(_x), y(_y), z(_z)
    {
        
    }
    ~CVector3()
    {
        
    }
    
    float x;
    float y;
    float z;
    
    CVector3 operator+(CVector3 v)
    {
        return CVector3(x + v.x, y + v.y, z + v.z);
    }
    
    CVector3 operator-(CVector3 v)
    {
        return CVector3(x - v.x, y - v.y, z - v.z);
    }
};


static struct LTMatrix{
    float a1;
    float a2;
    float a3;
    float a4;
    float b1;
    float b2;
    float b3;
    float b4;
    float c1;
    float c2;
    float c3;
    float c4;
    float d1;
    float d2;
    float d3;
    float d4;
}*LPMatrix;

struct FQuat
{
    float x;
    float y;
    float z;
    float w;
};
struct FRotator {
    float Pitch;
    float Yaw;
    float Roll;
};

struct MinimalViewInfo {
    Vector3 Location;
    Vector3 LocationLocalSpace;
    FRotator Rotation;
    float FOV;
};
typedef struct FVectorRect {
    float X;
    float Y;
    float W;
    float H;
} FVectorRect;
static Vector3 minusTheVector(Vector3 first, Vector3 second)
{
    static Vector3 ret;
    ret.x = first.x - second.x;
    ret.y = first.y - second.y;
    ret.z = first.z - second.z;
    return ret;
}

static float theDot(Vector3 v1, Vector3 v2)
{
    return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z;
}
typedef struct D3DXMATRIX {
    float _11, _12, _13, _14;
    float _21, _22, _23, _24;
    float _31, _32, _33, _34;
    float _41, _42, _43, _44;
} D3DXMATRIX;

static float getDistance(Vector3 a, Vector3 b)
{
    static Vector3 ret;
    ret.x = a.x - b.x;
    ret.y = a.y - b.y;
    ret.z = a.z - b.z;
    return sqrt(ret.x * ret.x + ret.y * ret.y + ret.z * ret.z);
}

static D3DXMATRIX toMATRIX(FRotator rot)
{
    static float RadPitch, RadYaw, RadRoll, SP, CP, SY, CY, SR, CR;
    D3DXMATRIX M;
    
    RadPitch = rot.Pitch * M_PI / 180;
    RadYaw = rot.Yaw * M_PI / 180;
    RadRoll = rot.Roll * M_PI / 180;
    
    SP = sin(RadPitch);
    CP = cos(RadPitch);
    SY = sin(RadYaw);
    CY = cos(RadYaw);
    SR = sin(RadRoll);
    CR = cos(RadRoll);
    
    M._11 = CP * CY;
    M._12 = CP * SY;
    M._13 = SP;
    M._14 = 0.f;
    
    M._21 = SR * SP * CY - CR * SY;
    M._22 = SR * SP * SY + CR * CY;
    M._23 = -SR * CP;
    M._24 = 0.f;
    
    M._31 = -(CR * SP * CY + SR * SY);
    M._32 = CY * SR - CR * SP * SY;
    M._33 = CR * CP;
    M._34 = 0.f;
    
    M._41 = 0.f;
    M._42 = 0.f;
    M._43 = 0.f;
    M._44 = 1.f;
    
    return M;
}

static void getTheAxes(FRotator rot, Vector3 *x, Vector3 *y, Vector3 *z){
    D3DXMATRIX M = toMATRIX(rot);
    
    x->x = M._11;
    x->y = M._12;
    x->z = M._13;
    
    y->x = M._21;
    y->y = M._22;
    y->z = M._23;
    
    z->x = M._31;
    z->y = M._32;
    z->z = M._33;
}

static Vector2 worldToScreen(Vector3 worldLocation, MinimalViewInfo camViewInfo, Vector2 canvas){
    static Vector2 Screenlocation;
    
    Vector3 vAxisX, vAxisY, vAxisZ;
    getTheAxes(camViewInfo.Rotation, &vAxisX, &vAxisY, &vAxisZ);
    
    Vector3 vDelta = minusTheVector(worldLocation, camViewInfo.Location);
    Vector3 vTransformed;
    
    vTransformed.x = theDot(vDelta, vAxisY);
    vTransformed.y = theDot(vDelta, vAxisZ);
    vTransformed.z = theDot(vDelta, vAxisX);
    
    if (vTransformed.z < 1.0f) {
        vTransformed.z = 1.0f;
    }
    
    float FOV = camViewInfo.FOV;
    float ScreenCenterX = canvas.X / 2;
    float ScreenCenterY = canvas.Y / 2;
    float BonesX=ScreenCenterX + vTransformed.x * (ScreenCenterX / tanf(FOV * (float)M_PI / 360.f)) / vTransformed.z;
    float BonesY=ScreenCenterY - vTransformed.y * (ScreenCenterX / tanf(FOV * (float)M_PI / 360.f)) / vTransformed.z;
    
    
    Screenlocation.X = BonesX;
    Screenlocation.Y = BonesY;
    
    return Screenlocation;
}

static FVectorRect worldToScreenForRect(Vector3 worldLocation, MinimalViewInfo camViewInfo, Vector2 canvas)
{
    FVectorRect rect;
    
    Vector3 Pos2 = worldLocation;
    Pos2.z += 90.f;
    
    
    Vector2 CalcPos = worldToScreen(worldLocation ,camViewInfo,canvas);
    
    Vector2 CalcPos2 = worldToScreen(Pos2 ,camViewInfo,canvas);
    
    rect.H = CalcPos.Y - CalcPos2.Y;
    rect.W = rect.H / 2.5;
    rect.X = CalcPos.X - rect.W;
    rect.Y = CalcPos2.Y;
    rect.W = rect.W * 2;
    rect.H = rect.H * 2;
    
    return rect;
}

struct FTransform
{
    FQuat rot;
    Vector3 translation;
    Vector3 scale;
   
    
};
static D3DXMATRIX toMatrixWithScale(FQuat rotation, Vector3 translation, Vector3 scale){
    static D3DXMATRIX ret;
    
    float x2, y2, z2, xx2, yy2, zz2, yz2, wx2, xy2, wz2, xz2, wy2 = 0.f;
    ret._41 = translation.x;
    ret._42 = translation.y;
    ret._43 = translation.z;
    
    x2 = rotation.x * 2;
    y2 = rotation.y * 2;
    z2 = rotation.z * 2;
    
    xx2 = rotation.x * x2;
    yy2 = rotation.y * y2;
    zz2 = rotation.z * z2;
    
    ret._11 = (1 - (yy2 + zz2)) * scale.x;
    ret._22 = (1 - (xx2 + zz2)) * scale.y;
    ret._33 = (1 - (xx2 + yy2)) * scale.z;
    
    yz2 = rotation.y * z2;
    wx2 = rotation.w * x2;
    ret._32 = (yz2 - wx2) * scale.z;
    ret._23 = (yz2 + wx2) * scale.y;
    
    xy2 = rotation.x * y2;
    wz2 = rotation.w * z2;
    ret._21 = (xy2 - wz2) * scale.y;
    ret._12 = (xy2 + wz2) * scale.x;
    
    xz2 = rotation.x * z2;
    wy2 = rotation.w * y2;
    ret._31 = (xz2 + wy2) * scale.z;
    ret._13 = (xz2 - wy2) * scale.x;
    
    ret._14 = 0.f;
    ret._24 = 0.f;
    ret._34 = 0.f;
    ret._44 = 1.f;
    
    return ret;
}

static D3DXMATRIX matrixMultiplication(D3DXMATRIX M1, D3DXMATRIX M2)
{
    static D3DXMATRIX ret;
    ret._11 = M1._11 * M2._11 + M1._12 * M2._21 + M1._13 * M2._31 + M1._14 * M2._41;
    ret._12 = M1._11 * M2._12 + M1._12 * M2._22 + M1._13 * M2._32 + M1._14 * M2._42;
    ret._13 = M1._11 * M2._13 + M1._12 * M2._23 + M1._13 * M2._33 + M1._14 * M2._43;
    ret._14 = M1._11 * M2._14 + M1._12 * M2._24 + M1._13 * M2._34 + M1._14 * M2._44;
    ret._21 = M1._21 * M2._11 + M1._22 * M2._21 + M1._23 * M2._31 + M1._24 * M2._41;
    ret._22 = M1._21 * M2._12 + M1._22 * M2._22 + M1._23 * M2._32 + M1._24 * M2._42;
    ret._23 = M1._21 * M2._13 + M1._22 * M2._23 + M1._23 * M2._33 + M1._24 * M2._43;
    ret._24 = M1._21 * M2._14 + M1._22 * M2._24 + M1._23 * M2._34 + M1._24 * M2._44;
    ret._31 = M1._31 * M2._11 + M1._32 * M2._21 + M1._33 * M2._31 + M1._34 * M2._41;
    ret._32 = M1._31 * M2._12 + M1._32 * M2._22 + M1._33 * M2._32 + M1._34 * M2._42;
    ret._33 = M1._31 * M2._13 + M1._32 * M2._23 + M1._33 * M2._33 + M1._34 * M2._43;
    ret._34 = M1._31 * M2._14 + M1._32 * M2._24 + M1._33 * M2._34 + M1._34 * M2._44;
    ret._41 = M1._41 * M2._11 + M1._42 * M2._21 + M1._43 * M2._31 + M1._44 * M2._41;
    ret._42 = M1._41 * M2._12 + M1._42 * M2._22 + M1._43 * M2._32 + M1._44 * M2._42;
    ret._43 = M1._41 * M2._13 + M1._42 * M2._23 + M1._43 * M2._33 + M1._44 * M2._43;
    ret._44 = M1._41 * M2._14 + M1._42 * M2._24 + M1._43 * M2._34 + M1._44 * M2._44;
    return ret;
}








#endif /* JHCJVectorHeader_h */
