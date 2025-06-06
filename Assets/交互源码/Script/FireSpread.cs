using UnityEngine;
using System.Collections;

public class FireSpread : MonoBehaviour
{
    [Header("Core Fire Settings")]
    public ParticleSystem coreFireParticles;   // ���Ļ�������ϵͳ
    public float coreGrowthTime = 3f;         // ���ĳɳ�ʱ��
    public float maxCoreSize = 2f;            // �������ߴ�
    public AnimationCurve growthCurve;        // ��������

    [Header("Circular Spread Settings")]
    public GameObject firePrefab;             // ��ԴԤ����
    public float maxRadius = 10f;             // ������Ӱ뾶
    public float ringWidth = 1f;              // ÿȦ�𻷿��
    public float timeBetweenRings = 1f;       // ÿȦ���ɼ��
    public int firesPerRing = 8;              // ÿȦ��Դ����
    public float ringSizeReduction = 0.9f;    // ÿȦ�ߴ�����

    [Header("Variation Settings")]
    public float sizeVariation = 0.2f;        // �ߴ�����仯
    public float positionVariation = 0.3f;    // λ�����ƫ��

    [Header("�������")]
    public float health = 10f;                // ��������ֵ

    private float currentRadius = 0f;
    private int currentRing = 0;
    private float initialSize;                // ��ʼ��С

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

    // ����ˮ�˺�
    public void TakeDamage(float damage)
    {
        health -= damage;

        // ���»����С
        float scaleFactor = Mathf.Clamp01(health / 10f);
        transform.localScale = Vector3.one * initialSize * scaleFactor;

        // ������ֵ�ľ�ʱϨ�����
        if (health <= 0)
        {
            Extinguish();
        }
    }

    // Ϩ�����
    private void Extinguish()
    {
        // ֹͣ����Э��
        StopAllCoroutines();

        // ֹͣ����ϵͳ
        if (coreFireParticles != null)
        {
            coreFireParticles.Stop();
        }

        // ���ýű�
        enabled = false;

        // �ӳ����ٶ���
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

            // ���Ļ�������
            transform.localScale = Vector3.Lerp(initialScale, Vector3.one * maxCoreSize, progress);

            // ��������ϵͳ
            var shape = coreFireParticles.shape;
            shape.radius = Mathf.Lerp(0.5f, maxCoreSize, progress);

            var main = coreFireParticles.main;
            main.startSizeMultiplier = Mathf.Lerp(0.8f, maxCoreSize, progress);

            yield return null;
        }

        // ����������ɺ�ʼԲ������
        StartCoroutine(SpreadInCircles());
    }

    IEnumerator SpreadInCircles()
    {
        while (currentRadius < maxRadius)
        {
            yield return new WaitForSeconds(timeBetweenRings);

            currentRing++;
            currentRadius = currentRing * ringWidth;

            // ������һȦ�Ļ�Դ��������뾶���ӣ�
            int firesThisRing = Mathf.RoundToInt(firesPerRing * (1 + currentRing * 0.2f));

            // ��Բ���Ͼ��ȷֲ���Դ
            for (int i = 0; i < firesThisRing; i++)
            {
                float angle = i * (360f / firesThisRing);
                Vector3 basePos = transform.position + Quaternion.Euler(0, angle, 0) * Vector3.forward * currentRadius;

                // ������λ��ƫ��
                Vector3 randomOffset = Random.insideUnitSphere * positionVariation;
                randomOffset.y = 0; // ����Y�᲻��
                Vector3 spawnPos = basePos + randomOffset;

                // ������Դ
                GameObject newFire = Instantiate(firePrefab, spawnPos, Quaternion.identity);

                // ���������С��˥��
                float sizeScale = Random.Range(1f - sizeVariation, 1f + sizeVariation) * Mathf.Pow(ringSizeReduction, currentRing);
                newFire.transform.localScale = Vector3.one * sizeScale;

                // ���û�Դ���ټ������ӣ���������Ӵ�����
                FireSpread spread = newFire.GetComponent<FireSpread>();
                if (spread != null)
                {
                    spread.maxRadius = 0; // ��ֹ�������ӣ����Կ���С
                }
            }
        }
    }

    void OnDrawGizmosSelected()
    {
        // ���Ƶ�ǰ���Ӱ뾶
        Gizmos.color = new Color(1, 0.5f, 0, 0.3f);
        Gizmos.DrawWireSphere(transform.position, currentRadius);

        // ����������ӷ�Χ
        Gizmos.color = new Color(1, 0, 0, 0.1f);
        Gizmos.DrawWireSphere(transform.position, maxRadius);
    }
}