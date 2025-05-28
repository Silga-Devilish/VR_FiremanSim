using UnityEngine;
using UnityEngine.SceneManagement;
using TMPro;

public class SceneTransitionInteractable : MonoBehaviour
{
    [Header("场景设置")]
    [Tooltip("要跳转的目标场景名称")] 
    public string targetSceneName = "CPRScene";
    
    [Header("交互设置")]
    [Tooltip("交互提示显示的文本")]
    public string interactionText = "按E 跳转CPR教学场景";
    
    [Tooltip("交互检测距离")]
    public float interactionDistance = 3f;
    
    [Header("UI设置")]
    [Tooltip("拖入场景中的TextMeshPro提示UI对象")]
    public GameObject interactionPrompt; // 改为直接引用场景中的UI对象
    
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
            TransitionToScene();
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

    void TransitionToScene()
    {
        if (!string.IsNullOrEmpty(targetSceneName))
        {
            SceneManager.LoadScene(targetSceneName);
        }
    }

    void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.yellow;
        Gizmos.DrawWireSphere(transform.position, interactionDistance);
    }
}
