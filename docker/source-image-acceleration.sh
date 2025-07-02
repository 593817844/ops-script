mkdir -p /etc/docker
cat >> /etc/docker/daemon.json <<EOF
{
    "registry-mirrors": [
        "https://docker.xuanyuan.me",
        "https://docker.m.daocloud.io"
    ]
}
EOF
systemctl daemon-reload
systemctl restart docker
