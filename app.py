from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "Hello from my DevOps portfolio project!"

@app.route("/health")
def health():
    return {"status": "healthy"}, 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
