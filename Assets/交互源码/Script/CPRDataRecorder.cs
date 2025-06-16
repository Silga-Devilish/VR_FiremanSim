using UnityEngine;
using UnityEngine.Networking;
using UnityEngine.UI;
using System.Collections;
using System.Collections.Generic;
using System;

[System.Serializable]
public class CPRTrainingData
{
    public List<CPRPress> presses = new List<CPRPress>();
    public float averageDepth;
    public float averageBPM;
    public float accuracyScore;
    public string timestamp;
}

[System.Serializable]
public class CPRPress
{
    public float depth; // cm
    public float duration; // seconds
    public float interval; // seconds since last press
    public bool wasOptimalDepth;
    public bool wasOptimalDuration;
}

public class CPRDataRecorder : MonoBehaviour
{
    [Header("API Settings")]
    public string apiEndpoint = "https://api.deepseek.com/v1/cpr_analysis";
    public string apiKey = "sk-df37a52569f7443fa852f86489de986a";
    
    [Header("UI References")]
    public Text reportText;
    public Button sendDataButton;
    public GameObject reportPanel;
    
    private CPRTrainingData currentSession;
    private float lastPressTime;
    private bool isRecording;
    
    void Start()
    {
        StartNewSession();
        sendDataButton.onClick.AddListener(SendDataToAPI);
    }
    
    public void StartNewSession()
    {
        currentSession = new CPRTrainingData
        {
            timestamp = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss")
        };
        lastPressTime = 0;
        isRecording = true;
    }
    
    public void RecordPress(float depth, float duration, bool optimalDepth, bool optimalDuration)
    {
        if (!isRecording) return;
        
        float interval = lastPressTime > 0 ? Time.time - lastPressTime : 0;
        
        currentSession.presses.Add(new CPRPress
        {
            depth = depth,
            duration = duration,
            interval = interval,
            wasOptimalDepth = optimalDepth,
            wasOptimalDuration = optimalDuration
        });
        
        lastPressTime = Time.time;
    }
    
    public void CalculateSessionMetrics()
    {
        if (currentSession.presses.Count == 0) return;
        
        float totalDepth = 0;
        float totalIntervals = 0;
        int optimalPresses = 0;
        
        foreach (var press in currentSession.presses)
        {
            totalDepth += press.depth;
            if (press.interval > 0) totalIntervals += press.interval;
            if (press.wasOptimalDepth && press.wasOptimalDuration) optimalPresses++;
        }
        
        currentSession.averageDepth = totalDepth / currentSession.presses.Count;
        currentSession.averageBPM = 60f / (totalIntervals / (currentSession.presses.Count - 1));
        currentSession.accuracyScore = (float)optimalPresses / currentSession.presses.Count * 100f;
    }
    
    public void SendDataToAPI()
    {
        if (currentSession.presses.Count == 0) return;
        
        CalculateSessionMetrics();
        StartCoroutine(PostTrainingData());
    }
    
    IEnumerator PostTrainingData()
    {
        string jsonData = JsonUtility.ToJson(currentSession);
        
        UnityWebRequest request = new UnityWebRequest(apiEndpoint, "POST");
        byte[] bodyRaw = System.Text.Encoding.UTF8.GetBytes(jsonData);
        
        request.uploadHandler = new UploadHandlerRaw(bodyRaw);
        request.downloadHandler = new DownloadHandlerBuffer();
        request.SetRequestHeader("Content-Type", "application/json");
        request.SetRequestHeader("Authorization", "Bearer " + apiKey);
        
        sendDataButton.interactable = false;
        reportText.text = "正在分析数据...";
        reportPanel.SetActive(true);
        
        yield return request.SendWebRequest();
        
        if (request.result == UnityWebRequest.Result.Success)
        {
            DisplayAnalysisResult(request.downloadHandler.text);
        }
        else
        {
            reportText.text = $"分析失败: {request.error}";
        }
        
        sendDataButton.interactable = true;
    }
    
    void DisplayAnalysisResult(string apiResponse)
    {
        // 这里解析API返回的JSON数据
        // 示例响应格式:
        /*
        {
            "score": 85,
            "feedback": "您的按压深度良好，但频率稍快...",
            "recommendations": ["建议放慢节奏至100-110BPM", "注意完全回弹"],
            "detailed_analysis": {...}
        }
        */
        
        try
        {
            var response = JsonUtility.FromJson<DeepSeekResponse>(apiResponse);
            
            string report = $"<b>CPR训练报告</b>\n";
            report += $"得分: <color=green>{response.score}/100</color>\n\n";
            report += $"<b>主要反馈:</b>\n{response.feedback}\n\n";
            report += $"<b>建议:</b>\n";
            
            foreach (var recommendation in response.recommendations)
            {
                report += $"• {recommendation}\n";
            }
            
            reportText.text = report;
        }
        catch (Exception e)
        {
            reportText.text = $"报告解析错误: {e.Message}";
        }
    }
    
    [System.Serializable]
    private class DeepSeekResponse
    {
        public int score;
        public string feedback;
        public string[] recommendations;
    }
}
