from fastapi import Depends, FastAPI, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from sqlalchemy.orm import Session

from .database import Base, engine, obtener_db
from .models import Libro, Usuario
from .schemas import (
    LibroRespuesta,
    TokenRespuesta,
    UsuarioLogin,
    UsuarioRegistro,
    UsuarioRespuesta,
)

from .security import (
    ALGORITHM,
    SECRET_KEY,
    crear_hash_password,
    crear_token_acceso,
    verificar_password,
)

Base.metadata.create_all(bind=engine)

LIBROS_INICIALES = [
    {
        "titulo": "Cien años de soledad",
        "autor": "Gabriel García Márquez",
        "genero": "Realismo mágico",
        "descripcion": "La historia de la familia Buendía a lo largo de varias generaciones en Macondo.",
        "anio": 1967,
    },
    {
        "titulo": "1984",
        "autor": "George Orwell",
        "genero": "Distopía",
        "descripcion": "Una sociedad vigilada por un régimen totalitario que controla la información y el pensamiento.",
        "anio": 1949,
    },
    {
        "titulo": "Orgullo y prejuicio",
        "autor": "Jane Austen",
        "genero": "Novela",
        "descripcion": "Una historia sobre relaciones, prejuicios sociales y crecimiento personal.",
        "anio": 1813,
    },
    {
        "titulo": "Don Quijote de la Mancha",
        "autor": "Miguel de Cervantes",
        "genero": "Clásico",
        "descripcion": "Las aventuras de un hidalgo que decide convertirse en caballero andante.",
        "anio": 1605,
    },
    {
        "titulo": "El principito",
        "autor": "Antoine de Saint-Exupéry",
        "genero": "Fábula",
        "descripcion": "Un relato sobre la amistad, la imaginación y la forma en que los adultos ven el mundo.",
        "anio": 1943,
    },
    {
        "titulo": "Rayuela",
        "autor": "Julio Cortázar",
        "genero": "Novela",
        "descripcion": "Una novela experimental sobre amor, identidad y búsqueda existencial.",
        "anio": 1963,
    },
    {
        "titulo": "Crónica de una muerte anunciada",
        "autor": "Gabriel García Márquez",
        "genero": "Novela",
        "descripcion": "La reconstrucción de un crimen conocido de antemano por todo un pueblo.",
        "anio": 1981,
    },
    {
        "titulo": "Fahrenheit 451",
        "autor": "Ray Bradbury",
        "genero": "Ciencia ficción",
        "descripcion": "Una sociedad futura donde los libros están prohibidos y los bomberos los destruyen.",
        "anio": 1953,
    },
    {
        "titulo": "La metamorfosis",
        "autor": "Franz Kafka",
        "genero": "Ficción",
        "descripcion": "Un hombre despierta transformado y debe enfrentar el rechazo de quienes lo rodean.",
        "anio": 1915,
    },
    {
        "titulo": "El retrato de Dorian Gray",
        "autor": "Oscar Wilde",
        "genero": "Gótico",
        "descripcion": "Un joven conserva su belleza mientras un retrato refleja las consecuencias de sus actos.",
        "anio": 1890,
    },
    {
        "titulo": "Matar a un ruiseñor",
        "autor": "Harper Lee",
        "genero": "Novela",
        "descripcion": "Una historia sobre justicia, racismo y empatía vista desde la infancia.",
        "anio": 1960,
    },
    {
        "titulo": "La sombra del viento",
        "autor": "Carlos Ruiz Zafón",
        "genero": "Misterio",
        "descripcion": "Un joven descubre un libro olvidado y se adentra en un misterio literario en Barcelona.",
        "anio": 2001,
    },
    {
        "titulo": "Los juegos del hambre",
        "autor": "Suzanne Collins",
        "genero": "Distopía",
        "descripcion": "Una joven participa en una competencia mortal organizada por un gobierno autoritario.",
        "anio": 2008,
    },
    {
        "titulo": "Harry Potter y la piedra filosofal",
        "autor": "J. K. Rowling",
        "genero": "Fantasía",
        "descripcion": "Un niño descubre que es mago y comienza sus estudios en una escuela de magia.",
        "anio": 1997,
    },
    {
        "titulo": "El nombre de la rosa",
        "autor": "Umberto Eco",
        "genero": "Misterio histórico",
        "descripcion": "Un monje investiga una serie de muertes en una abadía medieval.",
        "anio": 1980,
    },
    {
        "titulo": "Pedro Páramo",
        "autor": "Juan Rulfo",
        "genero": "Realismo mágico",
        "descripcion": "Un hombre viaja a un pueblo en busca de su padre y encuentra un lugar lleno de voces del pasado.",
        "anio": 1955,
    },
    {
        "titulo": "La casa de los espíritus",
        "autor": "Isabel Allende",
        "genero": "Realismo mágico",
        "descripcion": "La historia de varias generaciones de una familia marcada por cambios sociales y políticos.",
        "anio": 1982,
    },
    {
        "titulo": "Frankenstein",
        "autor": "Mary Shelley",
        "genero": "Gótico",
        "descripcion": "Un científico crea vida y debe enfrentar las consecuencias de su experimento.",
        "anio": 1818,
    },
    {
        "titulo": "El hobbit",
        "autor": "J. R. R. Tolkien",
        "genero": "Fantasía",
        "descripcion": "Bilbo Bolsón emprende una aventura inesperada junto a un grupo de enanos.",
        "anio": 1937,
    },
    {
        "titulo": "Ensayo sobre la ceguera",
        "autor": "José Saramago",
        "genero": "Ficción",
        "descripcion": "Una epidemia de ceguera pone a prueba la convivencia, la ética y la humanidad.",
        "anio": 1995,
    },
]


def sembrar_libros():
    db = next(obtener_db())

    try:
        cantidad = db.query(Libro).count()

        if cantidad == 0:
            for datos in LIBROS_INICIALES:
                db.add(Libro(**datos))

            db.commit()
    finally:
        db.close()


sembrar_libros()

app = FastAPI(
    title="LecturaIA API",
    version="1.0.0",
)

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post(
    "/auth/registro",
    response_model=UsuarioRespuesta,
    status_code=status.HTTP_201_CREATED,
)
def registrar_usuario(
    datos: UsuarioRegistro,
    db: Session = Depends(obtener_db),
):
    existente = (
        db.query(Usuario)
        .filter(Usuario.email == datos.email.lower())
        .first()
    )

    if existente:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="El correo ya está registrado.",
        )

    usuario = Usuario(
        nombre=datos.nombre.strip(),
        email=datos.email.lower(),
        password_hash=crear_hash_password(datos.password),
    )

    db.add(usuario)
    db.commit()
    db.refresh(usuario)

    return usuario


@app.post(
    "/auth/login",
    response_model=TokenRespuesta,
)
def iniciar_sesion(
    datos: UsuarioLogin,
    db: Session = Depends(obtener_db),
):
    usuario = (
        db.query(Usuario)
        .filter(Usuario.email == datos.email.lower())
        .first()
    )

    if usuario is None or not verificar_password(
        datos.password,
        usuario.password_hash,
    ):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Correo o contraseña incorrectos.",
        )

    token = crear_token_acceso(usuario.id)

    return TokenRespuesta(
        access_token=token,
        token_type="bearer",
    )


def obtener_usuario_actual(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(obtener_db),
):
    credenciales_invalidas = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="No autorizado.",
    )

    try:
        payload = jwt.decode(
            token,
            SECRET_KEY,
            algorithms=[ALGORITHM],
        )

        usuario_id = int(payload.get("sub"))
    except (JWTError, TypeError, ValueError):
        raise credenciales_invalidas

    usuario = (
        db.query(Usuario)
        .filter(Usuario.id == usuario_id)
        .first()
    )

    if usuario is None:
        raise credenciales_invalidas

    return usuario


@app.get(
    "/auth/me",
    response_model=UsuarioRespuesta,
)
def usuario_actual(
    usuario: Usuario = Depends(obtener_usuario_actual),
):
    return usuario


@app.get(
    "/libros",
    response_model=list[LibroRespuesta],
)
def listar_libros(
    db: Session = Depends(obtener_db),
):
    return db.query(Libro).order_by(Libro.titulo).all()
