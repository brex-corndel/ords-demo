FROM python:3.8-slim-buster AS base
LABEL key="Jeremy Brex ords-demo"

# Add Curl as not part of slim Buster
RUN apt-get update -y && apt-get install curl -y

# Install Poetry

ENV POETRY_HOME=/poetry
ENV PATH=${POETRY_HOME}/bin:${PATH}

RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python

# Set the working directory.
WORKDIR /app
COPY pyproject.toml /app
COPY poetry.toml /app

# Development Docker
FROM base as development
RUN poetry install
ENTRYPOINT ["poetry", "run", "flask", "run"]
CMD [ "--host=0.0.0.0"]
