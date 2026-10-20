import os
import json
import httpx
import asyncio
from pathlib import Path


from fastapi import Depends, FastAPI, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from sqlalchemy.orm import Session

from .database import Base, engine, obtener_db

from .models import Libro, Resena, Usuario


from .schemas import (
    LibroRespuesta,
    ResenaCrear,
    ResenaRespuesta,
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

DATA_DIR = Path(__file__).resolve().parent.parent / "data"
LIBROS_DATASET = DATA_DIR / "libros.json"


def cargar_libros_iniciales():
    with LIBROS_DATASET.open("r", encoding="utf-8") as archivo:
        return json.load(archivo)


def sembrar_libros():
    db = next(obtener_db())

    try:
        cantidad = db.query(Libro).count()

        if cantidad == 0:
            for datos in cargar_libros_iniciales():
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


@app.post(
    "/resenas",
    response_model=ResenaRespuesta,
    status_code=status.HTTP_201_CREATED,
)
def crear_resena(
    datos: ResenaCrear,
    usuario: Usuario = Depends(obtener_usuario_actual),
    db: Session = Depends(obtener_db),
):
    libro = (
        db.query(Libro)
        .filter(Libro.id == datos.libro_id)
        .first()
    )

    if libro is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Libro no encontrado.",
        )

    resena = Resena(
        usuario_id=usuario.id,
        libro_id=datos.libro_id,
        comentario=datos.comentario.strip(),
        calificacion=datos.calificacion,
    )

    db.add(resena)
    db.commit()
    db.refresh(resena)

    return resena


@app.get(
    "/resenas/mias",
    response_model=list[ResenaRespuesta],
)
def listar_mis_resenas(
    usuario: Usuario = Depends(obtener_usuario_actual),
    db: Session = Depends(obtener_db),
):
    return (
        db.query(Resena)
        .filter(Resena.usuario_id == usuario.id)
        .order_by(Resena.id.desc())
        .all()
    )


@app.delete(
    "/resenas/{resena_id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
def eliminar_resena(
    resena_id: int,
    usuario: Usuario = Depends(obtener_usuario_actual),
    db: Session = Depends(obtener_db),
):
    resena = (
        db.query(Resena)
        .filter(
            Resena.id == resena_id,
            Resena.usuario_id == usuario.id,
        )
        .first()
    )

    if resena is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Reseña no encontrada.",
        )

    db.delete(resena)
    db.commit()

    return None


@app.post("/ia/recomendar")
async def recomendar_lectura(
    preferencias: dict,
    usuario: Usuario = Depends(obtener_usuario_actual),
):
    api_key = os.getenv("GEMINI_API_KEY")

    if not api_key:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="La clave de Gemini no está configurada.",
        )

    gustos = preferencias.get("preferencias", "").strip()

    if not gustos:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Debes indicar tus preferencias de lectura.",
        )

    prompt = (
        "Eres un asistente de recomendación de libros. "
        "Recomienda 3 libros adecuados para el usuario según sus preferencias. "
        "Para cada libro indica título, autor y una breve razón de recomendación. "
        "Responde en español y de forma clara.\n\n"
        f"Preferencias del usuario: {gustos}"
    )


    url = "https://" + "generativelanguage.googleapis.com/v1beta/models/gemini-3.6-flash:generateContent"

    payload = {
        "contents": [
            {
                "parts": [
                    {
                        "text": prompt,
                    }
                ]
            }
        ]
    }

    try:
        timeout = httpx.Timeout(
            connect=10.0,
            read=60.0,
            write=10.0,
            pool=10.0,
        )

        async with httpx.AsyncClient(timeout=timeout) as client:
            response = await client.post(
                url,
                headers={
                    "x-goog-api-key": api_key,
                    "Content-Type": "application/json",
                },
                json=payload,
            )

        if response.status_code == 503:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail=(
                    "El servicio de inteligencia artificial "
                    "está temporalmente saturado. "
                    "Intenta nuevamente en unos momentos."
                ),
            )


        if response.status_code != 200:
            print(
                "ERROR GEMINI:",
                response.status_code,
                response.text,
            )

            raise HTTPException(
                status_code=status.HTTP_502_BAD_GATEWAY,
                detail=(
                    "No fue posible obtener una respuesta "
                    "del servicio de IA."
                ),
            )


        data = response.json()

        texto = (
            data["candidates"][0]["content"]["parts"][0]["text"]
        )

        return {
            "recomendacion": texto,
        }

    


    except httpx.RequestError as e:
        print(
            "ERROR HTTPX IA:",
            type(e).__name__,
            str(e),
        )

        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="No se pudo conectar con el servicio de IA.",
        )
