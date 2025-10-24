//
//  function.h
//  pcdr
//
//  Created by hzx on 2023/2/3.
//  Copyright © 2023 tencent. All rights reserved.
//

#ifndef function_h
#define function_h

#import "JHCJVectorHeader.h"

#pragma mark string--------------------------------------------------------------------------------
bool isContain(std::string str, const char* check) {
    size_t found = str.find(check);
    return (found != std::string::npos);
}
#pragma mark aim--------------------------------------------------------------------------------
float getAngleDifference(float angle1, float angle2) {
    float diff = fmod(angle2 - angle1 + 180, 360) - 180;
    return diff < -180 ? diff + 360 : diff;
}

float change(float num) {
    if (num < 0) {
        return abs(num);
    } else if (num > 0) {
        return num - num * 2;
    }
    return num;
}

FRotator CalcAngle(Vector3 t){
    FRotator angles;
        float deltaVecL = sqrt((t.X * t.X) + (t.Y * t.Y));
    angles.Pitch = (float)(atan2(t.Z, deltaVecL) * 57.29577951308f);
    angles.Yaw = (float)(atan2(t.Y, t.X) * 57.29577951308f);
           return angles;
}
#pragma mark 转换--------------------------------------------------------------------------------
Vector3 MatrixToVector(FMatrix matrix) {
    return Vector3(matrix[3][0], matrix[3][1], matrix[3][2]);
}//骨骼矩阵

FMatrix MatrixMulti(FMatrix m1, FMatrix m2) {
    FMatrix matrix = FMatrix();
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            for (int k = 0; k < 4; k++) {
                matrix[i][j] += m1[i][k] * m2[k][j];
            }
        }
    }
    return matrix;
}//骨骼矩阵

FMatrix TransformToMatrix(FTransform transform) {
    FMatrix matrix;
    
    matrix[3][0] = transform.Translation.X;
    matrix[3][1] = transform.Translation.Y;
    matrix[3][2] = transform.Translation.Z;
    
    float x2 = transform.Rotation.x + transform.Rotation.x;
    float y2 = transform.Rotation.y + transform.Rotation.y;
    float z2 = transform.Rotation.z + transform.Rotation.z;
    
    float xx2 = transform.Rotation.x * x2;
    float yy2 = transform.Rotation.y * y2;
    float zz2 = transform.Rotation.z * z2;
    
    matrix[0][0] = (1.0f - (yy2 + zz2)) * transform.Scale3D.X;
    matrix[1][1] = (1.0f - (xx2 + zz2)) * transform.Scale3D.Y;
    matrix[2][2] = (1.0f - (xx2 + yy2)) * transform.Scale3D.Z;
    
    float yz2 = transform.Rotation.y * z2;
    float wx2 = transform.Rotation.w * x2;
    matrix[2][1] = (yz2 - wx2) * transform.Scale3D.Z;
    matrix[1][2] = (yz2 + wx2) * transform.Scale3D.Y;
    
    float xy2 = transform.Rotation.x * y2;
    float wz2 = transform.Rotation.w * z2;
    matrix[1][0] = (xy2 - wz2) * transform.Scale3D.Y;
    matrix[0][1] = (xy2 + wz2) * transform.Scale3D.X;
    
    float xz2 = transform.Rotation.x * z2;
    float wy2 = transform.Rotation.w * y2;
    matrix[2][0] = (xz2 + wy2) * transform.Scale3D.Z;
    matrix[0][2] = (xz2 - wy2) * transform.Scale3D.X;
    
    matrix[0][3] = 0;
    matrix[1][3] = 0;
    matrix[2][3] = 0;
    matrix[3][3] = 1;
    
    return matrix;
}//骨骼矩阵

FMatrix RotatorToMatrix(FRotator rotation) {
    float radPitch = rotation.Pitch * ((float) M_PI / 180.0f);
    float radYaw = rotation.Yaw * ((float) M_PI / 180.0f);
    float radRoll = rotation.Roll * ((float) M_PI / 180.0f);
    
    float SP = sinf(radPitch);
    float CP = cosf(radPitch);
    float SY = sinf(radYaw);
    float CY = cosf(radYaw);
    float SR = sinf(radRoll);
    float CR = cosf(radRoll);
    
    FMatrix matrix;
    
    matrix[0][0] = (CP * CY);
    matrix[0][1] = (CP * SY);
    matrix[0][2] = (SP);
    matrix[0][3] = 0;
    
    matrix[1][0] = (SR * SP * CY - CR * SY);
    matrix[1][1] = (SR * SP * SY + CR * CY);
    matrix[1][2] = (-SR * CP);
    matrix[1][3] = 0;
    
    matrix[2][0] = (-(CR * SP * CY + SR * SY));
    matrix[2][1] = (CY * SR - CR * SP * SY);
    matrix[2][2] = (CR * CP);
    matrix[2][3] = 0;
    
    matrix[3][0] = 0;
    matrix[3][1] = 0;
    matrix[3][2] = 0;
    matrix[3][3] = 1;
    
    return matrix;
}

Vector2 WorldToScreen(Vector3 worldLocation, MinimalViewInfo camViewInfo, float width, float height) {
    FMatrix tempMatrix = RotatorToMatrix(camViewInfo.Rotation);
    
    Vector3 vAxisX(tempMatrix[0][0], tempMatrix[0][1], tempMatrix[0][2]);
    Vector3 vAxisY(tempMatrix[1][0], tempMatrix[1][1], tempMatrix[1][2]);
    Vector3 vAxisZ(tempMatrix[2][0], tempMatrix[2][1], tempMatrix[2][2]);
    
    Vector3 vDelta = worldLocation - camViewInfo.Location;
    
    Vector3 vTransformed(Vector3::Dot(vDelta, vAxisY), Vector3::Dot(vDelta, vAxisZ), Vector3::Dot(vDelta, vAxisX));
    
    if (vTransformed.Z < 1.0f) {
        vTransformed.Z = 1.0f;
    }
    
    float fov = camViewInfo.FOV;
    float screenCenterX = (width / 2.0f);
    float screenCenterY = (height / 2.0f);
    
    return Vector2(
                   (screenCenterX + vTransformed.X * (screenCenterX / tanf(fov * ((float) M_PI / 360.0f))) / vTransformed.Z),
                   (screenCenterY - vTransformed.Y * (screenCenterX / tanf(fov * ((float) M_PI / 360.0f))) / vTransformed.Z)
                   );
}
Vector3 getBoneWorldPos(long boneTransAddr,FMatrix c2wMatrix)
{
    FTransform boneTrans = *(FTransform*)(boneTransAddr);
    FMatrix boneMatrix = TransformToMatrix(boneTrans);
    return MatrixToVector(MatrixMulti(boneMatrix, c2wMatrix));
}
#pragma mark 判断--------------------------------------------------------------------------------
int BoneVisible(BoneVisibleData data)
{
    if(data.leftElbow)return 13;
    if(data.rightElbow)return 34;
    if(data.leftHand)return 14;
    if(data.rightHand)return 35;
    if(data.leftShoulder)return 12;
    if(data.rightShoulder)return 33;
    if(data.head)return 6;
    if(data.chest)return 4;
    if(data.leftFoot)return 55;
    if(data.rightFoot)return 59;
    if(data.leftKnee)return 54;
    if(data.rightKnee)return 58;
    if(data.leftThigh)return 53;
    if(data.rightThigh)return 57;
    if(data.pelvis)return 1;
    return 0;
}//锁定顺序
#endif /* function_h */
