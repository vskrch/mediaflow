FROM python:3.9

RUN useradd -m -u 1000 user
USER user
ENV PATH="/home/user/.local/bin:$PATH"

WORKDIR /app

RUN pip install mediaflow-proxy

EXPOSE 7860

CMD ["uvicorn", "mediaflow_proxy.main:app", "--host", "0.0.0.0", "--port", "7860", "--workers", "4"]
