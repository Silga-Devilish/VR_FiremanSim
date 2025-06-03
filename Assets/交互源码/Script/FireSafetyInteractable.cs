using UnityEngine;
using UnityEngine.SceneManagement;
using TMPro;

public class FireSafetyInteractable : MonoBehaviour
{
    [Header("场景设置")]
    [Tooltip("消防安全知识UI面板")]
    public GameObject fireSafetyPanel; // 新增：引用消防安全知识UI面板

    [Header("交互设置")]
    [Tooltip("交互提示显示的文本")]
    public string interactionText = "按E 查看消防安全知识";

    [Tooltip("交互检测距离")]
    public float interactionDistance = 3f;

    [Header("UI设置")]
    [Tooltip("拖入场景中的TextMeshPro提示UI对象")]
    public GameObject interactionPrompt;

    private bool isPlayerInRange = false;
    private Transform playerTransform;
    private TMP_Text promptText;

    void Start()
    {
        playerTransform = GameObject.FindGameObjectWithTag("Player")?.transform;

        if (interactionPrompt != null)
        {
            promptText = interactionPrompt.GetComponentInChildren<TMP_Text>();
            interactionPrompt.SetActive(false);
        }
        else
        {
            Debug.LogError("未指定交互提示UI对象！");
        }

        // 初始化时隐藏消防安全知识面板
        if (fireSafetyPanel != null)
        {
            fireSafetyPanel.SetActive(false);
        }
        else
        {
            Debug.LogError("未指定消防安全知识UI面板！");
        }
    }

    void Update()
    {
        if (playerTransform == null) return;

        float distance = Vector3.Distance(transform.position, playerTransform.position);
        bool wasInRange = isPlayerInRange;
        isPlayerInRange = distance <= interactionDistance;

        if (isPlayerInRange != wasInRange)
        {
            UpdatePromptVisibility();
        }

        if (isPlayerInRange && Input.GetKeyDown(KeyCode.E))
        {
            ToggleFireSafetyPanel();
        }
    }

    void UpdatePromptVisibility()
    {
        if (interactionPrompt != null)
        {
            interactionPrompt.SetActive(isPlayerInRange);

            if (promptText != null)
            {
                promptText.text = interactionText;
            }
        }
    }

    void ToggleFireSafetyPanel()
    {
        if (fireSafetyPanel != null)
        {
            // 切换面板的显示状态
            bool isActive = !fireSafetyPanel.activeSelf;
            fireSafetyPanel.SetActive(isActive);

            // 可以根据需要在这里暂停游戏
            // Time.timeScale = isActive ? 0 : 1;
        }
    }

    void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.yellow;
        Gizmos.DrawWireSphere(transform.position, interactionDistance);
    }
}