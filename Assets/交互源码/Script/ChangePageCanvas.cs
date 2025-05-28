using System.Collections;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.UI;

public class ChangePageCanvas : MonoBehaviour
{
    public Camera mainCamera; // 主摄像机
    public Canvas canvasA; // 要关闭的画布
    public Canvas canvasB; // 要启用的画布

    public Canvas canvasC; // 要关闭的画布
    public Canvas canvasD; // 要启用的画布
    public Button targetButton; // 目标按钮
    public float angleThreshold = -30f; // 镜头转动超过此角度则切换页面
    public Color color1 = Color.white; // 第一个颜色
    public Color color2 = Color.clear; // 第二个颜色
    public float debounceTime = 0.5f; // 触发后等待的时间

    private static float lastTriggerTime = -Mathf.Infinity; // 共享的最后触发时间
    private Image buttonImage;

    private void Start()
    {
        if (targetButton != null)
        {
            buttonImage = targetButton.GetComponent<Image>();
            if (buttonImage == null)
            {
                Debug.LogError("Target button does not have an Image component.");
            }
        }
        else
        {
            Debug.LogError("Target button is not assigned.");
        }

        // 确保初始状态下canvasB是禁用的
        canvasB.gameObject.SetActive(false);
    }

    private void Update()
    {
        // 获取当前时间
        float currentTime = Time.time;

        // 检查是否已经过了足够的等待时间
        if (currentTime - lastTriggerTime > debounceTime)
        {
            // 获取摄像机的旋转角度（这里假设是围绕Y轴的）
            float cameraAngle = mainCamera.transform.eulerAngles.y;

            // 如果镜头向左转超过了阈值
            if (cameraAngle > angleThreshold && cameraAngle < angleThreshold + 5)
            {
                // 切换画布并设置最后触发时间为当前时间
                SwitchCanvas();
                lastTriggerTime = currentTime;
            }
            else
            {
                // 否则更新按钮颜色
                UpdateButtonColor(cameraAngle);
            }
        }
    }

    private void SwitchCanvas()
    {
        canvasC.gameObject.SetActive(false);
        canvasD.gameObject.SetActive(true);
        // 关闭canvasA，启用canvasB
        canvasA.gameObject.SetActive(false);
        canvasB.gameObject.SetActive(true);
    }

    private void UpdateButtonColor(float cameraAngle)
    {
        if (buttonImage != null)
        {
            // 归一化cameraAngle使其在-180到180之间
            float normalizedAngle = ((cameraAngle + 180) % 360) - 180;
            
            // 设定阈值为-45度到0度（相当于原始坐标系中的315到360度）
            float angleThresholdMin = -45;
            float angleThresholdMax = 0;

            // 初始化颜色为color1
            Color newColor = color1;

            // 检查是否在指定的角度范围内
            if (normalizedAngle >= angleThresholdMin && normalizedAngle <= angleThresholdMax)
            {
                // 计算颜色混合因子t，确保当角度为angleThresholdMin时t=0, 角度为angleThresholdMax时t=1
                float t = Mathf.InverseLerp(angleThresholdMin, angleThresholdMax, normalizedAngle);
                // 根据t在线性插值两个颜色
                newColor = Color.Lerp(color1, color2, t);
            }
            else
            {
                newColor = color2;
            }

            // 应用新的颜色到按钮的Image组件
            buttonImage.color = newColor;
        }
    }
}