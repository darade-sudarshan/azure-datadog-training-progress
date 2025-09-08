from flask import Flask, render_template, jsonify
import os
from datetime import datetime

app = Flask(__name__)

@app.route('/')
def home():
    return render_template('index.html', 
                         title='Flask Docker App',
                         timestamp=datetime.now().strftime('%Y-%m-%d %H:%M:%S'))

@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'version': '1.0.0'
    })

@app.route('/api/info')
def info():
    return jsonify({
        'app': 'Flask Docker Sample',
        'version': '1.0.0',
        'python_version': os.sys.version,
        'environment': os.environ.get('FLASK_ENV', 'production')
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)