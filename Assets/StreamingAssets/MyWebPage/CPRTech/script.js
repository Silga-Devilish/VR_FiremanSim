document.addEventListener('DOMContentLoaded', function() {
    const steps = document.querySelectorAll('.step');
    const prevBtn = document.getElementById('prev-btn');
    const nextBtn = document.getElementById('next-btn');
    const resetBtn = document.getElementById('reset-btn');
    let currentStep = 0;

    // 初始化显示第一步
    showStep(currentStep);

    // 下一步按钮事件
    nextBtn.addEventListener('click', function() {
        if (currentStep < steps.length - 1) {
            currentStep++;
            showStep(currentStep);
        }
    });

    // 上一步按钮事件
    prevBtn.addEventListener('click', function() {
        if (currentStep > 0) {
            currentStep--;
            showStep(currentStep);
        }
    });

    // 重置按钮事件
    resetBtn.addEventListener('click', function() {
        currentStep = 0;
        showStep(currentStep);
    });

    // 显示指定步骤
    function showStep(stepIndex) {
        // 隐藏所有步骤
        steps.forEach(step => {
            step.classList.remove('active');
        });

        // 显示当前步骤
        steps[stepIndex].classList.add('active');

        // 更新按钮状态
        prevBtn.disabled = stepIndex === 0;
        nextBtn.disabled = stepIndex === steps.length - 1;

        // 添加动画效果
        animateStep(steps[stepIndex]);
    }

    // 步骤动画效果
    function animateStep(stepElement) {
        // 重置动画
        stepElement.style.transform = 'translateX(-20px)';
        stepElement.style.opacity = '0';

        // 应用动画
        setTimeout(() => {
            stepElement.style.transition = 'transform 0.5s ease, opacity 0.5s ease';
            stepElement.style.transform = 'translateX(0)';
            stepElement.style.opacity = '1';
        }, 50);

        // 数字动画
        const stepNumber = stepElement.querySelector('.step-number');
        stepNumber.style.transform = 'scale(0)';
        
        setTimeout(() => {
            stepNumber.style.transition = 'transform 0.3s ease';
            stepNumber.style.transform = 'scale(1)';
        }, 300);
    }

    // 模拟VR环境中的交互
    if (typeof VR !== 'undefined') {
        // 如果是在VR环境中，添加额外的交互逻辑
        document.addEventListener('vr-controller-click', function(e) {
            if (e.target.classList.contains('control-btn')) {
                e.target.click();
            }
        });
    }

    // 添加键盘导航
    document.addEventListener('keydown', function(e) {
        if (e.key === 'ArrowRight' || e.key === ' ') {
            nextBtn.click();
        } else if (e.key === 'ArrowLeft') {
            prevBtn.click();
        } else if (e.key === 'Home') {
            resetBtn.click();
        }
    });
});
