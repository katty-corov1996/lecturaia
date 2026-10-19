from pydantic import BaseModel, EmailStr, Field


class UsuarioRegistro(BaseModel):
    nombre: str = Field(min_length=2, max_length=100)
    email: EmailStr
    password: str = Field(min_length=6, max_length=100)


class UsuarioLogin(BaseModel):
    email: EmailStr
    password: str


class UsuarioRespuesta(BaseModel):
    id: int
    nombre: str
    email: EmailStr

    class Config:
        from_attributes = True


class TokenRespuesta(BaseModel):
    access_token: str
    token_type: str = "bearer"



class LibroRespuesta(BaseModel):
    id: int
    titulo: str
    autor: str
    genero: str
    descripcion: str
    anio: int

    class Config:
        from_attributes = True



class ResenaCrear(BaseModel):
    libro_id: int
    comentario: str = Field(min_length=3, max_length=500)
    calificacion: int = Field(ge=1, le=5)


class ResenaRespuesta(BaseModel):
    id: int
    usuario_id: int
    libro_id: int
    comentario: str
    calificacion: int

    class Config:
        from_attributes = True
