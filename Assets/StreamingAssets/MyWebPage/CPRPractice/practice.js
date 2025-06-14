document.addEventListener('DOMContentLoaded', function() {
    // DOM 元素引用
    const elements = {
        chestTarget: document.getElementById('chest-target'),
        depthFill: document.getElementById('depth-fill'),
        rateFill: document.getElementById('rate-fill'),
        bpmDisplay: document.getElementById('bpm-display'),
        recoilBar: document.querySelector('.recoil-bar'),
        beatVisualizer: document.getElementById('beat-visualizer'),
        startBtn: document.getElementById('start-btn'),
        stopBtn: document.getElementById('stop-btn')
    };

    // 训练状态
    const state = {
        isTraining: false,
        lastPressTime: 0,
        pressCount: 0,
        pressIntervals: [],
        beatInterval: null,
        currentDepthIndex: 3, // 初始5cm
        depthLevels: [2, 3, 4, 5, 6, 7, 8], // cm
        targetBPM: 110,
        beatPosition: 0,
        beatDirection: 1
    };

    // 初始化
    function init() {
        setupEventListeners();
        resetFeedbackDisplays();
    }

    // 设置事件监听器
    function setupEventListeners() {
        elements.startBtn.addEventListener('click', startTraining);
        elements.stopBtn.addEventListener('click', stopTraining);
        
        // 桌面和移动端触摸事件
        elements.chestTarget.addEventListener('mousedown', handlePressStart);
        elements.chestTarget.addEventListener('mouseup', handlePressEnd);
        elements.chestTarget.addEventListener('touchstart', handlePressStart);
        elements.chestTarget.addEventListener('touchend', handlePressEnd);
        
        // VR环境适配
        if (typeof VR !== 'undefined') {
            elements.chestTarget.addEventListener('vr-controller-down', handlePressStart);
            elements.chestTarget.addEventListener('vr-controller-up', handlePressEnd);
        }
    }

    // 开始训练
    function startTraining() {
        state.isTraining = true;
        state.pressCount = 0;
        state.pressIntervals = [];
        state.lastPressTime = 0;
        
        updateButtonStates();
        resetFeedbackDisplays();
        startBeatVisualizer();
        
        // 初始随机深度
        updateDepthFeedback();
    }

    // 停止训练
    function stopTraining() {
        state.isTraining = false;
        clearInterval(state.beatInterval);
        state.beatInterval = null;
        
        updateButtonStates();
        showTrainingSummary();
    }

    // 处理按压开始
    function handlePressStart(e) {
        if (!state.isTraining) return;
        if (e.touches && e.touches.length > 1) return; // 忽略多点触控
        
        e.preventDefault();
        elements.chestTarget.classList.add('active');
        
        // 更新按压深度 (模拟实际变化)
        updateCompressionDepth();
        
        // 计算按压频率
        calculateCompressionRate();
    }

    // 处理按压结束
    function handlePressEnd(e) {
        if (!state.isTraining) return;
        
        e.preventDefault();
        elements.chestTarget.classList.remove('active');
        
        // 更新回弹反馈
        updateRecoilFeedback();
    }

    // 更新按压深度反馈
    function updateCompressionDepth() {
        // 随机生成深度变化 (模拟用户表现)
        state.currentDepthIndex = Math.min(
            state.depthLevels.length - 1, 
            Math.max(0, state.currentDepthIndex + Math.floor(Math.random() * 3) - 1)
        );
        
        const depth = state.depthLevels[state.currentDepthIndex];
        let depthPercent, fillClass;
        
        // 计算深度百分比和反馈颜色
        if (depth < 5) {
            depthPercent = (depth / 5) * 50;
            fillClass = 'error';
        } else if (depth > 6) {
            depthPercent = 50 + ((depth - 5) / 3) * 50;
            fillClass = 'warning';
        } else {
            depthPercent = 50 + ((depth - 5) * 25);
            fillClass = 'correct';
        }
        
        // 更新UI
        elements.depthFill.style.width = `${depthPercent}%`;
        elements.depthFill.className = 'meter-fill ' + fillClass;
    }

    // 计算按压频率
    function calculateCompressionRate() {
        const now = Date.now();
        
        if (state.lastPressTime > 0) {
            const interval = now - state.lastPressTime;
            state.pressIntervals.push(interval);
            
            // 计算BPM (每分钟按压次数)
            const bpm = Math.round(60000 / interval);
            updateRateFeedback(bpm);
        }
        
        state.lastPressTime = now;
        state.pressCount++;
    }

    // 更新频率反馈
    function updateRateFeedback(bpm) {
        // 计算频率百分比 (60-180 BPM映射到0-100%)
        let ratePercent = ((bpm - 60) / 120) * 100;
        ratePercent = Math.max(0, Math.min(100, ratePercent));
        
        // 确定反馈颜色
        let fillClass;
        if (bpm < 100 || bpm > 120) {
            fillClass = 'error';
        } else if (bpm < 105 || bpm > 115) {
            fillClass = 'warning';
        } else {
            fillClass = 'correct';
        }
        
        // 更新UI
        elements.rateFill.style.width = `${ratePercent}%`;
        elements.rateFill.className = 'meter-fill ' + fillClass;
        elements.bpmDisplay.textContent = `${bpm} BPM`;
        elements.bpmDisplay.className = 'bpm-display ' + fillClass;
    }

    // 更新回弹反馈
    function updateRecoilFeedback() {
        // 随机生成回弹完整度 (0.8-1.0)
        const recoil = 0.8 + Math.random() * 0.2;
        let fillClass;
        
        if (recoil < 0.9) {
            fillClass = 'error';
        } else if (recoil < 0.95) {
            fillClass = 'warning';
        } else {
            fillClass = 'correct';
        }
        
        // 更新UI
        elements.recoilBar.style.transform = `scaleX(${recoil})`;
        elements.recoilBar.className = 'recoil-bar ' + fillClass;
    }

    // 启动节拍器可视化
    function startBeatVisualizer() {
        // 清除现有节拍器
        if (state.beatInterval) {
            clearInterval(state.beatInterval);
        }
        
        elements.beatVisualizer.innerHTML = '';
        
        // 创建节拍指示器
        const beatIndicator = document.createElement('div');
        beatIndicator.className = 'beat-indicator';
        elements.beatVisualizer.appendChild(beatIndicator);
        
        // 计算节拍间隔 (ms)
        const beatIntervalMs = 60000 / state.targetBPM;
        
        // 启动动画
        state.beatInterval = setInterval(() => {
            state.beatPosition += state.beatDirection * 2;
            
            if (state.beatPosition > 100) {
                state.beatPosition = 100;
                state.beatDirection = -1;
                // 播放节拍音效 (VR环境中可以触发触觉反馈)
                playBeatSound();
            } else if (state.beatPosition < 0) {
                state.beatPosition = 0;
                state.beatDirection = 1;
            }
            
            beatIndicator.style.left = `${state.beatPosition}%`;
        }, beatIntervalMs / 50); // 平滑动画
    }

    // 播放节拍音效 (VR环境中可替换为触觉反馈)
    function playBeatSound() {
        if (typeof VR !== 'undefined') {
            // VR环境中的触觉反馈
            VR.triggerHapticPulse(0.1, 50); // 持续时间和强度
        } else {
            // 网页环境中的音频反馈
            const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
            const oscillator = audioCtx.createOscillator();
            const gainNode = audioCtx.createGain();
            
            oscillator.connect(gainNode);
            gainNode.connect(audioCtx.destination);
            
            oscillator.type = 'sine';
            oscillator.frequency.value = 880;
            gainNode.gain.value = 0.1;
            
            oscillator.start();
            gainNode.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.1);
            oscillator.stop(audioCtx.currentTime + 0.1);
        }
    }

    // 显示训练总结
    function showTrainingSummary() {
        if (state.pressIntervals.length === 0) return;
        
        // 计算平均BPM
        const avgInterval = state.pressIntervals.reduce((a, b) => a + b, 0) / state.pressIntervals.length;
        const avgBPM = Math.round(60000 / avgInterval);
        
        // 计算深度统计
        const depths = state.pressIntervals.map((_, i) => 
            i < state.depthLevels.length ? state.depthLevels[i] : 5
        );
        const avgDepth = depths.reduce((a, b) => a + b, 0) / depths.length;
        const correctDepthPercent = (depths.filter(d => d >= 5 && d <= 6).length / depths.length) * 100;
        
        // 创建总结信息
        const summary = `
            <div class="training-summary">
                <h3>训练总结</h3>
                <p>总按压次数: ${state.pressCount}</p>
                <p>平均频率: ${avgBPM} BPM</p>
                <p>平均深度: ${avgDepth.toFixed(1)} cm</p>
                <p>正确深度比例: ${correctDepthPercent.toFixed(0)}%</p>
                <p>建议: ${getFeedbackMessage(avgBPM, avgDepth, correctDepthPercent)}</p>
            </div>
        `;
        
        // 显示总结 (可以替换为更精美的模态框)
        alert(summary);
    }

    // 获取反馈消息
    function getFeedbackMessage(bpm, depth, depthPercent) {
        let messages = [];
        
        if (bpm < 100) messages.push("加快按压速度");
        if (bpm > 120) messages.push("稍微放慢速度");
        if (depth < 5) messages.push("增加按压深度");
        if (depth > 6) messages.push("减少按压深度");
        if (depthPercent < 80) messages.push("注意保持5-6cm的按压深度");
        
        if (messages.length === 0) {
            return "表现优秀！保持这种节奏和深度";
        }
        
        return messages.join("，") + "。";
    }

    // 更新按钮状态
    function updateButtonStates() {
        elements.startBtn.disabled = state.isTraining;
        elements.stopBtn.disabled = !state.isTraining;
    }

    // 重置反馈显示
    function resetFeedbackDisplays() {
        elements.depthFill.style.width = '50%';
        elements.depthFill.className = 'meter-fill';
        
        elements.rateFill.style.width = '50%';
        elements.rateFill.className = 'meter-fill';
        elements.bpmDisplay.textContent = '0 BPM';
        elements.bpmDisplay.className = 'bpm-display';
        
        elements.recoilBar.style.transform = 'scaleX(0.8)';
        elements.recoilBar.className = 'recoil-bar';
    }

    // 初始化应用
    init();
});
