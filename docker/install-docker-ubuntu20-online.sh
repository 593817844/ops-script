##具体可参考https://developer.aliyun.com/mirror/docker-ce?spm=a2c6h.13651102.0.0.57e31b110iCbia
# 重新导入 GPG 密钥
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
# 更新源列表以指定签名密钥
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# 更新软件包列表
apt update
# 安装（至此已经安装完成，该版本自带docker compose）
apt install docker-ce docker-ce-cli containerd.io -y 

# docker-ce：Docker 引擎本身，负责容器的生命周期管理。
# docker-ce-cli：命令行工具，允许用户与 Docker 引擎交互。
# containerd：底层容器运行时，负责容器的实际运行和管理。

#扩展1: 安装nvidia-container,使用nvidia显卡
apt install -y nvidia-container-toolkit
nvidia-ctk runtime configure --runtime=docker
systemctl restart docker

#扩展2：安装docker-compose
curl -L "https://github.whrstudio.top/https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
