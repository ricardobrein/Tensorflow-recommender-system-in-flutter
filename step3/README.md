# Fullstack recommendation system with docker, Flask y Flutter

El backend está listo. Puede comenzar a enviarle solicitudes para consultar recomendaciones de películas desde la aplicación Flutter.

La aplicación flutter para el frontend es bastante simple. Solo tiene un TextField que toma el ID de usuario y envía la solicitud (en la función) al backend que acaba de crear. Después de recibir la respuesta, la interfaz de usuario de la aplicación muestra las películas recomendadas en ListView.recommend()

Agregamos este código a la función `recommend()` en step3/frontend/lib/main.dart

`final response = await http.post(
  Uri.parse('http://' + _server + ':5000/recommend'),
  headers: <String, String>{
    'Content-Type': 'application/json',
  },
  body: jsonEncode(<String, String>{
    'user_id': _userIDController.text,
  }),
);`

# Actualizacion

Una vez que la aplicación recibe la respuesta del back-end, se actualiza la interfaz de usuario para mostrar la lista de películas recomendadas para el usuario especificado.

Agregue este código justo debajo del código anterior en `main.dart`:

`if (response.statusCode == 200) {
  return List<String>.from(jsonDecode(response.body)['movies']);
} else {
  throw Exception('Error response');
}`

### Ejecútalo

Ahora hay que probarlo: estando en VScode presiona F5 para ejecutar tu app de flutter segun la plataforma seleccionada, en mi caso es una plataforma WEB, pero con Flutter puede ser cualquiera que desees ;) y, a continuación, esperas a que se cargue la aplicación.

Escribes un ID de usuario (por ejemplo 15) y, a continuación, seleccione Recomendar.

[GIF](step3\gif-recommender.gif)


Y ahí lo tenemos... Genial no? Esto es solo el punto de Partida de lo que podria ser una Gran aplicación para recomendar peliculas en base a las ultimas que has visto, tus gustos o simplemente con una descripción de la pelicula puedes obtener todas las que encajan con ella, los limites a partir de aqui solo los pones tú.

Pero aún nos faltan un par de cosas...Vamos al [Paso 4](../step4/README.md)

