using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;

public class CPRTrainingSimulator : MonoBehaviour
{
    [Header("Data Recording")]
    public CPRDataRecorder dataRecorder;

    [Header("UI References")]
    public Image crosshair;
    public Slider depthSlider;
    public Text bpmText;
    public Text feedbackText;
    public GameObject chestCollider;
    public Image timingIndicator;

    [Header("Settings")]
    public float maxDepth = 0.1f;
    public float optimalDepthMin = 0.05f;
    public float optimalDepthMax = 0.07f;
    public int optimalBPM = 110;
    public float minPressTime = 0.2f;
    public float maxPressTime = 0.4f;
    public float depthResponseCurve = 2f;

    // 按压参数
    private float pressStartTime;
    private float lastPressTime;
    private float currentDepth;
    private int pressCount;
    private float[] pressIntervals = new float[10];
    private int currentIntervalIndex;
    private bool isPressing;
    private Vector3 chestOriginalPosition;

    void Start()
    {
        chestOriginalPosition = chestCollider.transform.localPosition;
        timingIndicator.gameObject.SetActive(false);
        
        if (dataRecorder == null) 
        {
            dataRecorder = FindObjectOfType<CPRDataRecorder>();
        }
        
        // 初始化UI事件系统
        if (EventSystem.current == null)
        {
            gameObject.AddComponent<EventSystem>();
            gameObject.AddComponent<StandaloneInputModule>();
        }
    }

    void Update()
    {
        UpdateCrosshair();
        HandleCPRInput();
        UpdateChestAnimation();
        CalculateBPM();
    }

    void UpdateCrosshair()
    {
        // 只在非UI交互时显示准星
        crosshair.enabled = !EventSystem.current.IsPointerOverGameObject();
        crosshair.rectTransform.position = Input.mousePosition;
    }

    void HandleCPRInput()
    {
        // 鼠标左键按压（仅在未悬停在UI上时生效）
        if (!EventSystem.current.IsPointerOverGameObject())
        {
            if (Input.GetMouseButtonDown(0))
            {
                TryStartPress(Input.mousePosition);
            }

            if (isPressing && Input.GetMouseButtonUp(0))
            {
                EndPress();
            }
        }

        // 空格键全局按压
        if (Input.GetKeyDown(KeyCode.Space))
        {
            TryStartPress(new Vector3(Screen.width/2, Screen.height/2, 0));
        }

        if (isPressing && Input.GetKeyUp(KeyCode.Space))
        {
            EndPress();
        }

        // 按压过程中更新深度
        if (isPressing)
        {
            float pressDuration = Time.time - pressStartTime;
            float normalizedTime = Mathf.Clamp01(pressDuration / maxPressTime);
            currentDepth = maxDepth * Mathf.Pow(normalizedTime, depthResponseCurve);
            UpdateTimingIndicator(pressDuration);
        }
    }

    void TryStartPress(Vector3 screenPosition)
    {
        Ray ray = Camera.main.ScreenPointToRay(screenPosition);
        if (Physics.Raycast(ray, out var hit, 2f) && hit.collider.gameObject == chestCollider)
        {
            StartPress();
        }
        else if(screenPosition == Input.mousePosition) // 仅对鼠标点击给出反馈
        {
            ShowFeedback("<color=red>请对准胸部中央位置</color>");
        }
    }

    void StartPress()
    {
        isPressing = true;
        pressStartTime = Time.time;
        timingIndicator.gameObject.SetActive(true);
        timingIndicator.color = Color.yellow;

        // 记录按压间隔
        if (lastPressTime > 0)
        {
            float interval = Time.time - lastPressTime;
            pressIntervals[currentIntervalIndex] = interval;
            currentIntervalIndex = (currentIntervalIndex + 1) % pressIntervals.Length;
        }
        lastPressTime = Time.time;
    }

    void UpdateTimingIndicator(float currentDuration)
    {
        float fillAmount = currentDuration / maxPressTime;
        timingIndicator.fillAmount = fillAmount;

        if (currentDuration < minPressTime)
        {
            timingIndicator.color = Color.red;
        }
        else if (currentDuration > maxPressTime)
        {
            timingIndicator.color = Color.red;
        }
        else
        {
            timingIndicator.color = Color.green;
        }
    }

    void EndPress()
    {
        if (!isPressing) return;

        float pressDuration = Time.time - pressStartTime;
        isPressing = false;
        timingIndicator.gameObject.SetActive(false);

        // 按压质量评估
        if (pressDuration < minPressTime)
        {
            ShowFeedback($"<color=red>按压太短！需要至少{minPressTime.ToString("0.0")}秒</color>");
            currentDepth = 0;
        }
        else if (pressDuration > maxPressTime)
        {
            ShowFeedback($"<color=red>按压过长！不要超过{maxPressTime.ToString("0.0")}秒</color>");
            currentDepth = optimalDepthMax;
        }
        else
        {
            ShowFeedback($"<color=green>按压良好！深度：{(currentDepth * 100).ToString("0")}cm</color>");
        }

        // 记录有效按压
        if (pressDuration >= minPressTime)
        {
            pressCount++;
            bool optimalDepth = currentDepth >= optimalDepthMin && currentDepth <= optimalDepthMax;
            dataRecorder?.RecordPress(
                currentDepth * 100, // 转换为cm
                pressDuration,
                optimalDepth,
                pressDuration >= minPressTime && pressDuration <= maxPressTime
            );
        }
    }

    void ShowFeedback(string message)
    {
        feedbackText.text = message;
        if (feedbackText.GetComponent<Animator>() != null)
        {
            feedbackText.GetComponent<Animator>().Play("FadeOut", 0, 0);
        }
    }

    void UpdateChestAnimation()
    {
        float targetY = chestOriginalPosition.y - currentDepth;
        chestCollider.transform.localPosition = new Vector3(
            chestOriginalPosition.x,
            Mathf.Lerp(chestCollider.transform.localPosition.y, targetY, Time.deltaTime * 10f),
            chestOriginalPosition.z
        );

        depthSlider.value = currentDepth / maxDepth;
        depthSlider.fillRect.GetComponent<Image>().color = 
            (currentDepth >= optimalDepthMin && currentDepth <= optimalDepthMax) ? 
            Color.green : Color.red;
    }

    void CalculateBPM()
    {
        if (pressCount < 2) return;

        float total = 0;
        int count = 0;
        int validCount = Mathf.Min(5, pressCount - 1);
        
        for (int i = 0; i < validCount; i++)
        {
            int index = (currentIntervalIndex - 1 - i + pressIntervals.Length) % pressIntervals.Length;
            if (pressIntervals[index] > 0)
            {
                total += pressIntervals[index];
                count++;
            }
        }

        if (count > 0)
        {
            int bpm = Mathf.RoundToInt(60f / (total / count));
            bpmText.text = bpm + " BPM";
            bpmText.color = 
                (Mathf.Abs(bpm - optimalBPM) <= 10) ? 
                Color.green : 
                (bpm < optimalBPM ? Color.yellow : Color.red);
        }
    }
}
