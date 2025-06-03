using UnityEngine;
using UnityEngine.SceneManagement;
using TMPro;

public class FireSafetyInteractable : MonoBehaviour
{
    [Header("��������")]
    [Tooltip("������ȫ֪ʶUI���")]
    public GameObject fireSafetyPanel; // ����������������ȫ֪ʶUI���

    [Header("��������")]
    [Tooltip("������ʾ��ʾ���ı�")]
    public string interactionText = "��E �鿴������ȫ֪ʶ";

    [Tooltip("����������")]
    public float interactionDistance = 3f;

    [Header("UI����")]
    [Tooltip("���볡���е�TextMeshPro��ʾUI����")]
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
            Debug.LogError("δָ��������ʾUI����");
        }

        // ��ʼ��ʱ����������ȫ֪ʶ���
        if (fireSafetyPanel != null)
        {
            fireSafetyPanel.SetActive(false);
        }
        else
        {
            Debug.LogError("δָ��������ȫ֪ʶUI��壡");
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
            // �л�������ʾ״̬
            bool isActive = !fireSafetyPanel.activeSelf;
            fireSafetyPanel.SetActive(isActive);

            // ���Ը�����Ҫ��������ͣ��Ϸ
            // Time.timeScale = isActive ? 0 : 1;
        }
    }

    void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.yellow;
        Gizmos.DrawWireSphere(transform.position, interactionDistance);
    }
}