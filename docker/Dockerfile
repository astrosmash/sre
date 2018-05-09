FROM python:2.7-alpine

COPY ./server/server.py /server.py
RUN pip install pyparsing

ENTRYPOINT python /server.py
