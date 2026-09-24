from fastapi import FastAPI

app = FastAPI(
    title="Biblioteca+ - User Service",
    version="1.0.0"
)


@app.get("/health")
def health():
    return {
        "service": "users",
        "status": "online"
    }