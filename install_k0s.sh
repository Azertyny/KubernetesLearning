#!/usr/bin/bash

# Variables #

# Functions ###################################################

install_k0s(){
  curl -sSf https://get.k0s.sh | sudo sh
  # TODO: Add path /usr/local/bin to secure path in soduers:  Defaults    secure_path = /sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin
  sudo /usr/local/bin/k0s install controller --single
  sudo /usr/local/bin/k0s start
}

install_kubectl(){
  # To adapt for ARM:
  #curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
  
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  mkdir /home/vagrant/.k0s
  chown vagrant:vagrant -R /home/vagrant/.k0s
  sudo cat /var/lib/k0s/pki/admin.conf > /home/vagrant/.k0s/kubeconfig
  chown vagrant:vagrant -R /home/vagrant/.k0s
  chmod 600 -R /home/vagrant/.k0s/kubeconfig
  export KUBECONFIG="/home/vagrant/.k0s/kubeconfig"
}


wait_api() {
    while [[ "$(curl -k --output /dev/null --silent -w ''%{http_code}'' https://127.0.0.1:6443)" != "401" ]];do
      printf '.';
      sleep 1;
    done
}

wait_ready(){
  kubectl wait --for='jsonpath={.status.conditions[?(@.type=="Ready")].status}=True' nodes k0s1
}


install_tooling(){
  wget https://github.com/jonmosco/kube-ps1/archive/refs/tags/v0.9.0.tar.gz 
  tar xzvf v0.9.0.tar.gz 
  cp kube-ps1-0.9.0/kube-ps1.sh /usr/local/bin/
  chmod +x /usr/local/bin/kube-ps1.sh
  curl -sL https://github.com/ahmetb/kubectx/releases/download/v0.9.5/kubens -o /usr/local/bin/kubens && sudo chmod +x /usr/local/bin/kubens
  curl -sL https://github.com/ahmetb/kubectx/releases/download/v0.9.5/kubectx -o /usr/local/bin/kubectx && sudo chmod +x /usr/local/bin/kubectx

  #wget https://github.com/derailed/k9s/releases/download/v0.32.5/k9s_linux_amd64.deb && apt install ./k9s_linux_amd64.deb && rm k9s_linux_amd64.deb
  wget https://github.com/derailed/k9s/releases/download/v0.50.9/k9s_linux_arm64.rpm && rpm -i ./k9s_linux_arm64.rpm && rm k9s_linux_arm64.rpm
  apt-get install bash-completion
  echo "source <(kubectl completion bash)" >> ~/.bashrc

}

# Let's Go !! #################################################

install_k0s

wait_api

install_kubectl

wait_ready

kubectl get nodes

#install_tooling
