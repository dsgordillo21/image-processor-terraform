const {
  S3Client,
  PutObjectCommand,
} = require("@aws-sdk/client-s3");

const { randomUUID } = require("crypto");

const s3 = new S3Client({});

const S3_BUCKET = process.env.S3_BUCKET;
const UPLOAD_PREFIX = process.env.UPLOAD_PREFIX || "uploads/";

exports.handler = async (event) => {
  try {
    if (!event.body) {
      return response(400, {
        message: "No se recibió ninguna imagen",
      });
    }

    const contentType =
      event.headers?.["content-type"] ||
      event.headers?.["Content-Type"] ||
      "application/octet-stream";

    if (!contentType.startsWith("image/")) {
      return response(400, {
        message: "El archivo enviado debe ser una imagen",
      });
    }

    const imageBuffer = event.isBase64Encoded
      ? Buffer.from(event.body, "base64")
      : Buffer.from(event.body);

    const originalName =
      event.headers?.["x-file-name"] ||
      event.headers?.["X-File-Name"] ||
      `image-${randomUUID()}`;

    const safeFileName = originalName.replace(
      /[^a-zA-Z0-9._-]/g,
      "_"
    );

    const objectKey =
      `${UPLOAD_PREFIX}${randomUUID()}-${safeFileName}`;

    await s3.send(
      new PutObjectCommand({
        Bucket: S3_BUCKET,
        Key: objectKey,
        Body: imageBuffer,
        ContentType: contentType,
      })
    );

    console.log(`Imagen guardada en: ${objectKey}`);

    return response(201, {
      message: "Imagen subida correctamente",
      key: objectKey,
    });
  } catch (error) {
    console.error("Error al subir la imagen:", error);

    return response(500, {
      message: "Error al subir la imagen",
    });
  }
};

function response(statusCode, body) {
  return {
    statusCode,
    headers: {
      "content-type": "application/json",
    },
    body: JSON.stringify(body),
  };
}