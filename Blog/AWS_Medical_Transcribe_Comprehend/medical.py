##############################################
# AWS Transcribe + Comprehend Medical
# Multi-file pipeline with automatic audio conversion
# Handles WAV, MP3, M4A from S3
# Saves JSON/CSV per job + master CSV to S3
##############################################

import boto3
import time
import json
import csv
import io
from pydub import AudioSegment

# -----------------------------
# Step 0: Configuration
# -----------------------------
input_bucket = "earp-medical-audio-input"       # Input S3 bucket with audio files
output_bucket = "earp-medical-output"          # Transcribe output bucket
results_bucket = "earp-medical-results-bucket"   # Bucket for JSON/CSV results
region = "us-east-1"

# Initialize AWS clients
s3 = boto3.client('s3', region_name=region)
transcribe = boto3.client('transcribe', region_name=region)
comprehend = boto3.client('comprehendmedical', region_name=region)

# -----------------------------
# Step 1: List all audio files in S3 input bucket
# -----------------------------
s3_objects = s3.list_objects_v2(Bucket=input_bucket)
audio_files = [obj['Key'] for obj in s3_objects.get('Contents', []) if obj['Key'].endswith(('.wav', '.mp3', '.m4a'))]

if not audio_files:
    raise Exception(f"No audio files found in bucket {input_bucket}")

print(f"Found {len(audio_files)} audio file(s) in {input_bucket}: {audio_files}")

# -----------------------------
# Step 2: Prepare master CSV
# -----------------------------
master_csv = "master_entities.csv"
with open(master_csv, "w", newline="") as f_master:
    writer_master = csv.writer(f_master)
    writer_master.writerow(["JobName", "AudioFile", "Text", "Category", "Type", "Score"])

# -----------------------------
# Step 3: Audio conversion function
# -----------------------------
def convert_to_wav(s3_client, bucket, key):
    """Download MP3/M4A from S3, convert to WAV in memory, return BytesIO"""
    obj = s3_client.get_object(Bucket=bucket, Key=key)
    audio_bytes = obj['Body'].read()
    ext = key.split('.')[-1].lower()
    audio = AudioSegment.from_file(io.BytesIO(audio_bytes), format=ext)
    wav_io = io.BytesIO()
    audio.export(wav_io, format="wav")
    wav_io.seek(0)
    return wav_io

# -----------------------------
# Step 4: Process each audio file
# -----------------------------
for audio_file in audio_files:
    ext = audio_file.split('.')[-1].lower()

    # Convert to WAV if necessary
    if ext in ['mp3', 'm4a']:
        print(f"Converting {audio_file} to WAV for Transcribe...")
        wav_io = convert_to_wav(s3, input_bucket, audio_file)
        temp_wav_key = f"tmp/{audio_file.split('.')[0]}.wav"
        s3.upload_fileobj(wav_io, input_bucket, temp_wav_key)
        media_uri = f"s3://{input_bucket}/{temp_wav_key}"
        media_format = "wav"
    else:
        media_uri = f"s3://{input_bucket}/{audio_file}"
        media_format = ext

    # Start Transcribe Medical Job
    job_name = f"job-{int(time.time())}"
    transcribe.start_medical_transcription_job(
        MedicalTranscriptionJobName=job_name,
        LanguageCode="en-US",
        MediaFormat=media_format,
        Media={'MediaFileUri': media_uri},
        OutputBucketName=output_bucket,
        Specialty="PRIMARYCARE",
        Type="DICTATION"
    )
    print(f"\nTranscribe job started: {job_name} for {audio_file}")

    # Wait for completion
    while True:
        status = transcribe.get_medical_transcription_job(MedicalTranscriptionJobName=job_name)
        job_status = status['MedicalTranscriptionJob']['TranscriptionJobStatus']
        if job_status in ['COMPLETED', 'FAILED']:
            break
        print("Waiting for job to complete...")
        time.sleep(10)

    if job_status == 'FAILED':
        print(f"Transcription failed for {audio_file}")
        continue

    print(f"Transcription completed: {job_name}")

    # Fetch latest transcript from S3 output bucket
    objects = s3.list_objects_v2(Bucket=output_bucket)
    latest_obj = sorted(objects['Contents'], key=lambda x: x['LastModified'], reverse=True)[0]
    object_key = latest_obj['Key']

    response = s3.get_object(Bucket=output_bucket, Key=object_key)
    data = json.loads(response['Body'].read())
    transcript_text = data['results']['transcripts'][0]['transcript']
    print(f"Transcript for {audio_file}:\n{transcript_text}")

    # Send transcript to Comprehend Medical
    cm_response = comprehend.detect_entities_v2(Text=transcript_text)

    # -----------------------------
    # Save individual JSON
    # -----------------------------
    json_filename = f"{job_name}_entities.json"
    with open(json_filename, "w") as f_json:
        json.dump(cm_response, f_json, indent=4)
    s3.upload_file(json_filename, results_bucket, json_filename)
    print(f"Uploaded JSON to s3://{results_bucket}/{json_filename}")

    # -----------------------------
    # Save individual CSV
    # -----------------------------
    csv_filename = f"{job_name}_entities.csv"
    with open(csv_filename, "w", newline="") as f_csv:
        writer_csv = csv.writer(f_csv)
        writer_csv.writerow(["Text", "Category", "Type", "Score"])
        for e in cm_response["Entities"]:
            writer_csv.writerow([e["Text"], e["Category"], e["Type"], e["Score"]])
    s3.upload_file(csv_filename, results_bucket, csv_filename)
    print(f"Uploaded CSV to s3://{results_bucket}/{csv_filename}")

    # -----------------------------
    # Append to master CSV
    # -----------------------------
    with open(master_csv, "a", newline="") as f_master:
        writer_master = csv.writer(f_master)
        for e in cm_response["Entities"]:
            writer_master.writerow([job_name, audio_file, e["Text"], e["Category"], e["Type"], e["Score"]])

# -----------------------------
# Step 5: Upload master CSV to S3
# -----------------------------
s3.upload_file(master_csv, results_bucket, f"master_{int(time.time())}_entities.csv")
print(f"\nMaster CSV uploaded to s3://{results_bucket}/master_{int(time.time())}_entities.csv")