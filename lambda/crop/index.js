const {
  S3Client,
  GetObjectCommand,
  PutObjectCommand,
} = require("@aws-sdk/client-s3");

const sharp = require("sharp");

const s3 = new S3Client({});

const OUTPUT_SIZE = 40;
const PROCESSED_PREFIX = "processed/";

exports.handler = async (event) => {
  for (const record of event.Records) {
    const message = JSON.parse(record.body);

    for (const s3Record of message.Records) {
      const bucket = s3Record.s3.bucket.name;

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
        `${PROCESSED_PREFIX}${fileName}.png`;

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
  }

  return {
    statusCode: 200,
    body: "Imagen procesada correctamente",
  };
};