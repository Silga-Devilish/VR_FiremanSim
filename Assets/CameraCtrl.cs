using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraCtrl : MonoBehaviour
{
    // 公开的角速度参数，可以用来调整旋转速度
    public float rotationSpeed = 2.0f;

    private float xRotation = 0.0f;
    private float yRotation = 0.0f;

    void Update()
    {
        // 获取输入
        float horizontalInput = Input.GetAxis("Horizontal"); // A(-1) D(1)
        float verticalInput = Input.GetAxis("Vertical");     // W(1) S(-1)

        // 计算旋转角度增量
        float rotateHorizontal = horizontalInput * rotationSpeed;
        float rotateVertical = verticalInput * rotationSpeed;

        // 更新旋转角度
        yRotation += rotateHorizontal;
        xRotation -= rotateVertical; // 注意这里的减号，因为上下翻转方向是相反的

        // 限制xRotation在一定的范围内，避免翻转过度
        xRotation = Mathf.Clamp(xRotation, -90.0f, 90.0f);

        // 应用新的旋转到摄像机
        transform.rotation = Quaternion.Euler(xRotation, yRotation, 0);
    }
}