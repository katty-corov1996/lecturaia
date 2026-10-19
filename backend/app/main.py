from fastapi import Depends, FastAPI, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from sqlalchemy.orm import Session

from .database import Base, engine, obtener_db
from .models import Usuario
from .schemas import TokenRespuesta, UsuarioLogin, UsuarioRegistro, UsuarioRespuesta
from .security import (
    ALGORITHM,
    SECRET_KEY,
    crear_hash_password,
    crear_token_acceso,
    verificar_password,
)

Base.metadata.create_all(bind=engine)

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
