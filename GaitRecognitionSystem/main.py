import os
import sys
from config import conf
from base64 import b64encode
import json
import io
from PIL import Image
import numpy as np
from flask_restx import Api, Resource, fields
from flask_cors import CORS

print(f"{conf=}")
WORK_PATH = conf['WORK_PATH']
sys.path.append(WORK_PATH)
os.environ["CUDA_VISIBLE_DEVICES"] = conf["CUDA_VISIBLE_DEVICES"]
# print(f"{os.environ['CUDA_VISIBLE_DEVICES']=}")


from util.register import allowed_file, get_video_frame, run_opengait, register
from werkzeug.utils import secure_filename
from flask_toastr import Toastr
from flask import Flask, render_template, request, Response, redirect, url_for, flash, jsonify, Blueprint

app = Flask(__name__)
web = Blueprint('web', __name__)
CORS(app)

# Initialize API with prefix to avoid conflicts
api = Api(app, version='1.0', 
          title='Gait Recognition API',
          description='API documentation for Gait Recognition System',
          prefix='/api',  # Add prefix
          doc='/swagger')    # Keep swagger UI path

toastr = Toastr(app)
app.secret_key = b'_5#y2L"F4Q8z\n\xec]/'

STATIC_TMP_FOLDER = conf["STATIC_TMP_FOLDER"]


register_parser = api.parser()
register_parser.add_argument('video', location='files',
                         type='FileStorage', required=True,
                         help='Video file for gait registration')
register_parser.add_argument('name', location='form', type=str, required=False,
                         help='Person name for registration')
register_parser.add_argument('name', location='args', type=str, required=False,
                         help='Person name for registration')
register_response = api.model('RegisterResponse', {
    'success': fields.Boolean(description='Operation success status'),
    'message': fields.String(description='Response message'),
    'data': fields.Nested(api.model('RegisterData', {
        'name': fields.String(description='Registered person name'),
        'filename': fields.String(description='Uploaded video filename')
    }))
})

recognize_parser = api.parser()
recognize_parser.add_argument('video', location='files',
                          type='FileStorage', required=True,
                          help='Video file for gait recognition')

recognition_response = api.model('RecognitionResponse', {
    'success': fields.Boolean(description='Operation success status'),
    'message': fields.String(description='Response message'),
    'data': fields.Raw(description='Response data containing results and images')
})

# Move web routes to blueprint
@web.route('/')
def index():
    return render_template('home.html')

@web.route('/upload', methods=['GET', 'POST'])
def upload_file():
    try:
        if request.method == 'POST':
            person_name = secure_filename(request.form['name'])
            vid_file = request.files['regFile']
            if person_name and vid_file and allowed_file(vid_file.filename):
                tag, message = register(person_name, vid_file)
            else:
                tag = False
                message = "Invalid name or video, please check and re-upload."

            status = 'success' if tag else 'warning'
            flash(message, status)

        return redirect(url_for('web.index'))

    except Exception as error:
        print(error)

@web.route('/recognition', methods=['GET', 'POST'])
def gait_recognition():
    try:
        if request.method == 'POST':
            tag = False
            person_name = ""
            vid_file = request.files['recFile']
            if vid_file and allowed_file(vid_file.filename):
                tag, message = register(person_name, vid_file)
            else:
                message = "Invalid video, please check and re-upload."

            if tag:
                tmp_image_path = os.path.sep.join([STATIC_TMP_FOLDER, "image"])
                cut_image_folder = os.path.sep.join([STATIC_TMP_FOLDER, "cut_img"])
                
                # Add directory existence check
                os.makedirs(tmp_image_path, exist_ok=True)
                os.makedirs(cut_image_folder, exist_ok=True)
                
                # Add error handling for empty directories
                try:
                    images = [str("/static/tmp/image/" + image) for image in sorted(os.listdir(tmp_image_path))[5:-5:3]]
                    cut_images = [str("/static/tmp/cut_img/" + image) for image in sorted(os.listdir(cut_image_folder))[5:-5:3]]
                except IndexError:
                    flash("Not enough frames processed", 'warning')
                    return redirect(url_for('web.index'))
                
                return render_template('video.html', images=images, cut_images=cut_images)
            else:
                print(message)
                flash(message, 'warning')

        return redirect(url_for('web.index'))

    except Exception as error:
        print(error)
        flash(f"An error occurred: {str(error)}", 'error')
        return redirect(url_for('web.index'))

@web.route("/get_similarity")
def get_similarity():
    if request.headers.get('accept') == 'text/event-stream':

        return Response(run_opengait(), mimetype='text/event-stream')

@web.route("/video_feed")
def video_feed():
    return Response(get_video_frame(), mimetype="multipart/x-mixed-replace; boundary=frame")

# Register blueprint with the app
app.register_blueprint(web)

# Update API namespace
ns = api.namespace(name = "gait",description='Gait Recognition operations')


@ns.route('/register')  
class GaitRegister(Resource):
    @ns.expect(register_parser)
    @ns.response(200, 'Success', register_response)
    @ns.response(400, 'Validation Error')
    @ns.response(500, 'Internal Server Error')
    def post(self):
        """Register a new person with their gait video"""
        try:
            if 'video' not in request.files:
                return {'success': False, 'message': 'No video file provided'}, 400
            
            vid_file = request.files['video']
            person_name = request.form.get('name', '').strip() or request.args.get('name', '').strip()
            print(f"{vid_file=}")
            print(f"{person_name=}")

            if not person_name:
                return {'success': False, 'message': 'Name is required'}, 400
                
            if not vid_file:
                return {'success': False, 'message': 'Video file is required'}, 400
                
            if not allowed_file(vid_file.filename):
                return {'success': False, 'message': 'Invalid video format'}, 400

            # Process registration
            tag, message = register(person_name, vid_file)
            
            if not tag:
                return {'success': False, 'message': f'Registration failed: {message}'}, 400

            return {
                'success': True,
                'message': 'Registration successful',
                'data': {
                    'name': person_name,
                    'filename': vid_file.filename
                }
            }

        except Exception as error:
            print(f"Registration error: {str(error)}")
            return {'success': False, 'message': f'Registration failed: {str(error)}'}, 500

@ns.route('/recognize')  
class GaitRecognize(Resource):
    @ns.expect(recognize_parser)
    @ns.response(200, 'Success', recognition_response)
    @ns.response(400, 'Validation Error')
    @ns.response(500, 'Internal Server Error')
    def post(self):
        """Recognize person from gait video"""
        try:
            if 'video' not in request.files:
                return {'success': False, 'message': 'No video file provided'}, 400

            vid_file = request.files['video']
            if not allowed_file(vid_file.filename):
                return {'success': False, 'message': 'Invalid video format'}, 400

            # Note: Passing empty string for name in recognition mode
            tag, message = register("", vid_file)
            
            if not tag:
                return {'success': False, 'message': message}, 400

            # Process images
            tmp_image_path = os.path.sep.join([STATIC_TMP_FOLDER, "image"])
            cut_image_folder = os.path.sep.join([STATIC_TMP_FOLDER, "cut_img"])
            
            os.makedirs(tmp_image_path, exist_ok=True)
            os.makedirs(cut_image_folder, exist_ok=True)

            # Convert images to base64
            def get_base64_images(folder_path):
                images = []
                for image_file in sorted(os.listdir(folder_path))[5:-5:3]:
                    img_path = os.path.join(folder_path, image_file)
                    with open(img_path, 'rb') as img_file:
                        encoded = b64encode(img_file.read()).decode('utf-8')
                        images.append(f"data:image/jpeg;base64,{encoded}")
                return images

            # Get similarity results
            similarity_results = list(run_opengait())
            # Parse the SSE data format and convert to proper JSON
            cleaned_results = {}
            for result in similarity_results:
                if result.startswith('data: '):
                    # Remove 'data: ' prefix and parse JSON string
                    json_str = result.replace('data: ', '').strip()
                    results_dict = json.loads(json_str)
                    # Format the data into a cleaner structure
                    for person, scores in results_dict.items():
                        cleaned_results[person] = {
                            'name': person.split('-')[0],  # Extract name without ID
                            'distance': round(scores['dist'], 3),
                            'similarity': round(scores['similarity'] * 100, 2)  # Convert to percentage
                }

            response_data = {
                'success': True,
                'data': {
                    'similarity_results': cleaned_results
                }
            }

            return jsonify(response_data)

        except Exception as error:
            return jsonify({
                'success': False,
                'message': str(error)
            }), 500

@ns.route('/stream')  # Changed from /stream_video
class StreamVideo(Resource):
    @ns.response(200, 'Success')
    @ns.response(500, 'Internal Server Error')
    def get(self):
        """Stream video feed with gait analysis"""
        try:
            def generate_frames():
                for frame in get_video_frame():
                    encoded_frame = b64encode(frame).decode('utf-8')
                    yield f"data: {encoded_frame}\n\n"

            return Response(generate_frames(), 
                          mimetype='text/event-stream')

        except Exception as error:
            return {'success': False, 'message': str(error)}, 500

api.add_namespace(ns)

if __name__ == '__main__':
    app.run(host="0.0.0.0", debug=False, port=5001)
