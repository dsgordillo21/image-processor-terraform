const {
  S3Client,
  GetObjectCommand,
  PutObjectCommand,
} = require("@aws-sdk/client-s3");

const sharp = require("sharp");

const s3 = new S3Client({});

const OUTPUT_SIZE = 40;
const S3_BUCKET = process.env.S3_BUCKET;
const PROCESSED_PREFIX = process.env.PROCESSED_PREFIX || "processed/";

exports.handler = async (event) => {
  const failures = [];

  for (const record of event.Records) {
    try {
      const message = JSON.parse(record.body);

      if (!Array.isArray(message.Records)) {
        throw new Error("El mensaje SQS no contiene registros S3");
      }

      for (const s3Record of message.Records) {
        const bucket =
          S3_BUCKET || s3Record.s3.bucket.name;

        const sourceKey = decodeURIComponent(
          s3Record.s3.object.key.replace(/\+/g, " ")
        );

        console.log(`Procesando imagen: ${sourceKey}`);

        const object = await s3.send(
          new GetObjectCommand({
            Bucket: bucket,
            Key: sourceKey,
          })
        );

        const imageBuffer = Buffer.from(
          await object.Body.transformToByteArray()
        );

        const circleMask = Buffer.from(`
          <svg width="${OUTPUT_SIZE}" height="${OUTPUT_SIZE}">
            <circle
              cx="${OUTPUT_SIZE / 2}"
              cy="${OUTPUT_SIZE / 2}"
              r="${OUTPUT_SIZE / 2}"
              fill="white"
            />
          </svg>
        `);

        const processedImage = await sharp(imageBuffer)
          .resize(OUTPUT_SIZE, OUTPUT_SIZE, {
            fit: "cover",
          })
          .composite([
            {
              input: circleMask,
              blend: "dest-in",
            },
          ])
          .png()
          .toBuffer();

        const fileName = sourceKey
          .replace(/^uploads\//, "")
          .replace(/\.[^/.]+$/, "");

        const destinationKey =
          `${PROCESSED_PREFIX}${fileName}_circular.png`;

        await s3.send(
          new PutObjectCommand({
            Bucket: bucket,
            Key: destinationKey,
            Body: processedImage,
            ContentType: "image/png",
          })
        );

        console.log(`Imagen guardada en: ${destinationKey}`);
      }
    } catch (error) {
      console.error(
        `Error procesando mensaje SQS ${record.messageId}:`,
        error
      );

      failures.push({
        itemIdentifier: record.messageId,
      });
    }
  }

  return {
    batchItemFailures: failures,
  };
};
