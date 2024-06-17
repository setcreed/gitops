# 使用sealos 快速安装

# 安装sealos工具
VERSION=`curl -s https://api.github.com/repos/labring/sealos/releases/latest | grep -oE '"tag_name": "[^"]+"' | head -n1 | cut -d'"' -f4`
curl -sfL https://mirror.ghproxy.com/https://raw.githubusercontent.com/labring/sealos/main/scripts/install.sh | PROXY_PREFIX=https://mirror.ghproxy.com sh -s ${VERSION} labring/sealos

# 安装k8s测试集群
sealos run registry.cn-shanghai.aliyuncs.com/labring/kubernetes:v1.27.7 \
          registry.cn-shanghai.aliyuncs.com/labring/helm:v3.14.1 registry.cn-shanghai.aliyuncs.com/labring/calico:3.26.4 \
          --masters 192.168.2.61 --nodes 192.168.2.62,192.168.2.63 -p 123

# kubectl自动补全
echo "source <(kubectl completion bash)" >> ~/.bashrc
source ~/.bashrc

# 去除污点
kubectl describe nodes master | grep taint
kubectl taint nodes master node-role.kubernetes.io/control-plane:NoSchedule-
kubectl taint nodes master node-role.kubernetes.io/master:NoSchedule-

# 安装一些应用
sealos run registry.cn-shanghai.aliyuncs.com/labring/metallb:v0.14.4
sealos run registry.cn-shanghai.aliyuncs.com/labring/openebs:v3.10.0
sealos run registry.cn-shanghai.aliyuncs.com/labring/ingress-nginx:v1.9.6

# metallb 配置layer2模式
cat <<-EOF > layer.yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: default
  namespace: metallb-system
spec:
  addresses:
  # 可分配的 IP 地址,可以指定多个，包括 ipv4、ipv6
    - 192.168.2.161-192.168.2.165
  autoAssign: true

---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: default
  namespace: metallb-system
spec:
  ipAddressPools:
  - default
EOF

kubectl apply -f layer.yaml



