# Image Processor - Terraform AWS

## Integrantes

- Diego Gordillo Saona
- Cristhian Villena Flores
- Jesus Quinde Rojas
- Jhonatan Rios Iparraguirre
- Joel Leon Poveda

Proyecto desarrollado para el curso de Infraestructura como Código. Se utiliza Terraform para desplegar en AWS una infraestructura que permite recibir, almacenar y procesar imágenes.

## Arquitectura

Para el proyecto se utilizan los siguientes servicios de AWS:

- Amazon API Gateway
- AWS Lambda
- Amazon S3
- Amazon SQS
- Amazon VPC
- AWS IAM
- Amazon CloudWatch
- Amazon SNS

El funcionamiento general es el siguiente:

1. El cliente envía una imagen mediante `POST /upload`.
2. API Gateway recibe la petición.
3. Lambda Upload almacena la imagen en S3 dentro de `uploads/`.
4. S3 genera una notificación al detectar el nuevo archivo.
5. El evento es enviado a SQS.
6. Lambda Crop procesa el mensaje.
7. La imagen es redimensionada a 40x40 píxeles y se aplica una máscara circular.
8. El resultado se guarda en S3 dentro de `processed/`.

## Entornos

El proyecto puede desplegarse en tres ambientes:

- DEV
- QA
- PROD

Para separar cada ambiente se utilizan Terraform Workspaces.

Los recursos utilizan nombres de acuerdo con el ambiente seleccionado, por ejemplo:

- `image-processor-dev-...`
- `image-processor-qa-...`
- `image-processor-prod-...`

## Región

La infraestructura se despliega en la región `us-east-1`.

El acceso a AWS se realiza mediante AWS IAM Identity Center y perfiles configurados de forma local con AWS CLI.

## Estructura del proyecto

La estructura principal del repositorio es:

- `lambda/upload/`: código de la Lambda encargada de recibir y subir imágenes.
- `lambda/crop/`: código de la Lambda encargada de procesar las imágenes.
- `terraform/network.tf`: configuración de red.
- `terraform/storage.tf`: configuración del bucket S3.
- `terraform/queues.tf`: configuración de SQS y DLQ.
- `terraform/iam.tf`: roles y permisos IAM.
- `terraform/lambda-upload.tf`: configuración de Lambda Upload.
- `terraform/lambda-crop.tf`: configuración de Lambda Crop.
- `terraform/api-gateway.tf`: configuración de API Gateway.
- `terraform/monitoring.tf`: CloudWatch, alarmas y SNS.
- `terraform/outputs.tf`: salidas de Terraform.

## Requisitos

Antes de ejecutar el proyecto se debe tener instalado:

- Terraform
- AWS CLI v2
- Git
- Node.js
- npm
- Acceso a AWS mediante IAM Identity Center

Se puede comprobar la instalación con:

```powershell
terraform version
aws --version
git --version
node --version
npm.cmd --version
```

## Clonar el repositorio

```powershell
git clone https://github.com/dsgordillo21/image-processor-terraform.git
cd image-processor-terraform
```

## Configuración de AWS

El acceso a AWS se realiza mediante IAM Identity Center.

Para configurar AWS CLI por primera vez:

```powershell
aws configure sso
```

Cada integrante utiliza sus propios perfiles locales. Los nombres de los perfiles no están escritos directamente dentro del código Terraform.

Ejemplo para iniciar sesión en DEV:

```powershell
aws sso login --profile dgs-dev
```

Para comprobar el acceso:

```powershell
aws sts get-caller-identity --profile dgs-dev
```

## Preparación de Lambda Crop

Desde la raíz del proyecto:

```powershell
cd lambda\crop
npm.cmd ci
```

Luego se genera el ZIP que utilizará Terraform:

```powershell
Compress-Archive -Path index.js,package.json,node_modules -DestinationPath crop-lambda.zip -Force
```

## Preparación de Lambda Upload

Ingresar a la carpeta:

```powershell
cd ..\upload
npm.cmd ci
```

Generar el ZIP:

```powershell
Compress-Archive -Path index.js,package.json,node_modules -DestinationPath upload-lambda.zip -Force
```

Volver a la raíz del proyecto:

```powershell
cd ..\..
```

Los archivos ZIP se utilizan de forma local para desplegar las Lambdas y no se almacenan en el repositorio.

## Inicializar Terraform

Ingresar a la carpeta de Terraform:

```powershell
cd terraform
```

Inicializar el proyecto:

```powershell
terraform init
```

Comprobar el formato:

```powershell
terraform fmt -check
```

Validar la configuración:

```powershell
terraform validate
```

Si todo está correcto debe aparecer:

`Success! The configuration is valid.`

## Ambiente DEV

Crear el workspace la primera vez:

```powershell
terraform workspace new dev
```

Si ya existe:

```powershell
terraform workspace select dev
```

Configurar el perfil local:

```powershell
$env:TF_VAR_aws_profile="dgs-dev"
```

Comprobar el workspace actual:

```powershell
terraform workspace show
```

Revisar los recursos que serán creados:

```powershell
terraform plan
```

Después de revisar el plan se puede realizar el despliegue:

```powershell
terraform apply
```

Terraform solicitará confirmación antes de crear los recursos.

## Ambiente QA

Crear el workspace:

```powershell
terraform workspace new qa
```

Si ya existe:

```powershell
terraform workspace select qa
```

Configurar el perfil:

```powershell
$env:TF_VAR_aws_profile="dgs-qa"
```

Luego ejecutar:

```powershell
terraform plan
terraform apply
```

## Ambiente PROD

Crear el workspace:

```powershell
terraform workspace new prod
```

Si ya existe:

```powershell
terraform workspace select prod
```

Configurar el perfil:

```powershell
$env:TF_VAR_aws_profile="dgs-prod"
```

Luego ejecutar:

```powershell
terraform plan
terraform apply
```

## Prueba de carga de imágenes

Después del despliegue se debe obtener la URL de API Gateway desde la consola de AWS.

La ruta utilizada es:

`POST /upload`

Ejemplo de prueba desde PowerShell:


Si la petición se procesa correctamente, Lambda Upload almacenará la imagen en:

- `uploads/`

Luego S3 enviará el evento a SQS y Lambda Crop generará la versión procesada en:

- `processed/`

El archivo generado tendrá un nombre similar a:

- `prueba_circular.png`

## Monitoreo

Lambda Crop registra sus ejecuciones en CloudWatch Logs.

También se cuenta con:

- Dead Letter Queue
- Alarma de CloudWatch
- SNS Topic

La alarma permite detectar mensajes que lleguen a la DLQ durante el procesamiento.

## Eliminación de recursos

Después de obtener las evidencias del despliegue se deben eliminar los recursos para evitar costos adicionales.

Primero se selecciona el ambiente correspondiente.

Ejemplo para DEV:

```powershell
terraform workspace select dev
$env:TF_VAR_aws_profile="dgs-dev"
terraform destroy
```

Terraform solicitará confirmación antes de eliminar la infraestructura.

Al finalizar debe aparecer un mensaje similar a:

`Destroy complete!`

Para QA y PROD se realiza el mismo procedimiento utilizando sus respectivos workspaces y perfiles.

