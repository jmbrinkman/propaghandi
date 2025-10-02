import functions_framework
import json
import uuid
import os

from google.cloud import storage

def upload_json_to_gcs(bucket_name: str, json_data: dict, destination_blob_name: str):
    """
    Uploads a Python dictionary as a JSON file to a GCS bucket.

    Args:
        bucket_name (str): The name of your GCS bucket.
        json_data (dict): The Python dictionary to upload as JSON.
        destination_blob_name (str): The desired path and filename in the bucket
                                     (e.g., 'data/my_file.json').
    """
    try:
        # 1. Instantiate the Google Cloud Storage client
        storage_client = storage.Client()

        # 2. Get the target bucket
        bucket = storage_client.bucket(bucket_name)

        # 3. Define the blob (i.e., the file)
        blob = bucket.blob(destination_blob_name)

        # 4. Convert the dictionary to a JSON string and upload it
        #    Specifying the content type is a good practice.
        blob.upload_from_string(
            data=json.dumps(json_data, indent=4),
            content_type='application/json'
        )

        print(
            f"Successfully uploaded JSON object to gs://{bucket_name}/{destination_blob_name}"
        )

    except Exception as e:
        print(f"An error occurred: {e}")

@functions_framework.http
def innoreader_handler(request):
    json_data = request.get_json(force=True)
    bucket_name = os.environ.get("POSTS_BUCKET_NAME")
    output_file = f"{uuid.uuid4()}.json" # Use f-string
    result =upload_json_to_gcs(bucket_name, json_data, output_file)
    return result,200
