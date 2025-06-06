using UnityEngine;
using TMPro;

public class WaterGunInteractable : MonoBehaviour
{
    [Header("水枪设置")]
    [Tooltip("水枪预制体")]
    public GameObject waterGunPrefab;

    [Tooltip("水枪生成位置偏移")]
    public Vector3 spawnOffset = new Vector3(0.5f, -0.3f, 1f);

    [Header("交互设置")]
    [Tooltip("交互提示显示的文本")]
    public string pickupText = "按E 获取水枪";

    [Tooltip("获得后的提示文本")]
    public string obtainedText = "已获得水枪，按鼠标左键使用";

    [Tooltip("交互检测距离")]
    public float interactionDistance = 3f;

    [Header("UI设置")]
    [Tooltip("拖入场景中的TextMeshPro提示UI对象")]
    public GameObject interactionPrompt;

    private bool isPlayerInRange = false;
    private bool hasObtainedGun = false;
    private Transform playerTransform;
    private Transform playerCamera;
    private TMP_Text promptText;
    private GameObject currentWaterGun;

    void Start()
    {
        playerTransform = GameObject.FindGameObjectWithTag("Player")?.transform;
        playerCamera = Camera.main?.transform;

        if (interactionPrompt != null)
        {
            promptText = interactionPrompt.GetComponentInChildren<TMP_Text>();
            interactionPrompt.SetActive(false);
        }
        else
        {
            Debug.LogError("未指定交互提示UI对象！");
        }
    }

    void Update()
    {
        if (playerTransform == null || playerCamera == null) return;

        float distance = Vector3.Distance(transform.position, playerTransform.position);
        bool wasInRange = isPlayerInRange;
        isPlayerInRange = distance <= interactionDistance;

        // 如果已经获得水枪，只显示提示不处理交互
        if (!hasObtainedGun)
        {
            if (isPlayerInRange != wasInRange)
            {
                UpdatePromptVisibility();
            }

            if (isPlayerInRange && Input.GetKeyDown(KeyCode.E))
            {
                ObtainWaterGun();
            }
        }

        // 水枪使用检测
        if (hasObtainedGun && currentWaterGun != null)
        {
            if (Input.GetMouseButtonDown(0))
            {
                UseWaterGun();
            }
        }
    }

    void UpdatePromptVisibility()
    {
        if (interactionPrompt != null)
        {
            interactionPrompt.SetActive(isPlayerInRange);

            if (promptText != null)
            {
                promptText.text = hasObtainedGun ? obtainedText : pickupText;
            }
        }
    }

    void ObtainWaterGun()
    {
        if (waterGunPrefab == null || playerCamera == null) return;

        // 在摄像机下生成水枪
        currentWaterGun = Instantiate(waterGunPrefab, playerCamera);
        currentWaterGun.transform.localPosition = spawnOffset;
        currentWaterGun.transform.localRotation = Quaternion.identity;

        hasObtainedGun = true;

        // 更新提示文本
        if (interactionPrompt != null && interactionPrompt.activeSelf)
        {
            promptText.text = obtainedText;
        }

        // 可以在这里添加获得音效等其他效果
        Debug.Log("水枪已获取！");
    }

    void UseWaterGun()
    {
        // 这里实现水枪的使用逻辑
        Debug.Log("使用水枪！");

        // 示例：播放水枪射击效果
        // 实际使用时需要添加水枪射击逻辑
    }

    void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.blue;
        Gizmos.DrawWireSphere(transform.position, interactionDistance);
    }
}