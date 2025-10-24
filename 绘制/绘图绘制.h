//
//  绘图绘制.h
//  THOR-HUD
//
//  Created by lqq on 2024/5/24.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#include <cstdint>
#include <string>
#import "UtfTool.hpp"

NS_ASSUME_NONNULL_BEGIN

@interface 绘图绘制 : UIViewController
+ (instancetype)sharedInstance;

@end


struct VVV2 {
    float X;
    float Y;

    VVV2() {
        this->X = 0;
        this->Y = 0;
    }

    VVV2(float x, float y) {
        this->X = x;
        this->Y = y;
    }

    static VVV2 Zero() {
        return VVV2(0.0f, 0.0f);
    }

    static float Distance(VVV2 a, VVV2 b) {
        VVV2 vector = VVV2(a.X - b.X, a.Y - b.Y);
        return sqrt((vector.X * vector.X) + (vector.Y * vector.Y));
    }

    bool operator!=(const VVV2 &src) const {
        return (src.X != X) || (src.Y != Y);
    }

    VVV2 &operator+=(const VVV2 &v) {
        X += v.X;
        Y += v.Y;
        return *this;
    }

    VVV2 &operator-=(const VVV2 &v) {
        X -= v.X;
        Y -= v.Y;
        return *this;
    }
};

typedef struct Circle2:public VVV2{
    float radius;
    
    Circle2():VVV2(),radius(0){}
    Circle2(float _x,float _y,float _radius):VVV2(_x,_y),radius(_radius){}

} Circle2;

struct VV3 {
    float X;
    float Y;
    float Z;

    VV3() {
        this->X = 0;
        this->Y = 0;
        this->Z = 0;
    }

    VV3(float x, float y, float z) {
        this->X = x;
        this->Y = y;
        this->Z = z;
    }

    VV3 operator+(const VV3 &v) const {
        return VV3(X + v.X, Y + v.Y, Z + v.Z);
    }

    VV3 operator-(const VV3 &v) const {
        return VV3(X - v.X, Y - v.Y, Z - v.Z);
    }

    bool operator==(const VV3 &v) {
        return X == v.X && Y == v.Y && Z == v.Z;
    }

    bool operator!=(const VV3 &v) {
        return !(X == v.X && Y == v.Y && Z == v.Z);
    }

    static VV3 Zero() {
        return VV3(0.0f, 0.0f, 0.0f);
    }

    static float Dot(VV3 lhs, VV3 rhs) {
        return (((lhs.X * rhs.X) + (lhs.Y * rhs.Y)) + (lhs.Z * rhs.Z));
    }

    static float Distance(VV3 a, VV3 b) {
        VV3 vector = VV3(a.X - b.X, a.Y - b.Y, a.Z - b.Z);
        return sqrt(((vector.X * vector.X) + (vector.Y * vector.Y)) + (vector.Z * vector.Z));
    }
};

struct FRotator {
    float Pitch;
    float Yaw;
    float Roll;
    inline FRotator()
        : Pitch(0.0f), Yaw(0.0f), Roll(0.0f)
    { }

    inline FRotator(float pitch, float yaw, float roll)
        : Pitch(pitch), Yaw(yaw), Roll(roll)
    { }
    
    inline FRotator operator+ (const FRotator &A) {
        return FRotator(this->Pitch + A.Pitch, this->Yaw + A.Yaw, this->Roll + A.Roll);
    }
    
    inline FRotator operator- (const FRotator &A) {
        return FRotator(this->Pitch - A.Pitch, this->Yaw - A.Yaw, this->Roll - A.Roll);
    }
    
    inline FRotator operator* (const FRotator &A) {
        return FRotator(this->Pitch * A.Pitch, this->Yaw * A.Yaw, this->Roll * A.Roll);
    }

    inline FRotator operator* (const float A) {
        return FRotator(this->Pitch * A, this->Yaw * A, this->Roll * A);
    }
    
    inline FRotator operator/ (const FRotator &A) {
        return FRotator(this->Pitch / A.Pitch, this->Yaw / A.Yaw, this->Roll / A.Roll);
    }

    inline FRotator operator/ (const float A) {
        return FRotator(this->Pitch / A, this->Yaw / A, this->Roll / A);
    }
    
    inline float Size() {
        return sqrt((this->Pitch * this->Pitch) + (this->Yaw * this->Yaw) + (this->Roll * this->Roll));
    }
    
};


struct 矩阵 {
    float Matrix[4][4];

    float *operator[](int index) {
        return Matrix[index];
    }
};


struct 最小视图信息 {
    VV3 Location;
    FRotator Rotation;
    float FOV;
};


static UIColor* HZColos(BOOL isAI) {
    if (isAI) {
        return [UIColor whiteColor];  // AI: 无论是否可见都为白色
    } else {
        return [UIColor yellowColor];  // 玩家：无论是否可见都为黄色
    }
}






NS_ASSUME_NONNULL_END

