#!/bin/bash

# 单机RoCE网络配置脚本
# 简化版本，移除了多节点同步功能，保留核心RoCE配置逻辑

set -e

# --- 辅助函数 ---
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] \$1"
}

log "开始RoCE网络配置..."

# --- RoCE网络设置 (静态IP分配) ---
mtu=4200
mlx_devs="mlx5_0 mlx5_1 mlx5_2 mlx5_3"

# 从主机名提取work编号 (如 "work123")
WORK_NUM=$(hostname | sed -E 's/.*work([0-9]+).*/\1/')
if ! [[ "$WORK_NUM" =~ ^[0-9]+$ ]]; then
    log "警告: 无法从主机名确定work编号，使用默认值1"
    WORK_NUM=1
fi
IP_SUFFIX=$((WORK_NUM + 1))

log "检测到work编号: $WORK_NUM，IP后缀: $IP_SUFFIX"

# 停止可能干扰的DHCP客户端
log "停止DHCP客户端..."
sudo pkill -f "dhclient eth" || true

# 配置以太网设备静态IP
log "配置网络接口..."
for i in {1..4}; do
    dev="eth$i"
    subnet="$i"
    ip="192.168.$subnet.$IP_SUFFIX"
    
    log "为设备 $dev 分配IP $ip"
    
    # 清除旧IP配置
    sudo ip addr flush dev "$dev" 2>/dev/null || true
    sudo ip link set "$dev" mtu "$mtu"
    sudo ip link set "$dev" up
    sudo ip addr add "$ip/24" dev "$dev"
done

# 配置RoCE特定设置
log "配置RoCE设备..."
for dev in $mlx_devs; do
    if command -v cma_roce_tos >/dev/null 2>&1; then
        sudo cma_roce_tos -d "$dev" -t 184 || log "警告: cma_roce_tos命令失败或设备 $dev 不存在"
    fi
    
    if command -v cma_roce_mode >/dev/null 2>&1; then
        sudo cma_roce_mode -d "$dev" -m 2 || log "警告: cma_roce_mode命令失败或设备 $dev 不存在"
    fi
    
    # 确保sysfs路径存在再写入
    if [ -d "/sys/class/infiniband/$dev" ]; then
        echo 184 | sudo tee "/sys/class/infiniband/$dev/tc/1/traffic_class" >/dev/null || true
    fi
done

# 加载必要的内核模块
log "加载内核模块..."
sudo modprobe rdma_cm || log "警告: 无法加载rdma_cm模块"
sudo modprobe nvidia_peermem || log "警告: 无法加载nvidia_peermem模块"

# 确保模块在启动时自动加载
log "配置启动时自动加载模块..."
sudo bash -c 'echo -e "nvidia_peermem\nrdma_cm" > /etc/modules-load.d/roce-modules.conf'

# 创建systemd服务以确保配置持久化
log "创建systemd服务..."
sudo tee /etc/systemd/system/roce-network-setup.service > /dev/null << 'EOF'
[Unit]
Description=RoCE Network Setup
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/roce-network-setup.sh
RemainAfterExit=yes
StandardOutput=journal+console
StandardError=journal+console

[Install]
WantedBy=multi-user.target
EOF

# 将此脚本复制到系统目录
sudo cp "\$0" /usr/local/sbin/roce-network-setup.sh
sudo chmod +x /usr/local/sbin/roce-network-setup.sh

# 启用systemd服务
sudo systemctl daemon-reload
sudo systemctl enable roce-network-setup.service

log "RoCE网络配置完成!"

# 显示配置结果
log "当前网络接口配置:"
for i in {1..4}; do
    dev="eth$i"
    if ip addr show "$dev" >/dev/null 2>&1; then
        ip addr show "$dev" | grep -E "inet |mtu" || true
    fi
done

log "已加载的RDMA相关模块:"
lsmod | grep -E "(rdma|nvidia_peer)" || log "未找到相关模块"

log "配置完成，系统重启后配置将自动生效"
