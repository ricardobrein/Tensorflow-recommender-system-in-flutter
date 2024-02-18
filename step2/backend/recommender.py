from flask import Flask, jsonify, make_response, request
from flask_cors import CORS
import json
import requests
import numpy as np

app = Flask(__name__)
CORS(app)

RETRIEVAL_URL = "http://localhost:8501/v1/models/retrieval:predict"
RANKING_URL = "http://localhost:8501/v1/models/ranking:predict"
NUM_OF_CANDIDATES = 10

@app.route("/recommend", methods=["POST"])
def get_recommendations():
    try:
        user_id = request.get_json()["user_id"]

        # Retrieve movie candidates for the user
        retrieval_request = json.dumps({"instances": [user_id]})
        retrieval_response = requests.post(RETRIEVAL_URL, data=retrieval_request)
        movie_candidates = retrieval_response.json()["predictions"][0]["output_2"]

        # Prepare queries for ranking model
        ranking_queries = [
            {"user_id": user_id, "movie_title": movie_title}
            for movie_title in movie_candidates
        ]
        
        # Get rankings for the movie candidates
        ranking_request = json.dumps({"instances": ranking_queries})
        ranking_response = requests.post(RANKING_URL, data=ranking_request)
        movies_scores = list(np.squeeze(ranking_response.json()["predictions"]))

        # Sort movies based on scores
        ranked_movies = [movie for _, movie in sorted(zip(movies_scores, movie_candidates), reverse=True)]
        
        return make_response(jsonify({"movies": ranked_movies[:NUM_OF_CANDIDATES]}), 200)
    
    except Exception as e:
        return make_response(jsonify({"error": str(e)}), 500)

if __name__ == "__main__":
    app.run(debug=True)
