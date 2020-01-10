#!/bin/bash

RED='\033[0;31m'
I=printf



 #=================================================================================================================================
 $I " ${RED}#1.Disable SELinux."
 #=================================================================================================================================

        setenforce 0
        sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

#=================================================================================================================================
 $I " ${RED}# 2. Enable the br_netfilter module for cluster communication."
#=================================================================================================================================

        modprobe br_netfilter
        echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables

#=================================================================================================================================
 $I " ${RED}# 3. Disable swap to prevent memory allocation issues."
#=================================================================================================================================

        swapoff -a
 #   vim /etc/fstab.orig  ->  Comment out the swap line. (There is most likely a cleaner way to do this.)
        sed -i '$ d' /etc/fstab
        echo "#/root/swap swap swap sw 0 0" >> /etc/fstab

#=================================================================================================================================
 $I " ${RED}# 4. Install the Docker prerequisites."
#=================================================================================================================================

        yum install -y yum-utils device-mapper-persistent-data lvm2 & sleep 60


#=================================================================================================================================
 $I " ${RED}#5. Add the Docker repo and install Docker."
#=================================================================================================================================

        yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        yum install -y docker-ce  

#=================================================================================================================================
 $I " ${RED}# 6. Conigure the Docker Cgroup Driver to systemd, enable and start Docker"
#=================================================================================================================================

        sed -i '/^ExecStart/ s/$/ --exec-opt native.cgroupdriver=systemd/' /usr/lib/systemd/system/docker.service
        systemctl daemon-reload
        systemctl start docker
        systemctl start docker

#=================================================================================================================================
 $I " ${RED}# 7. Add the Kubernetes repo."
#=================================================================================================================================

printf  "[kubernetes]\nname=Kubernetes\nbaseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64\nenabled=1\ngpgcheck=0\ngpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg\nhttps://packages.cloud.google.com/yum/doc/rpm-package-key.gpg" >> /etc/yum.repos.d/kubernetes.repo


#=================================================================================================================================
 $I " ${RED} 8. Install Kubernetes."
#=================================================================================================================================

    yum install -y kubelet kubeadm kubectl 

#=================================================================================================================================
 $I " ${RED}# 9 .Enable Kubernetes. The kubelet service will not start until you run kubeadm init."
#=================================================================================================================================

    systemctl enable kubelet



#confirmation of master node

        read -p "is this a master node? y or n?"  -r
                if [[ $REPLY =~ ^[Yy]$ ]]
                then
#=================================================================================================================================
 $I " ${RED}#10.a Initialize the cluster using the IP range for Flannel."
#=================================================================================================================================

        kubeadm init --pod-network-cidr=10.244.0.0/16

#=================================================================================================================================
 $I " ${RED}# 11.a Exit sudo and Copy the kubeadmin join command."
#=================================================================================================================================

#may need to exit here
#exit

        mkdir -p $HOME/.kube
        sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
        sudo chown $(id -u):$(id -g) $HOME/.kube/config

#=================================================================================================================================
 $I " ${RED}# 12.a Deploy Flannel."
#=================================================================================================================================

        kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml 



#Check the cluster state.

        kubectl get pods --all-namespaces


echo "==== !! COPY THE JOIN COMMAND ABOVE AND SAVE IT !! ===="
cat 

                fi

#confirmation if no display script is finished
 if [[ $REPLY =~ ^[Nn]$ ]]
  then

#=================================================================================================================================
 $I " ${RED}# 10.b Run the join command that you copied earlier froom the master node after kube finished installing (this command needs to be run as sudo), then check your nodes from the master."
#=================================================================================================================================

echo " example: kubeadm join 172.31.107.15:6443 --token 0zazre.1v8mwmxe2ueli6y6 \
    --discovery-token-ca-cert-hash sha256:20fc6be8f40c35033656bc52dfc7077b5c653baa33cdac6a0702c01ae43a0098"

        kubectl get nodes

#=================================================================================================================================
 $I " ${RED}# 11.b Print finished to let user know script is complete"
#=================================================================================================================================

        echo "finished"

                fi
