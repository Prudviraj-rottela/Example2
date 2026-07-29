FROM alpine:3.20

RUN apk add --no-cache python3 py3-pip

WORKDIR /app
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt
COPY app.py .

EXPOSE 8000
CMD ["python3", "app.py"]
