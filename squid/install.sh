# 1、下载
apt install squid -y

# 2、配置
cp /etc/squid/squid.conf /etc/squid/squid.conf.backup.$(date +%Y%m%d_%H%M%S)

# 创建新的测试配置
sudo tee /etc/squid/squid.conf > /dev/null << 'EOF'
# 定义 SSL 端口
acl SSL_ports port 443
# 定义 CONNECT 方法
acl CONNECT method CONNECT
# 允许所有来源
acl all src 0.0.0.0/0

# ============================================
# 访问控制规则 - 完全放开
# ============================================

# 允许 CONNECT 到 SSL 端口
http_access allow CONNECT SSL_ports

# 允许所有其他请求
http_access allow all

# ============================================
# 端口配置
# ============================================
http_port 3128

# ============================================
# 超时配置（增加超时时间）
# ============================================
forward_timeout 4 minutes
connect_timeout 2 minutes
peer_connect_timeout 60 seconds
read_timeout 15 minutes
request_timeout 5 minutes
persistent_request_timeout 2 minutes

# ============================================
# 日志配置
# ============================================
# 使用详细的日志格式
logformat combined %>a %[ui %[un [%tl] "%rm %ru HTTP/%rv" %>Hs %<st "%{Referer}>h" "%{User-Agent}>h" %Ss:%Sh
access_log daemon:/var/log/squid/access.log combined

# 缓存日志级别
debug_options ALL,1 33,2

# ============================================
# 缓存配置（禁用缓存，纯代理模式）
# ============================================
cache deny all

# ============================================
# DNS 配置
# ============================================
dns_nameservers 8.8.8.8 8.8.4.4

# 核心转储目录
coredump_dir /var/spool/squid
EOF


3、重启服务
systemctl restart squid

4、测试
curl -I https://huggingface.co --proxy http://192.168.1.100:3128

5、其他服务器使用
export http_proxy="http://YOUR_SQUID_SERVER_IP:3128"
export https_proxy="http://YOUR_SQUID_SERVER_IP:3128"
