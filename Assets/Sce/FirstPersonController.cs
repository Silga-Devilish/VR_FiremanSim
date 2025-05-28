using UnityEngine;

public class FirstPersonController : MonoBehaviour
{
    [Header("Movement Settings")]
    public float moveSpeed = 5f;
    public float runSpeed = 8f;
    public float gravity = -9.81f;

    [Header("Look Settings")]
    public float mouseSensitivity = 100f;
    public float minVerticalAngle = -90f;
    public float maxVerticalAngle = 90f;

    [Header("Interaction Settings")]
    public float interactionDistance = 3f; // �ɽ�����������
    public LayerMask interactionLayer; // �ɽ�������Ĳ㼶

    private CharacterController characterController;
    private Camera playerCamera;
    private float verticalRotation = 0f;
    private Vector3 velocity;

    void Start()
    {
        characterController = GetComponent<CharacterController>();
        playerCamera = GetComponentInChildren<Camera>();

        // ������굽��Ϸ�������Ĳ�����
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
    }

    void Update()
    {
        HandleMovement();
        HandleLook();
        ApplyGravity();
        HandleInteraction();
    }

    void HandleInteraction()
    {
        // ��⽻����������E����
        if (Input.GetKeyDown(KeyCode.E))
        {
            Ray ray = new Ray(playerCamera.transform.position, playerCamera.transform.forward);
            RaycastHit hit;

            if (Physics.Raycast(ray, out hit, interactionDistance, interactionLayer))
            {
                VideoClickController videoController = hit.collider.GetComponent<VideoClickController>();
                if (videoController != null)
                {
                    videoController.ToggleVideoPlayback();
                }
            }
        }
    }
    void HandleMovement()
    {
        // ��ȡ����
        float horizontalInput = Input.GetAxis("Horizontal");
        float verticalInput = Input.GetAxis("Vertical");

        // ����Ƿ�ס��Shift�ܲ�
        float currentSpeed = Input.GetKey(KeyCode.LeftShift) ? runSpeed : moveSpeed;

        // �����ƶ����򣨻�����ҵ�ǰ����
        Vector3 moveDirection = transform.right * horizontalInput + transform.forward * verticalInput;

        // ��׼�������Է�ֹ�Խ����ƶ�����
        if (moveDirection.magnitude > 1f)
        {
            moveDirection.Normalize();
        }

        // �ƶ���ɫ
        characterController.Move(moveDirection * currentSpeed * Time.deltaTime);
    }

    void HandleLook()
    {
        // ��ȡ�������
        float mouseX = Input.GetAxis("Mouse X") * mouseSensitivity * Time.deltaTime;
        float mouseY = Input.GetAxis("Mouse Y") * mouseSensitivity * Time.deltaTime;

        // ��ֱ��ת�����¿��������ƽǶ�
        verticalRotation -= mouseY;
        verticalRotation = Mathf.Clamp(verticalRotation, minVerticalAngle, maxVerticalAngle);

        // Ӧ����ת
        playerCamera.transform.localRotation = Quaternion.Euler(verticalRotation, 0f, 0f);
        transform.Rotate(Vector3.up * mouseX);
    }

    void ApplyGravity()
    {
        if (characterController.isGrounded && velocity.y < 0)
        {
            velocity.y = -2f; // ��΢������ȷ����ɫ�����ڵ���
        }

        velocity.y += gravity * Time.deltaTime;
        characterController.Move(velocity * Time.deltaTime);
    }
}