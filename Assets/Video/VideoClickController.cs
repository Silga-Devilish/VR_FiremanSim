using UnityEngine;
using UnityEngine.Video;

[RequireComponent(typeof(VideoPlayer))]
[RequireComponent(typeof(Collider))] // 确保有碰撞体
public class VideoClickController : MonoBehaviour
{
    private VideoPlayer videoPlayer;
    private bool isPlaying = false;

    [Header("Interaction Settings")]
    public KeyCode interactionKey = KeyCode.E;
    public float interactionDistance = 3f;

    void Start()
    {
        videoPlayer = GetComponent<VideoPlayer>();
        videoPlayer.Pause();
    }

    public void ToggleVideoPlayback()
    {
        if (isPlaying)
        {
            videoPlayer.Pause();
            isPlaying = false;
            Debug.Log("视频已暂停");
        }
        else
        {
            videoPlayer.Play();
            isPlaying = true;
            Debug.Log("视频已播放");
        }
    }
}