# Fullstack Recommendation system in flutter

## Paso 2: Crear el backend del motor de recomendaciones

Nota: Las instrucciones que se indican a continuación solo se aplican a un equipo Linux o a un Mac basado en Intel. Es posible adaptar los comandos a Windows con WSL (como es mi caso). En la documentacion de docker esta toda la información. En el caso de los Mac basados en Apple Silicon, no funcionará porque TensorFlow Serving es incompatible a partir de enero de 2024.

Ahora que entrenamos los modelos de recuperación y clasificación, puede implementarlos y crear un back-end.

Nota: Los modelos SavedModel previamente entrenados se proporcionan en las carpetas y para su comodidad en `step2/backend/retrieval/exported-retrieval` o `step2/backend/ranking/exported-ranking`

`docker run -t --rm -p 8501:8501 -p 8500:8500 -v "$(pwd)/:/models/" tensorflow/serving --model_config_file=/models/models.config`
cómo se deben implementar los dos modelos en TensorFlow Serving. Si entrena y descarga los modelos de Colab usted mismo, asegúrese de actualizar las rutas de acceso del modelo en el archivo.models.configmodels.config

Docker descarga automáticamente primero la imagen de TensorFlow Serving, lo que tarda un minuto. Después, debería comenzar TensorFlow Serving. El registro debe tener un aspecto similar al de este fragmento de código:

`2022-04-24 09:32:06.461702: I tensorflow_serving/model_servers/server_core.cc:465] Adding/updating models.
2022-04-24 09:32:06.461843: I tensorflow_serving/model_servers/server_core.cc:591]  (Re-)adding model: retrieval
2022-04-24 09:32:06.461907: I tensorflow_serving/model_servers/server_core.cc:591]  (Re-)adding model: ranking
2022-04-24 09:32:06.576920: I tensorflow_serving/core/basic_manager.cc:740] Successfully reserved resources to load servable {name: retrieval version: 123}
2022-04-24 09:32:06.576993: I tensorflow_serving/core/loader_harness.cc:66] Approving load for servable version {name: retrieval version: 123}
2022-04-24 09:32:06.577011: I tensorflow_serving/core/loader_harness.cc:74] Loading servable version {name: retrieval version: 123}
2022-04-24 09:32:06.577848: I external/org_tensorflow/tensorflow/cc/saved_model/reader.cc:38] Reading SavedModel from: /models/retrieval/exported-retrieval/123
2022-04-24 09:32:06.583809: I external/org_tensorflow/tensorflow/cc/saved_model/reader.cc:90] Reading meta graph with tags { serve }
2022-04-24 09:32:06.583879: I external/org_tensorflow/tensorflow/cc/saved_model/reader.cc:132] Reading SavedModel debug info (if present) from: /models/retrieval/exported-retrieval/123
2022-04-24 09:32:06.584970: I external/org_tensorflow/tensorflow/core/platform/cpu_feature_guard.cc:142] This TensorFlow binary is optimized with oneAPI Deep Neural Network Library (oneDNN) to use the following CPU instructions in performance-critical operations:  AVX2 FMA
To enable them in other operations, rebuild TensorFlow with the appropriate compiler flags.
2022-04-24 09:32:06.629900: I external/org_tensorflow/tensorflow/cc/saved_model/loader.cc:206] Restoring SavedModel bundle.
2022-04-24 09:32:06.634662: I external/org_tensorflow/tensorflow/core/platform/profile_utils/cpu_utils.cc:114] CPU Frequency: 2800000000 Hz
2022-04-24 09:32:06.672534: I external/org_tensorflow/tensorflow/cc/saved_model/loader.cc:190] Running initialization op on SavedModel bundle at path: /models/retrieval/exported-retrieval/123
2022-04-24 09:32:06.673629: I tensorflow_serving/core/basic_manager.cc:740] Successfully reserved resources to load servable {name: ranking version: 123}
2022-04-24 09:32:06.673765: I tensorflow_serving/core/loader_harness.cc:66] Approving load for servable version {name: ranking version: 123}
2022-04-24 09:32:06.673786: I tensorflow_serving/core/loader_harness.cc:74] Loading servable version {name: ranking version: 123}
2022-04-24 09:32:06.674731: I external/org_tensorflow/tensorflow/cc/saved_model/reader.cc:38] Reading SavedModel from: /models/ranking/exported-ranking/123
2022-04-24 09:32:06.683557: I external/org_tensorflow/tensorflow/cc/saved_model/reader.cc:90] Reading meta graph with tags { serve }
2022-04-24 09:32:06.683601: I external/org_tensorflow/tensorflow/cc/saved_model/reader.cc:132] Reading SavedModel debug info (if present) from: /models/ranking/exported-ranking/123
2022-04-24 09:32:06.688665: I external/org_tensorflow/tensorflow/cc/saved_model/loader.cc:277] SavedModel load for tags { serve }; Status: success: OK. Took 110815 microseconds.
2022-04-24 09:32:06.690019: I tensorflow_serving/servables/tensorflow/saved_model_warmup_util.cc:59] No warmup data file found at /models/retrieval/exported-retrieval/123/assets.extra/tf_serving_warmup_requests
2022-04-24 09:32:06.693025: I tensorflow_serving/core/loader_harness.cc:87] Successfully loaded servable version {name: retrieval version: 123}
2022-04-24 09:32:06.702594: I external/org_tensorflow/tensorflow/cc/saved_model/loader.cc:206] Restoring SavedModel bundle.
2022-04-24 09:32:06.745361: I external/org_tensorflow/tensorflow/cc/saved_model/loader.cc:190] Running initialization op on SavedModel bundle at path: /models/ranking/exported-ranking/123
2022-04-24 09:32:06.772363: I external/org_tensorflow/tensorflow/cc/saved_model/loader.cc:277] SavedModel load for tags { serve }; Status: success: OK. Took 97633 microseconds.
2022-04-24 09:32:06.774853: I tensorflow_serving/servables/tensorflow/saved_model_warmup_util.cc:59] No warmup data file found at /models/ranking/exported-ranking/123/assets.extra/tf_serving_warmup_requests
2022-04-24 09:32:06.777706: I tensorflow_serving/core/loader_harness.cc:87] Successfully loaded servable version {name: ranking version: 123}
2022-04-24 09:32:06.778969: I tensorflow_serving/model_servers/server_core.cc:486] Finished adding/updating models
2022-04-24 09:32:06.779030: I tensorflow_serving/model_servers/server.cc:367] Profiler service is enabled
2022-04-24 09:32:06.784217: I tensorflow_serving/model_servers/server.cc:393] Running gRPC ModelServer at 0.0.0.0:8500 ...
[warn] getaddrinfo: address family for nodename not supported
2022-04-24 09:32:06.785748: I tensorflow_serving/model_servers/server.cc:414] Exporting HTTP/REST API at:localhost:8501 ...
[evhttp_server.cc : 245] NET_LOG: Entering the event loop ...`


Nota: Después de iniciar la imagen de Docker de TensorFlow Serving, puedes visitar http://localhost:8501/v1/models/ranking/metadatos para inspeccionar los detalles de los tensores de entrada y salida. **En este codelab, reemplaza <MODEL_NAME> por retrieval o ranking**

**Creación de un nuevo punto de conexión**
Dado que TensorFlow Serving no admite el "encadenamiento" de varios modelos secuenciales, debes crear un nuevo servicio que conecte los modelos de recuperación y clasificación.

Agregue este código a la función en el archivo:get_recommendations()step2/backend/recommender.py

`user_id = request.get_json()["user_id"]
retrieval_request = json.dumps({"instances": [user_id]})
retrieval_response = requests.post(RETRIEVAL_URL, data=retrieval_request)
movie_candidates = retrieval_response.json()["predictions"][0]["output_2"]

ranking_queries = [
    {"user_id": u, "movie_title": m}
    for (u, m) in zip([user_id] * NUM_OF_CANDIDATES, movie_candidates)
]
ranking_request = json.dumps({"instances": ranking_queries})
ranking_response = requests.post(RANKING_URL, data=ranking_request)
movies_scores = list(np.squeeze(ranking_response.json()["predictions"]))
ranked_movies = [
    m[1] for m in sorted(list(zip(movies_scores, movie_candidates)), reverse=True)
]

return make_response(jsonify({"movies": ranked_movies}), 200)`

### Iniciar el servicio de Flask

**Ahora iniciamos el servicio Flask**

Ahora, En tu terminal, navegamos hasta la carpeta `.../step2/backend/`y ejecutamos lo siguiente: 

`FLASK_APP=recommender.py FLASK_ENV=development flask run`

Flask creará un nuevo endpoint dentro del contenedor yDeberías ver el registro de la siguiente ruta: http://localhost:5000/recommend

Esto es lo que se mostratara en la terminal de bash:

 * Serving Flask app 'recommender.py' (lazy loading)
 * Environment: development
 * Debug mode: on
 * Running on http://127.0.0.1:5000/ (Press CTRL+C to quit)
 * Restarting with stat
 * Debugger is active!
 * Debugger PIN: 705-382-264
127.0.0.1 - - [25/Apr/2022 19:44:47] "POST /recommend HTTP/1.1" 200 -


**Ahora, estando activo el endpoint, abrimos otra temrinal bash y haremos solicitudes de ejemplo al punto de conexión para asegurarse de que funciona como debe ser**

Por ejemplo:

`curl -X POST -H "Content-Type: application/json" -d '{"user_id":"15"}' http://localhost:5000/recommend`

El punto de conexión devolverá una lista de películas recomendadas para el usuario: 15


`{
  "movies": [
    "Evening Star, The (1996)",
    "Family Thing, A (1996)",
    "In Love and War (1996)",
    "Michael Collins (1996)",
    "Preacher's Wife, The (1996)",
    "Selena (1997)",
    "Spitfire Grill, The (1996)",
    "Associate, The (1996)",
    "To Gillian on Her 37th Birthday (1996)",
    "Beautician and the Beast, The (1997)"
  ]
}`

¡Eso es todo! Creamos conrrectamente un backend para recomendar películas en función de un ID de usuario.:D

Nota: En este caso implementamos los modelos de ranking y retrieval en una sola instancia de TensorFlow Serving. En la práctica, lo habitual implementarlos en clústeres independientes para administrar mejor la carga de trabajo de producción.

Con todo esto terminado, pasamos al Paso 3.