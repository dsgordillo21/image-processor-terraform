# Image Processor - Terraform AWS

## Integrantes

- Diego Gordillo Saona
- Cristhian Villena Flores
- Jesus Quinde Rojas
- Jhonatan Rios Iparraguirre
- Joel Leon Poveda

Proyecto de Infraestructura como Código (IaC) desarrollado con Terraform para desplegar una arquitectura de procesamiento de imágenes en AWS.

## Arquitectura

La solución utiliza los siguientes servicios principales:

- Amazon API Gateway
- AWS Lambda
- Amazon S3
- Amazon SQS
- Amazon VPC
- AWS IAM
- Amazon CloudWatch

## Entornos

La arquitectura debe poder desplegarse en:

- DEV
- QA
- PROD

## Región

Los recursos se desplegarán en:

```text
us-east-1
```

## Estructura del proyecto

```text
image-processor-terraform/
├── lambda/
│   ├── upload/
│   └── crop/
├── terraform/
├── .gitignore
└── README.md
```

## Requisitos

- Terraform
- AWS CLI
- Git
- Acceso a AWS mediante IAM Identity Center