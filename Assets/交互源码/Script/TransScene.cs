using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class TransScene : MonoBehaviour
{
    // 公共字符串变量，用于在Inspector中设置要加载的场景名称
    public string sceneName = "CPR_Main";  // 默认场景名

    // 预定义的可加载场景列表
    private static readonly HashSet<string> validScenes = new HashSet<string>
    {
        "CPR_Main", // 根据实际场景名称进行添加
        "TeachScene",
        "PracticeScene",
        "ZhanTing",
        // 添加更多场景...
    };

    // 公有方法，用于触发场景切换
    public void TS()
    {
        // 检查场景名称是否为空或者无效
        if (string.IsNullOrEmpty(sceneName))
        {
            Debug.LogError("场景名称未设置或为空！");
            return;
        }

        // 检查提供的场景名称是否存在于预定义的场景列表中
        if (!validScenes.Contains(sceneName))
        {
            Debug.LogError($"场景 '{sceneName}' 不存在于预定义的场景列表中！");
            return;
        }

        // 切换到新的场景
        SceneManager.LoadScene(sceneName);
    }
}