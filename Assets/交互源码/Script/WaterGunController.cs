using UnityEngine;
using System.Collections.Generic;

public class WaterGunController : MonoBehaviour
{
    [Header("射击设置")]
    [Tooltip("射击音效")]
    public AudioClip shootingSound;

    [Header("粒子系统")]
    [Tooltip("自动查找所有粒子系统")]
    public bool autoFindParticleSystems = true;

    [Header("灭火设置")]
    [Tooltip("水粒子灭火能力")]
    public float waterExtinguishPower = 0.1f;
    [Tooltip("灭火检测层")]
    public LayerMask fireLayer;

    private List<ParticleSystem> waterParticleSystems = new List<ParticleSystem>();
    private AudioSource audioSource;
    private bool isShooting = false;

    void Awake()
    {
        // 确保有音频源
        audioSource = GetComponent<AudioSource>();
        if (audioSource == null)
        {
            audioSource = gameObject.AddComponent<AudioSource>();
            audioSource.spatialBlend = 0.5f; // 半3D音效
        }

        // 自动查找粒子系统
        if (autoFindParticleSystems)
        {
            CacheWaterParticleSystems();
        }
    }

    void Start()
    {
        // 初始时停止所有粒子系统
        StopShooting();
    }

    void Update()
    {
        // 检测鼠标左键按下
        if (Input.GetMouseButtonDown(0))
        {
            StartShooting();
        }
        // 检测鼠标左键释放
        else if (Input.GetMouseButtonUp(0))
        {
            StopShooting();
        }
    }

    // 缓存水枪上的粒子系统
    public void CacheWaterParticleSystems()
    {
        waterParticleSystems.Clear();

        // 获取当前水枪上的所有粒子系统
        ParticleSystem[] systems = GetComponentsInChildren<ParticleSystem>(true);
        waterParticleSystems.AddRange(systems);

        // 初始时停止所有粒子系统
        foreach (var system in waterParticleSystems)
        {
            system.Stop(true, ParticleSystemStopBehavior.StopEmittingAndClear);
        }

        Debug.Log($"找到 {waterParticleSystems.Count} 个水枪粒子系统");
    }

    // 开始射击
    public void StartShooting()
    {
        if (isShooting) return; // 如果已经在射击，则不再重复启动

        if (waterParticleSystems.Count == 0 && autoFindParticleSystems)
        {
            CacheWaterParticleSystems();
        }

        if (waterParticleSystems.Count == 0)
        {
            Debug.LogWarning("未找到水枪射击粒子效果！");
            return;
        }

        // 开始所有粒子效果
        foreach (var system in waterParticleSystems)
        {
            system.Play();
        }

        isShooting = true;

        // 播放射击音效
        if (shootingSound != null)
        {
            audioSource.PlayOneShot(shootingSound);
        }

        Debug.Log($"水枪开始射击，激活 {waterParticleSystems.Count} 个粒子系统");
    }

    // 停止射击
    public void StopShooting()
    {
        if (!isShooting) return; // 如果已经停止射击，则不再重复停止

        if (waterParticleSystems.Count == 0) return;

        // 停止所有粒子效果
        foreach (var system in waterParticleSystems)
        {
            system.Stop();
        }

        isShooting = false;
    }

    // 添加粒子系统（如果需要手动添加）
    public void AddParticleSystem(ParticleSystem system)
    {
        if (!waterParticleSystems.Contains(system))
        {
            waterParticleSystems.Add(system);
        }
    }

    // 粒子碰撞事件
    void OnParticleCollision(GameObject other)
    {
        Debug.Log("有碰撞");
        if (other.GetComponent<FireSpread>())
        {
            Debug.Log("碰撞是火");
            FireSpread fire = other.GetComponent<FireSpread>();
            if (fire != null)
            {
                fire.TakeDamage(waterExtinguishPower);
            }
        }
        Debug.Log("碰撞不是火");
        Debug.Log(other.name);
    }
}