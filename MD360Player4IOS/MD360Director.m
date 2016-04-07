//
//  MD360Director.m
//  MD360Player4IOS
//
//  Created by ashqal on 16/4/7.
//  Copyright © 2016年 ashqal. All rights reserved.
//

#import "MD360Director.h"
#import <GLKit/GLKit.h>

@interface MD360Director(){
    GLKMatrix4 mModelMatrix;// = new float[16];
    GLKMatrix4 mViewMatrix;// = new float[16];
    GLKMatrix4 mProjectionMatrix;// = new float[16];
    
    GLKMatrix4 mMVMatrix;// = new float[16];
    GLKMatrix4 mMVPMatrix;// = new float[16];
    
    float mEyeZ;// = 0f;
    float mEyeX;// = 0f;
    float mAngle;// = 0f;
    float mRatio;// = 0f;
    float mNear;// = 0f;
    float mLookX;// = 0f;
    
    GLKMatrix4 mCurrentRotation;// = new float[16];
    GLKMatrix4 mAccumulatedRotation;// = new float[16];
    GLKMatrix4 mTemporaryMatrix;// = new float[16];
    GLKMatrix4 mSensorMatrix;// = new float[16];
    
    float mPreviousX;
    float mPreviousY;
    
    float mDeltaX;
    float mDeltaY;
}
@end

@implementation MD360Director

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void) setup{
    mEyeZ = 0;
    mAngle = 0;
    mRatio = 1.5f;
    mNear = 0.7f;
    mEyeX = 0;
    mLookX = 0;
    mModelMatrix = mViewMatrix = mProjectionMatrix = mMVMatrix = mMVPMatrix = GLKMatrix4Identity;
    mCurrentRotation = mAccumulatedRotation = mTemporaryMatrix = mSensorMatrix = GLKMatrix4Identity;
    
    [self initCamera];
    [self initModel];
}

- (void)initModel{
    mAccumulatedRotation = mSensorMatrix = GLKMatrix4Identity;
    // Model Matrix
    [self updateModelRotate:mAngle];
}

- (void)initCamera{
    [self updateViewMatrix];
}

- (void) shot:(MD360Program*) program{
    
    //Matrix.setIdentityM(mModelMatrix, 0);
    mModelMatrix = GLKMatrix4Identity;
    
    //Matrix.setIdentityM(mCurrentRotation, 0);
    mCurrentRotation = GLKMatrix4Identity;

    //Matrix.rotateM(mCurrentRotation, 0, -mDeltaY, 1.0f, 0.0f, 0.0f);
    mCurrentRotation = GLKMatrix4Rotate(mCurrentRotation, -mDeltaY, 1.0f, 0.0f, 0.0f);
    
    //Matrix.rotateM(mCurrentRotation, 0, -mDeltaX + mAngle, 0.0f, 1.0f, 0.0f);
    mCurrentRotation = GLKMatrix4Rotate(mCurrentRotation, -mDeltaX + mAngle, 0.0f, 1.0f, 0.0f);
    
    //Matrix.multiplyMM(mCurrentRotation, 0, mSensorMatrix, 0, mCurrentRotation, 0);
    mCurrentRotation = GLKMatrix4Multiply(mCurrentRotation, mSensorMatrix);
    
    // set the accumulated rotation to the result.
    //System.arraycopy(mCurrentRotation, 0, mAccumulatedRotation, 0, 16);
    mAccumulatedRotation = mCurrentRotation;
    
    // Rotate the cube taking the overall rotation into account.
    //Matrix.multiplyMM(mTemporaryMatrix, 0, mModelMatrix, 0, mAccumulatedRotation, 0);
    mAccumulatedRotation = GLKMatrix4Multiply(mTemporaryMatrix, mModelMatrix);
    
    //System.arraycopy(mTemporaryMatrix, 0, mModelMatrix, 0, 16);
    mModelMatrix = mTemporaryMatrix;
    
    // This multiplies the view matrix by the model matrix, and stores the result in the MVP matrix
    // (which currently contains model * view).
    //Matrix.multiplyMM(mMVMatrix, 0, mViewMatrix, 0, mModelMatrix, 0);
    mModelMatrix = GLKMatrix4Multiply(mMVMatrix, mViewMatrix);
    
    // This multiplies the model view matrix by the projection matrix, and stores the result in the MVP matrix
    // (which now contains model * view * projection).
    // Matrix.multiplyMM(mMVPMatrix, 0, mProjectionMatrix, 0, mMVMatrix, 0);
    mMVMatrix = GLKMatrix4Multiply(mMVPMatrix, mProjectionMatrix);
    
    // Pass in the model view matrix
    //GLES20.glUniformMatrix4fv(program.getMVMatrixHandle(), 1, false, mMVMatrix, 0);
    glUniformMatrix4fv(program.mMVMatrixHandle, 1, false, mMVMatrix.m);
    
    // Pass in the combined matrix.
    //GLES20.glUniformMatrix4fv(program.getMVPMatrixHandle(), 1, false, mMVPMatrix, 0);
    glUniformMatrix4fv(program.mMVPMatrixHandle, 1, false, mMVPMatrix.m);
}

- (void) reset{
    mDeltaX = mDeltaY = mPreviousX = mPreviousY = 0;
    mSensorMatrix = GLKMatrix4Identity;
}

- (void) updateProjection:(int)width height:(int)height{
    mRatio = width * 1.0f / height;
    [self updateProjectionNear:mNear];
}

- (void) updateProjectionNear:(float)near{
    mNear = near;
    float left = -mRatio/2;
    float right = mRatio/2;
    float bottom = -0.5f;
    float top = 0.5f;
    float far = 500;
    mProjectionMatrix = GLKMatrix4MakeFrustum(left, right, bottom, top, mNear, far);
}

- (void) updateModelRotate:(float)angle{
    mAngle = angle;
}

- (void) updateViewMatrix{
    float eyeX = mEyeX;
    float eyeY = 0.0f;
    float eyeZ = mEyeZ;
    float lookX = mLookX;
    float lookY = 0.0f;
    float lookZ = -1.0f;
    float upX = 0.0f;
    float upY = 1.0f;
    float upZ = 0.0f;
    //mViewMatrix = GLKMatrix4Identity; // Matrix.setIdentityM(mViewMatrix, 0);
    
    mViewMatrix = GLKMatrix4MakeLookAt(eyeX, eyeY, eyeZ, lookX, lookY, lookZ, upX, upY, upZ);
    // Matrix.setLookAtM(mViewMatrix, 0, eyeX, eyeY, eyeZ, lookX, lookY, lookZ, upX, upY, upZ);
}


@end
