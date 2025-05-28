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
    public float interactionDistance = 3f; // 可交互的最大距离
    public LayerMask interactionLayer; // 可交互物体的层级

    private CharacterController characterController;
    private Camera playerCamera;
    private float verticalRotation = 0f;
    private Vector3 velocity;

    void Start()
    {
        characterController = GetComponent<CharacterController>();
        playerCamera = GetComponentInChildren<Camera>();

        // 锁定光标到游戏窗口中心并隐藏
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
        // 检测交互按键（如E键）
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
        // 获取输入
        float horizontalInput = Input.GetAxis("Horizontal");
        float verticalInput = Input.GetAxis("Vertical");

        // 检查是否按住左Shift跑步
        float currentSpeed = Input.GetKey(KeyCode.LeftShift) ? runSpeed : moveSpeed;

        // 计算移动方向（基于玩家当前朝向）
        Vector3 moveDirection = transform.right * horizontalInput + transform.forward * verticalInput;

        // 标准化向量以防止对角线移动更快
        if (moveDirection.magnitude > 1f)
        {
            moveDirection.Normalize();
        }

        // 移动角色
        characterController.Move(moveDirection * currentSpeed * Time.deltaTime);
    }

    void HandleLook()
    {
        // 获取鼠标输入
        float mouseX = Input.GetAxis("Mouse X") * mouseSensitivity * Time.deltaTime;
        float mouseY = Input.GetAxis("Mouse Y") * mouseSensitivity * Time.deltaTime;

        // 垂直旋转（上下看）并限制角度
        verticalRotation -= mouseY;
        verticalRotation = Mathf.Clamp(verticalRotation, minVerticalAngle, maxVerticalAngle);

        // 应用旋转
        playerCamera.transform.localRotation = Quaternion.Euler(verticalRotation, 0f, 0f);
        transform.Rotate(Vector3.up * mouseX);
    }

    void ApplyGravity()
    {
        if (characterController.isGrounded && velocity.y < 0)
        {
            velocity.y = -2f; // 轻微向下力确保角色保持在地面
        }

        velocity.y += gravity * Time.deltaTime;
        characterController.Move(velocity * Time.deltaTime);
    }
}