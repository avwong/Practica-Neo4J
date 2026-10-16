# Práctica Neo4j: películas, personas y relaciones

Bases de Datos II, Tecnológico de Costa Rica, Campus Central Cartago.

Integrantes: Isaac Jiménez Blanco, Andrés Gabriel Padilla Robles y Alina Rodriguez Wong.

## Contenido del zip

| Archivo | Descripción |
|---|---|
| `practica_neo4j.cypher` | Consultas Q1 a Q18, cada una con un comentario superior con su número de ejercicio |
| `Informe_Neo4j.pdf` | Informe con explicación, resultados, capturas y análisis |
| `README.md` | Este archivo |
| Capturas de carga | Evidencia de la carga de la base de datos (también incluida en la sección 2 del informe) |

## Requisitos

- Docker instalado (se usó Docker en Windows).
- Neo4j 5 (se probó con la versión 5.26.32).
- El script de creación de datos de la práctica. Como el profesor no lo entregó, se usó un dataset alternativo basado en el conjunto público "Movie Graph" de Neo4j (ver sección 1 del informe).

## 1. Levantar Neo4j con Docker

```bash
docker run -d --name neo4j \
  -p 7474:7474 -p 7687:7687 \
  -v neo4j_data:/data \
  -e NEO4J_AUTH=neo4j/<contraseña> \
  neo4j:5
```

- `7474` es la interfaz web (Neo4j Browser) y `7687` es el protocolo Bolt.
- El volumen `neo4j_data` conserva los datos entre reinicios del contenedor.
- Reemplace `<contraseña>` por una contraseña de al menos 8 caracteres.

Abra `http://localhost:7474` e inicie sesión con el usuario `neo4j` y esa contraseña.

## 2. Cargar los datos

1. Abra el script de creación de datos (`practica_neo4j.cypher`) y péguelo en el editor de Neo4j Browser.
2. Ejecútelo completo.

## 3. Verificar la carga

Ejecute estas consultas, una por una:

```cypher
SHOW CONSTRAINTS;

MATCH (n)
RETURN labels(n) AS etiquetas, count(n) AS cantidad
ORDER BY cantidad DESC;

MATCH ()-[r]->()
RETURN type(r) AS relacion, count(r) AS cantidad
ORDER BY cantidad DESC;
```

Resultado esperado:

- Restricciones de unicidad sobre `Movie.title` y `Person.name`.
- 133 nodos `Person` y 38 nodos `Movie`.
- Relaciones: 172 `ACTED_IN`, 44 `DIRECTED`, 15 `PRODUCED`, 10 `WROTE`, 9 `REVIEWED` y 3 `FOLLOWS`.

## 4. Ejecutar las consultas

1. Abra `practica_neo4j.cypher`.
2. Copie y ejecute cada consulta por separado en Neo4j Browser, **en el orden en que aparecen** (el archivo no usa `;` para separarlas).
3. Ejecute Q1 a Q15 antes de Q16: Q16 modifica el grafo al crear las relaciones `:COLLABORATED_WITH` (362 relaciones, 724 propiedades).
4. Q17 consulta esas relaciones y Q18 contiene los pares `EXPLAIN` y `PROFILE` de Q4 y Q9. En Q18, ejecute cada `EXPLAIN` y cada `PROFILE` por separado.

Si necesita volver al estado inicial, puede eliminar las relaciones derivadas con:

```cypher
MATCH ()-[r:COLLABORATED_WITH]->() DELETE r;
```

## Notas

- Las consultas no dependen de identificadores internos generados por Neo4j.
- Q16 usa `MERGE` y la condición `a.name < b.name`, por lo que no crea relaciones duplicadas y se puede volver a ejecutar sin problema.
