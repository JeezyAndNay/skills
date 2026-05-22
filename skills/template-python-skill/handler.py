import os
from flask import Flask, request, jsonify

app = Flask(__name__)


@app.route('/run', methods=['POST'])
def run():
    data = request.get_json() or {}
    return jsonify({"success": True, "result": data})


if __name__ == '__main__':
    port = int(os.environ.get('PORT', '3001'))
    app.run(host='0.0.0.0', port=port)
