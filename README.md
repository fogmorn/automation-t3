# automation-t3
Тестовое задание по автоматизации.

## Дано
Необходимо создать три веб сервера: один FrontEnd и два BackEnd.  
На FrontEnd Веб страничка, запрашивающая ввести два числа, и кнопка «Посчитать».  
Веб сервера на NGINX или Apache, страничка на PHP и/или Python, может что-нибудь своё, главное результат.


## Задание
1. При нажатии кнопки «Посчитать», FrontEnd сервер должен через первый BackEnd посчитать сумму чисел, а через второй их перемножение и отобразить результат.
2. На страничке необходимо отобразить имена серверов, на которых осуществлялись вычисления, причем имя сервера должен сообщить именно BackEnd.


## Условия реализации
1. Запустить Docker образы из проекта [automation-t1](https://github.com/fogmorn/automation-t1) в Kubernetes.
2. Сделать по два пода на каждый бэкэнд.

## Решение

### Установка minikube
Был установлен minikube.
<details><summary>Запуск minikube</summary>
<p>

```Shell
  azureuser@s01:~$ minikube start
* minikube v1.24.0 on Ubuntu 20.04                                       
* Automatically selected the docker driver. Other choices: ssh, none  
* Starting control plane node minikube in cluster minikube
* Pulling base image ...                                                                                                                         
* Downloading Kubernetes v1.22.3 preload ...          
    > preloaded-images-k8s-v13-v1...: 501.73 MiB / 501.73 MiB  100.00% 307.33 M
    > gcr.io/k8s-minikube/kicbase: 355.78 MiB / 355.78 MiB  100.00% 21.56 MiB p
* Creating docker container (CPUs=2, Memory=2200MB) ...- E1114 06:56:42.883217    1658 network_create.go:85] failed to find free subnet for docker network minikube after 20 attempts: no free private network subnets found with given parameters (start: "192.168.57.0", step: 9, tries: 20)                                                                                                                                               
! Unable to create dedicated network, this might result in cluster IP change after restart: un-retryable: no free private network subnets found with given parameters (start: "192.168.57.0", step: 9, tries: 20)          
* Preparing Kubernetes v1.22.3 on Docker 20.10.8 ...
  - Generating certificates and keys ...                                                                                                        
  - Booting up control plane ...                                         
  - Configuring RBAC rules ...                                           
* Verifying Kubernetes components...          
  - Using image gcr.io/k8s-minikube/storage-provisioner:v5
* Enabled addons: storage-provisioner, default-storageclass             
* kubectl not found. If you need it, try: 'minikube kubectl -- get pods -A'
* Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

</p>
</details>

<details><summary>Интеграция minikube и docker</summary>
<p>

```Shell
minikube docker-env
eval $(minikube -p minikube docker-env)
```

</p>
</details>


<details><summary>Запуск minikube dashboard</summary>
<p>

```Shell
minikube dashboard
# Port forwarding from local pc to remote with minikube dashboard
ssh -f -N -L 46041:localhost:46041 azureuser@137.135.200.175
```

</p>
</details>

### Создание Docker образов
Так как в этой задаче не предполагается использование Docker-compose, то Docker файлы из проекта [automation-t1](https://github.com/fogmorn/automation-t1) были переделаны.
В Docker файлы было добавлено:
1. Настройка портов.
2. Запуск основной программы контейнера.
3. Копирование файлов сайта на BackEnd контейнеры.

<details><summary>Сборка образов</summary>
<p>

```Shell
docker build -t back1:6 -f back1.Dockerfile .
docker build -t back2:6 -f back2.Dockerfile .
docker build -t front1:6 -f front1.Dockerfile .
```

</p>
</details>


### Запуск Docker контейнеров в Kubernetes
Были созданы файлы Deployment, в которых описано имя пода, количество реплик, порты и образы для создания контейнера:
[front1](front1/front1-deployment.yml), [back1](back1/back1-deployment.yml), [back2](back2/back2-deployment.yml).

Также были созданы Service файлы для связи между подами: [front1](front1/front1-service.yml), [back1](back1/back1-service.yml), [back2](back2/back2-service.yml).

<details><summary>Запуск Docker контейнеров в K8s</summary>
<p>

```Shell
kubectl apply -f https://raw.githubusercontent.com/fogmorn/automation-t3/main/back2/back2-deployment.yml
kubectl apply -f https://raw.githubusercontent.com/fogmorn/automation-t3/main/back1/back1-deployment.yml
kubectl apply -f https://raw.githubusercontent.com/fogmorn/automation-t3/main/front1/front1-deployment.yml
kubectl apply -f https://raw.githubusercontent.com/fogmorn/automation-t3/main/back2/back2-service.yml
kubectl apply -f https://raw.githubusercontent.com/fogmorn/automation-t3/main/back1/back1-service.yml
kubectl apply -f https://raw.githubusercontent.com/fogmorn/automation-t3/main/front1/front1-service.yml
```

</p>
</details>

Посмотреть, что получилось, можно следующими командами (и также в dashboard):
```Shell
kubectl get deployments -o wide
kubectl get pods -o wide
kubectl get services -o wide
```

### Перенаправление портов
FrontEnd под запущен на порту 9080, а nginx в нем на порту 80.  
Команда для перенаправления 9080 порта сервера K8s на порт 80: 
```Shell
kubectl port-forward --address 0.0.0.0 front1-6cb967bb5d-q4pcj 9080:80
```

Теперь можно обратиться к FrontEnd по адресу http://<IP сервера>:9080 и отобразится веб страничка.

### Конечный результат
<details><summary>Веб страничка с вычислениями</summary>
  <img src="https://user-images.githubusercontent.com/49227124/147834396-0899b37f-9d1d-4a3b-935b-aebc7b9ff000.png" alt="Web_page_automation-t3"/>
</details>

<details><summary>Kubernetes Dashboard - Pods</summary>
  <img src="https://user-images.githubusercontent.com/49227124/147834489-67fda385-4331-4a74-94ca-d28874050506.png" alt="K8s_pods_list"/>
</details>

<details><summary>Kubernetes Dashboard - Deployments</summary>
  <img src="https://user-images.githubusercontent.com/49227124/147834480-7c8bc534-2f39-496a-be22-50238a7c1e41.png" alt="K8s_deployments_list"/>
</details>

<details><summary>Kubernetes Dashboard - Replicas</summary>
  <img src="https://user-images.githubusercontent.com/49227124/147834470-6769dcd5-912b-410f-8f94-c5300fb2e6bf.png" alt="K8s_replicas_list"/>
</details>


<details><summary>Kubernetes Dashboard - Services</summary>
  <img src="https://user-images.githubusercontent.com/49227124/147834463-9848f485-15c6-4bbf-87ef-7250144d4737.png" alt="K8s_services_list"/>
</details>
