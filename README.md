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

### Запуск Docker контейнеров в Kubernetes
Сборка Docker образов и их запуск в Kubernetes осуществляется с помощью утилита Werf.  
Файл [werf.yaml](werf.yaml) используется для сборки образов.  
Файлы в папке [.helm/templates](.helm/templates) используются для запуска контейнеров в Kubernetes.

Были созданы файлы Deployment, в которых описано имя пода, количество реплик, порты и образы для создания контейнера:
[front1](.helm/templates/front1-deployment.yaml), [back1](.helm/templates/back1-deployment.yaml), [back2](.helm/templates/back2-deployment.yaml). Также были созданы Service файлы для связи между подами: [front1](.helm/templates/front1-service.yaml), [back1](.helm/templates/back1-service.yaml), [back2](.helm/templates/back2-service.yaml).

<details><summary>Запуск утилиты Werf</summary>
<p>

```Shell
azureuser@s01:~/automation-t3$ werf converge --repo registry.example.com:80/automation-t3                                                          
Version: v1.2.53                                                                                                                                   
Using werf config render file: /tmp/werf-config-render-1990110385
<some lines skipped>
┌ ⛵ image back2                                                                                                                                 
│ ┌ Building stage back2/dockerfile                                                                                                               
│ │ back2/dockerfile  Sending build context to Docker daemon  43.01kB                                                                             
│ │ back2/dockerfile  Step 1/15 : FROM nanoninja/php-fpm:latest                                                                                  
│ │ back2/dockerfile   ---> 975daeead3d0                                                                                                         
│ │ back2/dockerfile  Step 2/15 : COPY ./back2/php-fpm.conf /usr/local/etc/                                                                       
│ │ back2/dockerfile   ---> Using cache
│ │ back2/dockerfile   ---> 8743ee13e16c
│ │ back2/dockerfile  Step 3/15 : COPY ./back2/site.conf /usr/local/etc/php-fpm.d/
│ │ back2/dockerfile   ---> Using cache
│ │ back2/dockerfile   ---> b161497edabb
│ │ back2/dockerfile  Step 4/15 : COPY ./site_static/multiply.php /var/www/html/site/
<some lines skipped>
│ │ ┌ Store stage into registry.example.com:80/automation-t3
│ │ └ Store stage into registry.example.com:80/automation-t3 (0.60 seconds)
│ ├ Info
│ │      name: registry.example.com:80/automation-t3:e6d15dc6b103b7be825f307dcf6f870b74d199d2a73176d04aa91950-1641665715991
│ │        id: 715ab520d3ec
│ │   created: 2022-01-08 18:15:15 +0000 UTC
│ │      size: 230.9 MiB
│ └ Building stage back2/dockerfile (33.49 seconds)
└ ⛵ image back2 (34.11 seconds)
<some lines skipped>
┌ Waiting for release resources to become ready                                                                                                   
│ ┌ Status progress                                                                                                                               
│ │ DEPLOYMENT                                                                        REPLICAS       AVAILABLE        UP-TO-DATE                 
│ │ back1                                                                             2/2            1                2                           
│ │ │   POD                            READY      RESTARTS       STATUS               ---                                                         
│ │ ├── 857d8cc657-5nz4x               0/1        0              ContainerCreating    Waiting for: available 1->2                                 
│ │ └── 857d8cc657-mkxl4               1/1        0              Running                                                                         
│ │ back2                                                                             2/2            2                2                           
│ │ │   POD                            READY      RESTARTS       STATUS                                                                           
│ │ ├── 57bb69b58f-kccpn               1/1        0              Running                                                                         
│ │ └── 57bb69b58f-shs9d               1/1        0              Running                                                                         
│ │ front1                                                                            1/1            0                1                           
│ │ │   POD                            READY      RESTARTS       STATUS               ---                                                         
│ │ └── 5b956ff4c5-8jzkb               0/1        0              ContainerCreating    Waiting for: available 0->1                                 
│ └ Status progress                                                                                                                               
│                                                                                                                                                 
│ ┌ Status progress                                                                                                                               
│ │ DEPLOYMENT                                                                        REPLICAS       AVAILABLE        UP-TO-DATE                 
│ │ back1                                                                             2/2            1->2             2                           
│ │ │   POD                            READY      RESTARTS       STATUS                                                                           
│ │ ├── 857d8cc657-5nz4x               1/1        0              ContainerCreating                                                               
│ │ │                                                            -> Running                                                                       
│ │ └── 857d8cc657-mkxl4               1/1        0              Running                                                                         
│ │ back2                                                                             2/2            2                2                           
│ │ │   POD                            READY      RESTARTS       STATUS                                                                          
│ │ ├── 57bb69b58f-kccpn               1/1        0              Running                                                                         
│ │ └── 57bb69b58f-shs9d               1/1        0              Running                                                                         
│ │ front1                                                                            1/1            0->1             1                           
│ │ │   POD                            READY      RESTARTS       STATUS                                                                           
│ │ └── 5b956ff4c5-8jzkb               1/1        0              ContainerCreating                                                               
│ │                                                              -> Running           
│ └ Status progress
└ Waiting for release resources to become ready (5.13 seconds)

Release "automation-t3" has been upgraded. Happy Helming!
NAME: automation-t3
LAST DEPLOYED: Sat Jan  8 17:02:38 2022
NAMESPACE: automation-t3
STATUS: deployed
REVISION: 3
TEST SUITE: None
Running time 7.02 seconds
```

</p>
</details>

<details><summary>Посмотреть, что получилось, можно следующей командой (и также в dashboard):</summary>
<p>

```Shell
azureuser@s01:~$ kubectl get all -n automation-t3                                                                                                  
NAME                          READY   STATUS    RESTARTS   AGE
pod/back1-857d8cc657-5nz4x    1/1     Running   0          22s                                                                                   
pod/back1-857d8cc657-mkxl4    1/1     Running   0          22s                                                                                   
pod/back2-57bb69b58f-kccpn    1/1     Running   0          22s                                                                                   
pod/back2-57bb69b58f-shs9d    1/1     Running   0          22s                                                                                   
pod/front1-5b956ff4c5-8jzkb   1/1     Running   0          21s                                                                                   
  
NAME             TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/back1    ClusterIP   10.110.189.203   <none>        9000/TCP   22s
service/back2    ClusterIP   10.97.9.129      <none>        9001/TCP   22s
service/front1   ClusterIP   10.104.231.86    <none>        80/TCP     22s
                                                                                                                                                 
NAME                     READY   UP-TO-DATE   AVAILABLE   AGE                                                                                     
deployment.apps/back1    2/2     2            2           22s                                                                                     
deployment.apps/back2    2/2     2            2           22s                                                                                     
deployment.apps/front1   1/1     1            1           22s            
                                                                         
NAME                                DESIRED   CURRENT   READY   AGE
replicaset.apps/back1-857d8cc657    2         2         2       22s                                                                               
replicaset.apps/back2-57bb69b58f    2         2         2       22s
replicaset.apps/front1-5b956ff4c5   1         1         1       22s
```

</p>
</details>

### Перенаправление портов
Команда для перенаправления 9080 порта сервера K8s на порт 80: 
```Shell
kubectl port-forward --address 0.0.0.0 pod/front1-8b494ffc6-v2kjq 9080:80 --namespace=automation-t3
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
