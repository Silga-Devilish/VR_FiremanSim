using UnityEngine;
using TMPro;

public class WaterGunInteractable : MonoBehaviour
{
    [Header("ˮǹ����")]
    [Tooltip("ˮǹԤ����")]
    public GameObject waterGunPrefab;

    [Tooltip("ˮǹ����λ��ƫ��")]
    public Vector3 spawnOffset = new Vector3(0.5f, -0.3f, 1f);

    [Header("��������")]
    [Tooltip("������ʾ��ʾ���ı�")]
    public string pickupText = "��E ��ȡˮǹ";

    [Tooltip("��ú����ʾ�ı�")]
    public string obtainedText = "�ѻ��ˮǹ����������ʹ��";

    [Tooltip("����������")]
    public float interactionDistance = 3f;

    [Header("UI����")]
    [Tooltip("���볡���е�TextMeshPro��ʾUI����")]
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
            Debug.LogError("δָ��������ʾUI����");
        }
    }

    void Update()
    {
        if (playerTransform == null || playerCamera == null) return;

        float distance = Vector3.Distance(transform.position, playerTransform.position);
        bool wasInRange = isPlayerInRange;
        isPlayerInRange = distance <= interactionDistance;

        // ����Ѿ����ˮǹ��ֻ��ʾ��ʾ��������
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

        // ˮǹʹ�ü��
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

        // �������������ˮǹ
        currentWaterGun = Instantiate(waterGunPrefab, playerCamera);
        currentWaterGun.transform.localPosition = spawnOffset;
        currentWaterGun.transform.localRotation = Quaternion.identity;

        hasObtainedGun = true;

        // ������ʾ�ı�
        if (interactionPrompt != null && interactionPrompt.activeSelf)
        {
            promptText.text = obtainedText;
        }

        // ������������ӻ����Ч������Ч��
        Debug.Log("ˮǹ�ѻ�ȡ��");
    }

    void UseWaterGun()
    {
        // ����ʵ��ˮǹ��ʹ���߼�
        Debug.Log("ʹ��ˮǹ��");

        // ʾ��������ˮǹ���Ч��
        // ʵ��ʹ��ʱ��Ҫ���ˮǹ����߼�
    }

    void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.blue;
        Gizmos.DrawWireSphere(transform.position, interactionDistance);
    }
}