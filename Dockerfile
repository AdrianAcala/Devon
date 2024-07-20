FROM node:18-alpine

RUN apk add --no-cache python3 py3-pip bash git

RUN python3 -m pip install --user pipx
RUN python3 -m pipx ensurepath

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN pipx install devon_agent
RUN npm install -g devon-ui

EXPOSE 3000

ENTRYPOINT ["devon-ui"]