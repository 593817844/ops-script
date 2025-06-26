# 下载分支
git clone https://github.com/prometheus-operator/kube-prometheus.git --branch release-0.15

cd kube-prometheus
#首先创建需要的命名空间和 CRD
kubectl create -f manifests/setup

#可选，修改镜像地址，国内可能无法拉去
sed -i s/registry.k8s.io/k8s.mirror.nju.edu.cn/ manifests/prometheusAdapter-deployment.yaml
sed -i s/registry.k8s.io/k8s.mirror.nju.edu.cn/ manifests/kubeStateMetrics-deployment.yaml
sed -i s#grafana/grafana:12.0.1#swr.cn-north-4.myhuaweicloud.com/ddn-k8s/docker.io/grafana/grafana:12.0.1#  manifests/grafana-deployment.yaml

#创建组件
kubectl apply -f manifests/
