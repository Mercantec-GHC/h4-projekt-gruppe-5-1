using Amazon.Runtime;
using Amazon.S3.Model;
using Amazon.S3;
using System.Diagnostics;

namespace SKSBookingAPI.Service {
    public enum ImageUploadType {
        profile,
        rental
    }

    public class S3Service {
        private readonly IAmazonS3 _s3Client;
        public string AccessKey { get; }
        public string SecretKey { get; }

        public S3Service(string accessKey, string secretKey) {
            AccessKey = accessKey;
            SecretKey = secretKey;

            var credentials = new BasicAWSCredentials(accessKey, secretKey);
            var config = new AmazonS3Config {
                ServiceURL = "https://lxhsmtgbazdlwjlwmxme.supabase.co/storage/v1/s3",
                //AuthenticationRegion = "eu-north-1",
                ForcePathStyle = true // Ensure the path style is used
            };
            _s3Client = new AmazonS3Client(credentials, config);
        }

        public async Task<string> UploadToS3(Stream fileStream, string uid, ImageUploadType type) {
            var request = new PutObjectRequest {
                InputStream = fileStream,
                BucketName = "sks-images",
                Key = uid,
                DisablePayloadSigning = true
            };

            var response = await _s3Client.PutObjectAsync(request);

            if (response.HttpStatusCode != System.Net.HttpStatusCode.OK) {
                throw new AmazonS3Exception($"Error uploading file to S3. HTTP Status Code: {response.HttpStatusCode}");
            }

            var imageUrl = $"https://lxhsmtgbazdlwjlwmxme.supabase.co/storage/v1/object/public/sks-images/{type}/{uid}";
            return imageUrl;
        }
    }
}
