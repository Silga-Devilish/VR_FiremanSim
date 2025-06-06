using UnityEngine;
using System.Collections;

public class FireSpread : MonoBehaviour
{
    [Header("Core Fire Settings")]
    public ParticleSystem coreFireParticles;   // 核心火焰粒子系统
    public float coreGrowthTime = 3f;         // 核心成长时间
    public float maxCoreSize = 2f;            // 核心最大尺寸
    public AnimationCurve growthCurve;        // 生长曲线

    [Header("Circular Spread Settings")]
    public GameObject firePrefab;             // 火源预制体
    public float maxRadius = 10f;             // 最大蔓延半径
    public float ringWidth = 1f;              // 每圈火环宽度
    public float timeBetweenRings = 1f;       // 每圈生成间隔
    public int firesPerRing = 8;              // 每圈火源数量
    public float ringSizeReduction = 0.9f;    // 每圈尺寸缩减

    [Header("Variation Settings")]
    public float sizeVariation = 0.2f;        // 尺寸随机变化
    public float positionVariation = 0.3f;    // 位置随机偏移

    [Header("灭火设置")]
    public float health = 10f;                // 火焰生命值

    private float currentRadius = 0f;
    private int currentRing = 0;
    private float initialSize;                // 初始大小

    void Start()
    {
        if (growthCurve == null)
        {
            growthCurve = AnimationCurve.EaseInOut(0, 0, 1, 1);
        }

        if (coreFireParticles == null)
        {
            coreFireParticles = GetComponent<ParticleSystem>();
        }

        initialSize = transform.localScale.x;
        StartCoroutine(GrowCoreFire());
    }

    // 接收水伤害
    public void TakeDamage(float damage)
    {
        health -= damage;

        // 更新火焰大小
        float scaleFactor = Mathf.Clamp01(health / 10f);
        transform.localScale = Vector3.one * initialSize * scaleFactor;

        // 当生命值耗尽时熄灭火焰
        if (health <= 0)
        {
            Extinguish();
        }
    }

    // 熄灭火焰
    private void Extinguish()
    {
        // 停止所有协程
        StopAllCoroutines();

        // 停止粒子系统
        if (coreFireParticles != null)
        {
            coreFireParticles.Stop();
        }

        // 禁用脚本
        enabled = false;

        // 延迟销毁对象
        Destroy(gameObject, 0.5f);
    }

    IEnumerator GrowCoreFire()
    {
        float elapsed = 0f;
        Vector3 initialScale = transform.localScale;

        while (elapsed < coreGrowthTime)
        {
            elapsed += Time.deltaTime;
            float progress = growthCurve.Evaluate(elapsed / coreGrowthTime);

            // 核心火焰生长
            transform.localScale = Vector3.Lerp(initialScale, Vector3.one * maxCoreSize, progress);

            // 调整粒子系统
            var shape = coreFireParticles.shape;
            shape.radius = Mathf.Lerp(0.5f, maxCoreSize, progress);

            var main = coreFireParticles.main;
            main.startSizeMultiplier = Mathf.Lerp(0.8f, maxCoreSize, progress);

            yield return null;
        }

        // 核心生长完成后开始圆形蔓延
        StartCoroutine(SpreadInCircles());
    }

    IEnumerator SpreadInCircles()
    {
        while (currentRadius < maxRadius)
        {
            yield return new WaitForSeconds(timeBetweenRings);

            currentRing++;
            currentRadius = currentRing * ringWidth;

            // 计算这一圈的火源数量（随半径增加）
            int firesThisRing = Mathf.RoundToInt(firesPerRing * (1 + currentRing * 0.2f));

            // 在圆周上均匀分布火源
            for (int i = 0; i < firesThisRing; i++)
            {
                float angle = i * (360f / firesThisRing);
                Vector3 basePos = transform.position + Quaternion.Euler(0, angle, 0) * Vector3.forward * currentRadius;

                // 添加随机位置偏移
                Vector3 randomOffset = Random.insideUnitSphere * positionVariation;
                randomOffset.y = 0; // 保持Y轴不变
                Vector3 spawnPos = basePos + randomOffset;

                // 创建火源
                GameObject newFire = Instantiate(firePrefab, spawnPos, Quaternion.identity);

                // 设置随机大小和衰减
                float sizeScale = Random.Range(1f - sizeVariation, 1f + sizeVariation) * Mathf.Pow(ringSizeReduction, currentRing);
                newFire.transform.localScale = Vector3.one * sizeScale;

                // 配置火源不再继续蔓延（或减少蔓延代数）
                FireSpread spread = newFire.GetComponent<FireSpread>();
                if (spread != null)
                {
                    spread.maxRadius = 0; // 禁止继续蔓延，但仍可缩小
                }
            }
        }
    }

    void OnDrawGizmosSelected()
    {
        // 绘制当前蔓延半径
        Gizmos.color = new Color(1, 0.5f, 0, 0.3f);
        Gizmos.DrawWireSphere(transform.position, currentRadius);

        // 绘制最大蔓延范围
        Gizmos.color = new Color(1, 0, 0, 0.1f);
        Gizmos.DrawWireSphere(transform.position, maxRadius);
    }
}