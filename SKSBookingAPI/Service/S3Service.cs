using Amazon.Runtime;
using Amazon.S3.Model;
using Amazon.S3;
using System.Diagnostics;

namespace SKSBookingAPI.Service {
    // Nemmere organisering af billeder
    public enum ImageDirectoryType {
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
                ServiceURL = "https://7edebe7b5106f3bceb95ecd71d962f10.r2.cloudflarestorage.com/sks",
                ForcePathStyle = true
            };
            _s3Client = new AmazonS3Client(credentials, config);
        }

        // Upload a billedefil til bucket
        public async Task<string> UploadToS3(Stream fileStream, string uid, ImageDirectoryType type) {
            var request = new PutObjectRequest {
                InputStream = fileStream,
                BucketName = "sks",
                Key = $"{type}/{uid}.png",
                DisablePayloadSigning = true
            };

            var response = await _s3Client.PutObjectAsync(request);

            if (response.HttpStatusCode != System.Net.HttpStatusCode.OK) {
                throw new AmazonS3Exception($"Error uploading file to S3. HTTP Status Code: {response.HttpStatusCode}");
            }

            // Domæne giver CORS-fejl på web, virker på andre platforme
            //var imageUrl = $"https://sks.mercantec.tech/sks/{type}/{uid}.png"; 

            var imageUrl = $"https://sks.magsapi.com/sks/{type}/{uid}.png"; // Returneret URL til billede, der nu findes på serveren
            return imageUrl;
        }

        // Sletning af billedefil i bucket
        // Ingen adgang via vores nøgle, så det gør ingenting, men skulle gerne ellers være funktionelt
        public async Task DeleteFromS3(string url, ImageDirectoryType type) {
            string separator = type.ToString();
            int startIndex = url.IndexOf(separator);
            string imgKey = url.Substring(startIndex);

            try {
                var deleteObjectRequest = new DeleteObjectRequest {
                    BucketName = "sks",
                    Key = $"{imgKey}"
                };

                Console.WriteLine($"Attempting to delete at key {imgKey} ...");
                DeleteObjectResponse response = await _s3Client.DeleteObjectAsync(deleteObjectRequest);
                Console.WriteLine("Status: " + response.HttpStatusCode);
            }
            catch (AmazonS3Exception e) {
                Console.WriteLine("Error encountered on server. Message:'{0}' when deleting an object", e.Message);
            }
            catch (Exception e) {
                Console.WriteLine("Unknown encountered on server. Message:'{0}' when deleting an object", e.Message);
            }
        }
    }
}
