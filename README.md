# Jenkinsfile
Jenkinsfile es un archivo de código groovy que se puede ejecutar como Pipeline con Jenkins.
Este pipeline cuenta con 4 stages:

### Git
Se encarga de clonar el repositorio donde se encuentra la aplicación utilizando el branch que se indique al momento de ejecución. 

### Build Docker Images
En este stage se buildean los Dockerfile de las aplicaciones taggeandolos con el número de build del pipeline.

### Push Images
En Push Images se pushean las imagenes de docker al hub https://hub.docker.com/repository/docker/jnsalvatierra/challenge-infra/general

### Deploy
Este stage solo puede avanzar si el usuario administrador aprueba el despliegue manualmente.
Luego de ser aprobado se forwardea el servicio de ArgoCD, se logea y kustomiza las aplicaciones de ArgoCD para que cada deployment utilice la imagen buildeada en el stage Build Docker Images.

# Manifiestos de ArgoCD

En el directorio argocd se encuentran los manifiestos para desplegar las 5 aplicaciones en ArgoCD (redis, postgre, worker, result y vote). Cada uno de estos manifiestos toma la kustomizacion del respectivo directorio de su app.

# Manifiestos de Kubernetes

En el raiz del repositorio se encuentran los directorios con los manifiestos de cada servicio.

### database
Base de datos postgre con manifiestos de statefulset y servicio.

### redis
Base de datos redis con manifiestos de statefulset y servicio.

### result
Manifiestos de deployment, hpa, kustomization y servicio.

### vote
Manifiestos de deployment, hpa, kustomization y servicio.

### worker
Manifiestos de deployment, hpa y kustomization.

# install_argocd.sh

Este archivo es un script bash para ejecutarse en linux. 
* Instala ArgoCD en el cluster de k8s local.
* Clona éste repositorio y los manifiestos del directorio argocd para que se inicien las aplicaciones en ArgoCD.
* Cambia la contrañsea del usuario Admin de Argocd y forwardea el servicio para poder utilizarlo.
