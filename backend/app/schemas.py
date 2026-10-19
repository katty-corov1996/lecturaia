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
