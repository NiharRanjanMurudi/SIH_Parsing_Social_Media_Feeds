from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
import os

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Directory setup for files
IMAGE_DIR = 'static/images'
TEXT_DIR = 'static/tweet_texts'

@app.route('/process_instagram', methods=['POST'])
def process_instagram():
    instagram_url = request.form.get('instagram_url')
    # Simulate processing and generate file paths
    response = {
        'message': 'Processed Instagram post',
        'image_path': 'image.jpg',
        'text_path': 'text.txt',
        'text': 'Sample Instagram text',
        'sentiment': 'positive'
    }
    return jsonify(response)

@app.route('/process_tweet', methods=['POST'])
def process_tweet():
    tweet_url = request.form.get('profile_url')
    # Simulate processing and generate file paths
    response = {
        'message': 'Processed Tweet profile',
        'image_path': 'tweet_image.jpg',
        'text_path': 'tweet_text.txt',
        'text': 'Sample Tweet text',
        'sentiment': 'neutral'
    }
    return jsonify(response)

@app.route('/download_image/<filename>', methods=['GET'])
def download_image(filename):
    return send_from_directory(IMAGE_DIR, filename)

@app.route('/download_text/<filename>', methods=['GET'])
def download_text(filename):
    return send_from_directory(TEXT_DIR, filename)

if __name__ == '__main__':
    # Use 0.0.0.0 to make the server externally visible
    app.run(host='0.0.0.0', port=5000, debug=True)
