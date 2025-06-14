using UnityEngine;
using TMPro;

public class FireSafetyInteractable : MonoBehaviour
{
    [Header("UI References")]
    public GameObject fireSafetyPanel;
    
    [Header("Settings")]
    public string interactionText = "Press E to view fire safety knowledge";
    public float interactionDistance = 3f;
    
    [Header("UI Elements")]
    public GameObject interactionPrompt;

    private bool isPlayerInRange = false;
    private Transform playerTransform;
    private TMP_Text promptText;
    private FirstPersonController playerController;
    private bool wasCursorLocked; // 记录之前的鼠标锁定状态
    private bool wasCursorVisible; // 记录之前的鼠标可见状态

    void Start()
    {
        playerTransform = GameObject.FindGameObjectWithTag("Player")?.transform;
        
        if (playerTransform != null)
        {
            playerController = playerTransform.GetComponent<FirstPersonController>();
        }

        if (interactionPrompt != null)
        {
            promptText = interactionPrompt.GetComponentInChildren<TMP_Text>();
            interactionPrompt.SetActive(false);
        }

        if (fireSafetyPanel != null)
        {
            fireSafetyPanel.SetActive(false);
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

        if (isPlayerInRange && Input.GetKeyDown(KeyCode.E) && !fireSafetyPanel.activeSelf)
        {
            ShowFireSafetyPanel();
        }
        else if (fireSafetyPanel.activeSelf && Input.GetKeyDown(KeyCode.E))
        {
            HideFireSafetyPanel();
        }
    }

    void UpdatePromptVisibility()
    {
        if (interactionPrompt != null)
        {
            interactionPrompt.SetActive(isPlayerInRange && !fireSafetyPanel.activeSelf);
            
            if (promptText != null)
            {
                promptText.text = interactionText;
            }
        }
    }

    void ShowFireSafetyPanel()
    {
        if (fireSafetyPanel == null) return;

        // 保存当前状态
        wasCursorLocked = Cursor.lockState == CursorLockMode.Locked;
        wasCursorVisible = Cursor.visible;

        // 解锁鼠标
        Cursor.lockState = CursorLockMode.None;
        Cursor.visible = true;
        
        // 禁用玩家控制
        if (playerController != null)
        {
            playerController.enabled = false;
        }

        fireSafetyPanel.SetActive(true);
        UpdatePromptVisibility();
    }

    void HideFireSafetyPanel()
    {
        if (fireSafetyPanel == null) return;

        // 恢复鼠标状态
        Cursor.lockState = wasCursorLocked ? CursorLockMode.Locked : CursorLockMode.None;
        Cursor.visible = wasCursorVisible;
        
        // 恢复玩家控制
        if (playerController != null)
        {
            playerController.enabled = true;
        }

        fireSafetyPanel.SetActive(false);
        UpdatePromptVisibility();
    }

    void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.yellow;
        Gizmos.DrawWireSphere(transform.position, interactionDistance);
    }
}
