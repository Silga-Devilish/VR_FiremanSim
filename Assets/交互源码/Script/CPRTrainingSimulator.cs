using UnityEngine;
using UnityEngine.UI;

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
    public Image timingIndicator; // 新增按压计时指示器

    [Header("Settings")]
    public float maxDepth = 0.1f;
    public float optimalDepthMin = 0.05f;
    public float optimalDepthMax = 0.07f;
    public int optimalBPM = 110;
    public float minPressTime = 0.2f; // 最短有效按压时间
    public float maxPressTime = 0.4f; // 最长有效按压时间
    public float depthResponseCurve = 2f; // 深度响应曲线系数

    // 按压参数
    private float pressStartTime;
    private float lastPressTime;
    private float currentDepth;
    private int pressCount;
    private float[] pressIntervals = new float[10];
    private int currentIntervalIndex;
    private bool isPressing;

    // 模型位置
    private Vector3 chestOriginalPosition;

    void Start()
    {
        chestOriginalPosition = chestCollider.transform.localPosition;
        Cursor.visible = false;
        Cursor.lockState = CursorLockMode.Locked;
        timingIndicator.gameObject.SetActive(false);
        if (dataRecorder == null) dataRecorder = FindObjectOfType<CPRDataRecorder>();
        dataRecorder.StartNewSession();
    
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
        crosshair.rectTransform.position = new Vector3(
            Screen.width / 2, 
            Screen.height / 2, 
            0
        );
    }

    void HandleCPRInput()
    {
        // 开始按压
        if ((Input.GetMouseButtonDown(0) || Input.GetKeyDown(KeyCode.Space)))
        {
            Ray ray = Camera.main.ScreenPointToRay(new Vector3(Screen.width / 2, Screen.height / 2, 0));
            if (Physics.Raycast(ray, out var hit, 2f) && hit.collider.gameObject == chestCollider)
            {
                StartPress();
            }
        }

        // 结束按压
        if (isPressing && (Input.GetMouseButtonUp(0) || Input.GetKeyUp(KeyCode.Space)))
        {
            EndPress();
        }

        // 按压过程中更新深度
        if (isPressing)
        {
            float pressDuration = Time.time - pressStartTime;
            float normalizedTime = Mathf.Clamp01(pressDuration / maxPressTime);
            
            // 使用曲线函数使深度响应更自然
            currentDepth = maxDepth * Mathf.Pow(normalizedTime, depthResponseCurve);
            
            // 更新计时指示器
            UpdateTimingIndicator(pressDuration);
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

        if (pressDuration >= minPressTime)
        {
            float interval = Time.time - lastPressTime;
            pressIntervals[currentIntervalIndex] = interval;
            currentIntervalIndex = (currentIntervalIndex + 1) % pressIntervals.Length;
            lastPressTime = Time.time;
            pressCount++;
        }

        // 按压质量评估
        if (pressDuration < minPressTime)
        {
            feedbackText.text = "<color=red>按压太短！需要至少" + minPressTime.ToString("0.0") + "秒</color>";
            currentDepth = 0; // 无效按压不计深度
        }
        else if (pressDuration > maxPressTime)
        {
            feedbackText.text = "<color=red>按压过长！不要超过" + maxPressTime.ToString("0.0") + "秒</color>";
            currentDepth = optimalDepthMax; // 超过按最大深度计算
        }
        else
        {
            feedbackText.text = "<color=green>按压良好！深度：" + (currentDepth * 100).ToString("0") + "cm</color>";
        }

        feedbackText.GetComponent<Animator>().Play("FadeOut", 0, 0);
        pressCount++;
        bool optimalDepth = currentDepth >= optimalDepthMin && currentDepth <= optimalDepthMax;
    bool optimalDuration = pressDuration >= minPressTime && pressDuration <= maxPressTime;
    
    dataRecorder.RecordPress(
        currentDepth * 100, // 转换为cm
        pressDuration,
        optimalDepth,
        optimalDuration
    );
    
    }

    void UpdateChestAnimation()
    {
        // 平滑过渡到目标深度
        float targetY = chestOriginalPosition.y - currentDepth;
        chestCollider.transform.localPosition = new Vector3(
            chestOriginalPosition.x,
            Mathf.Lerp(chestCollider.transform.localPosition.y, targetY, Time.deltaTime * 10f),
            chestOriginalPosition.z
        );

        // 更新UI深度显示
        depthSlider.value = currentDepth / maxDepth;
        
        // 深度反馈颜色
        depthSlider.fillRect.GetComponent<Image>().color = 
            (currentDepth >= optimalDepthMin && currentDepth <= optimalDepthMax) ? 
            Color.green : Color.red;
    }

    void CalculateBPM()
    {
        if (pressCount < 2) return;

        float total = 0;
        int count = 0;
        
        // 只计算最近5次按压间隔（避免初期不准确数据）
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
