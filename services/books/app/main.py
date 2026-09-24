from fastapi import FastAPI

app = FastAPI(
    title="Biblioteca+ - Book Service",
    version="1.0.0"
)


@app.get("/health")
def health():
    return {
        "service": "books",
        "status": "online"
    }