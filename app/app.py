from fastapi import FastAPI
import socket

app = FastAPI()
counter = 0

@app.get("/")
async def root():
    global counter
    counter += 1
    return f"Container id : {socket.gethostname()}"

@app.get("/get_counts")
async def root():
    return {"counter": counter}

def fake_funk():
    pass

