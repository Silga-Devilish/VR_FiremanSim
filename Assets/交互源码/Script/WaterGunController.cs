using UnityEngine;
using System.Collections.Generic;

public class WaterGunController : MonoBehaviour
{
    [Header("�������")]
    [Tooltip("�����Ч")]
    public AudioClip shootingSound;

    [Header("����ϵͳ")]
    [Tooltip("�Զ�������������ϵͳ")]
    public bool autoFindParticleSystems = true;

    [Header("�������")]
    [Tooltip("ˮ�����������")]
    public float waterExtinguishPower = 0.1f;
    [Tooltip("������")]
    public LayerMask fireLayer;

    private List<ParticleSystem> waterParticleSystems = new List<ParticleSystem>();
    private AudioSource audioSource;
    private bool isShooting = false;

    void Awake()
    {
        // ȷ������ƵԴ
        audioSource = GetComponent<AudioSource>();
        if (audioSource == null)
        {
            audioSource = gameObject.AddComponent<AudioSource>();
            audioSource.spatialBlend = 0.5f; // ��3D��Ч
        }

        // �Զ���������ϵͳ
        if (autoFindParticleSystems)
        {
            CacheWaterParticleSystems();
        }
    }

    void Start()
    {
        // ��ʼʱֹͣ��������ϵͳ
        StopShooting();
    }

    void Update()
    {
        // �������������
        if (Input.GetMouseButtonDown(0))
        {
            StartShooting();
        }
        // ����������ͷ�
        else if (Input.GetMouseButtonUp(0))
        {
            StopShooting();
        }
    }

    // ����ˮǹ�ϵ�����ϵͳ
    public void CacheWaterParticleSystems()
    {
        waterParticleSystems.Clear();

        // ��ȡ��ǰˮǹ�ϵ���������ϵͳ
        ParticleSystem[] systems = GetComponentsInChildren<ParticleSystem>(true);
        waterParticleSystems.AddRange(systems);

        // ��ʼʱֹͣ��������ϵͳ
        foreach (var system in waterParticleSystems)
        {
            system.Stop(true, ParticleSystemStopBehavior.StopEmittingAndClear);
        }

        Debug.Log($"�ҵ� {waterParticleSystems.Count} ��ˮǹ����ϵͳ");
    }

    // ��ʼ���
    public void StartShooting()
    {
        if (isShooting) return; // ����Ѿ�������������ظ�����

        if (waterParticleSystems.Count == 0 && autoFindParticleSystems)
        {
            CacheWaterParticleSystems();
        }

        if (waterParticleSystems.Count == 0)
        {
            Debug.LogWarning("δ�ҵ�ˮǹ�������Ч����");
            return;
        }

        // ��ʼ��������Ч��
        foreach (var system in waterParticleSystems)
        {
            system.Play();
        }

        isShooting = true;

        // ���������Ч
        if (shootingSound != null)
        {
            audioSource.PlayOneShot(shootingSound);
        }

        Debug.Log($"ˮǹ��ʼ��������� {waterParticleSystems.Count} ������ϵͳ");
    }

    // ֹͣ���
    public void StopShooting()
    {
        if (!isShooting) return; // ����Ѿ�ֹͣ����������ظ�ֹͣ

        if (waterParticleSystems.Count == 0) return;

        // ֹͣ��������Ч��
        foreach (var system in waterParticleSystems)
        {
            system.Stop();
        }

        isShooting = false;
    }

    // �������ϵͳ�������Ҫ�ֶ���ӣ�
    public void AddParticleSystem(ParticleSystem system)
    {
        if (!waterParticleSystems.Contains(system))
        {
            waterParticleSystems.Add(system);
        }
    }

    // ������ײ�¼�
    void OnParticleCollision(GameObject other)
    {
        Debug.Log("����ײ");
        if (other.GetComponent<FireSpread>())
        {
            Debug.Log("��ײ�ǻ�");
            FireSpread fire = other.GetComponent<FireSpread>();
            if (fire != null)
            {
                fire.TakeDamage(waterExtinguishPower);
            }
        }
        Debug.Log("��ײ���ǻ�");
        Debug.Log(other.name);
    }
}