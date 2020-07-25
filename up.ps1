docker-compose -f .\frontproxy\docker-compose.yml up -d

docker-compose -f .\ghost\docker-compose.yml up -d

docker-compose -f .\radikrahl.com\docker-compose.yml up -d

docker-compose -f .\jenkins\docker-compose.yml up -d