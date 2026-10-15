// Q1. Películas por década
MATCH (m:Movie)
WHERE m.released >= 1990 AND m.released <= 1999
RETURN m.title AS titulo, m.released AS anio, m.tagline AS lema
ORDER BY anio ASC, titulo ASC

// Q2. Reparto de una película específica
MATCH (p:Person)-[r:ACTED_IN]->(m:Movie {title:"The Matrix"})
RETURN p.name AS actor, r.roles AS roles

// Q3. Películas con sus directores
MATCH (m:Movie)<-[:DIRECTED]-(p:Person)
RETURN m.title AS pelicula, collect(p.name) AS directores
ORDER BY pelicula

// Q4. Actores nacidos después de 1965
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WHERE p.born > 1965
RETURN p.name AS nombre, p.born AS anio_nacimiento, count(m) AS cantidad_peliculas
ORDER BY cantidad_peliculas DESC

// Q5. Colaboradores de un actor
MATCH (keanu:Person {name: "Keanu Reeves"})-[:ACTED_IN]->(m:Movie)<-[:ACTED_IN]-(colaborador:Person)
WHERE colaborador <> keanu
RETURN colaborador.name AS colaborador, collect(m.title) AS peliculas

// Q6. Personas con múltiples funciones
MATCH (p:Person)-[r]->(m:Movie)
WHERE type(r) IN ["ACTED_IN", "DIRECTED", "PRODUCED", "WROTE"]
WITH p, collect(DISTINCT type(r)) AS tipos_participacion, count(DISTINCT m) AS cantidad_peliculas
WHERE size(tipos_participacion) >= 2
RETURN p.name AS persona, tipos_participacion, cantidad_peliculas
ORDER BY cantidad_peliculas DESC

// Q7. Películas con reparto amplio
MATCH (m:Movie)<-[:ACTED_IN]-(p:Person)
WITH m, collect(p.name) AS actores, count(p) AS cantidad_actores
WHERE cantidad_actores >= 5
RETURN m.title AS pelicula, m.released AS anio, cantidad_actores, actores
ORDER BY cantidad_actores DESC

// Q8. Relación entre usuarios que siguen y reseñas
MATCH (seguidor:Person)-[:FOLLOWS]->(seguido:Person)-[r:REVIEWED]->(m:Movie)
OPTIONAL MATCH (seguidor)-[r2:REVIEWED]->(m)
RETURN seguidor.name AS seguidor, seguido.name AS seguido, m.title AS pelicula, r.rating AS calificacion, (r2 IS NOT NULL) AS seguidor_tambien_reseno
ORDER BY seguidor, pelicula

// Q9. Ruta más corta entre dos actores
MATCH p = shortestPath(
  (a:Person {name:"Keanu Reeves"})-[:ACTED_IN|DIRECTED|PRODUCED|WROTE*]-(b:Person {name:"Tom Hanks"})
)
RETURN [n IN nodes(p) | coalesce(n.title, n.name)] AS ruta, length(p) AS saltos

// Q10. Recomendación basada en personas seguidas
MATCH (james:Person {name:"James Thompson"})-[:FOLLOWS]->(seguido:Person)-[r:REVIEWED]->(m:Movie)
WHERE NOT EXISTS {
  MATCH (james)-[:REVIEWED]->(m)
}
RETURN m.title AS pelicula_recomendada, collect(DISTINCT seguido.name) AS recomendada_por, avg(r.rating) AS calificacion_promedio
ORDER BY calificacion_promedio DESC

// Q11. Actores con mayor red de colaboración
MATCH (a:Person)-[:ACTED_IN]->(:Movie)<-[:ACTED_IN]-(b:Person)
WHERE a <> b
RETURN a.name AS actor, count(DISTINCT b) AS tamano_red
ORDER BY tamano_red DESC
LIMIT 10

// Q12. Número de Bacon
MATCH (bacon:Person {name:"Kevin Bacon"})
MATCH p = shortestPath((bacon)-[:ACTED_IN*]-(persona:Person))
WHERE persona <> bacon
RETURN persona.name AS persona, length(p)/2 AS numero_bacon
ORDER BY numero_bacon ASC
LIMIT 20

// Q13. Personas que actuaron y dirigieron
MATCH (p:Person)-[:ACTED_IN]->(actuada:Movie)
MATCH (p)-[:DIRECTED]->(dirigida:Movie)
RETURN p.name AS persona, collect(DISTINCT actuada.title) AS peliculas_actuadas, collect(DISTINCT dirigida.title) AS peliculas_dirigidas

// Q14. Actores con múltiples roles en una misma película
MATCH (p:Person)-[r:ACTED_IN]->(m:Movie)
WHERE size(r.roles) > 1
RETURN p.name AS actor, m.title AS pelicula, r.roles AS roles, size(r.roles) AS cantidad_roles
ORDER BY cantidad_roles DESC

// Q15. Películas similares por actores compartidos
MATCH (m1:Movie)<-[:ACTED_IN]-(actor:Person)-[:ACTED_IN]->(m2:Movie)
WHERE m1.title < m2.title
WITH m1, m2, collect(DISTINCT actor.name) AS actores_compartidos
WHERE size(actores_compartidos) >= 2
RETURN m1.title AS pelicula1, m2.title AS pelicula2, actores_compartidos, size(actores_compartidos) AS puntaje_similitud
ORDER BY puntaje_similitud DESC

// Q16. Crear relaciones de colaboración
MATCH (a:Person)-[:ACTED_IN]->(m:Movie)<-[:ACTED_IN]-(b:Person)
WHERE a.name < b.name
WITH a, b, collect(m.title) AS peliculas, count(m) AS cantidad
MERGE (a)-[r:COLLABORATED_WITH]->(b)
SET r.movies = peliculas, r.count = cantidad

// Q17. Consultar las colaboraciones materializadas
MATCH (a:Person)-[r:COLLABORATED_WITH]->(b:Person)
RETURN a.name AS persona1, b.name AS persona2, r.count AS peliculas_compartidas, r.movies AS peliculas
ORDER BY peliculas_compartidas DESC
LIMIT 10

// Q18a. EXPLAIN y PROFILE de Q4 (dificultad media)
EXPLAIN
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WHERE p.born > 1965
RETURN p.name AS nombre, p.born AS anio_nacimiento, count(m) AS cantidad_peliculas
ORDER BY cantidad_peliculas DESC

PROFILE
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WHERE p.born > 1965
RETURN p.name AS nombre, p.born AS anio_nacimiento, count(m) AS cantidad_peliculas
ORDER BY cantidad_peliculas DESC

// Q18b. EXPLAIN y PROFILE de Q9 (difícil, con rutas)
EXPLAIN
MATCH p = shortestPath(
  (a:Person {name:"Keanu Reeves"})-[:ACTED_IN|DIRECTED|PRODUCED|WROTE*]-(b:Person {name:"Tom Hanks"})
)
RETURN [n IN nodes(p) | coalesce(n.title, n.name)] AS ruta, length(p) AS saltos

PROFILE
MATCH p = shortestPath(
  (a:Person {name:"Keanu Reeves"})-[:ACTED_IN|DIRECTED|PRODUCED|WROTE*]-(b:Person {name:"Tom Hanks"})
)
RETURN [n IN nodes(p) | coalesce(n.title, n.name)] AS ruta, length(p) AS saltos