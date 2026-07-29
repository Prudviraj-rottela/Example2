from fastapi import FastAPI

app = FastAPI(title="Example2 API")


@app.get("/health")
def health():
    return {"status": "ok", "service": "example2"}
